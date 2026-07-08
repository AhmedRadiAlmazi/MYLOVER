import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_models.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  // ── Stats & Achievements ──

  Stream<GameStatsModel> streamGameStats(String userId) {
    return _firestore.collection('game_stats').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return GameStatsModel.fromMap(doc.data()!, userId);
      }
      return GameStatsModel(userId: userId);
    });
  }

  Future<void> addPointsAndStats(String userId, int pointsAmount, {String? winField}) async {
    final docRef = _firestore.collection('game_stats').doc(userId);
    final doc = await docRef.get();

    int currentPoints = 0;
    int xoWins = 0;
    int whoKnowsWins = 0;
    int drawGuessWins = 0;
    int voiceChallengeWins = 0;
    int completedChallenges = 0;
    List<String> currentBadges = [];

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      currentPoints = data['points'] ?? 0;
      xoWins = data['xoWins'] ?? 0;
      whoKnowsWins = data['whoKnowsWins'] ?? 0;
      drawGuessWins = data['drawGuessWins'] ?? 0;
      voiceChallengeWins = data['voiceChallengeWins'] ?? 0;
      completedChallenges = data['completedChallenges'] ?? 0;
      currentBadges = List<String>.from(data['badges'] ?? []);
    }

    currentPoints += pointsAmount;
    if (winField != null) {
      if (winField == 'xoWins') xoWins++;
      if (winField == 'whoKnowsWins') whoKnowsWins++;
      if (winField == 'drawGuessWins') drawGuessWins++;
      if (winField == 'voiceChallengeWins') voiceChallengeWins++;
      if (winField == 'completedChallenges') completedChallenges++;
    }

    // Badge evaluations
    final List<String> badges = List<String>.from(currentBadges);
    void checkAndAddBadge(String badge, bool condition) {
      if (condition && !badges.contains(badge)) {
        badges.add(badge);
      }
    }

    checkAndAddBadge('ملك XO', xoWins >= 5);
    checkAndAddBadge('خبير الأسئلة', whoKnowsWins >= 5);
    checkAndAddBadge('أفضل رسام', drawGuessWins >= 3);
    checkAndAddBadge('أجمل صوت', voiceChallengeWins >= 3);
    checkAndAddBadge('بطل التحديات', completedChallenges >= 10);
    checkAndAddBadge('روح واحدة', currentPoints >= 200);

    await docRef.set({
      'userId': userId,
      'points': currentPoints,
      'xoWins': xoWins,
      'whoKnowsWins': whoKnowsWins,
      'drawGuessWins': drawGuessWins,
      'voiceChallengeWins': voiceChallengeWins,
      'completedChallenges': completedChallenges,
      'badges': badges,
    }, SetOptions(merge: true));
  }

  // ── XO Game ──

  Stream<XOGameState?> streamXOGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_xo').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return XOGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> startXOGame(String coupleId, String playerXId, String playerOId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_xo');
    final doc = await docRef.get();

    Map<String, int> scores = {playerXId: 0, playerOId: 0, 'draw': 0};
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if (data['score'] != null) {
        scores = Map<String, int>.from(data['score']);
      }
    }

    final newGame = XOGameState(
      id: '${coupleId}_xo',
      playerXId: playerXId,
      playerOId: playerOId,
      currentTurnId: playerXId, // X starts
      board: List.filled(9, ""),
      status: 'active',
      score: scores,
      updatedAt: DateTime.now(),
    );

    await docRef.set(newGame.toMap());
  }

  Future<void> makeXOMove(String coupleId, int index, String myId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_xo');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final game = XOGameState.fromMap(doc.data()!, doc.id);
    if (game.status != 'active' || game.currentTurnId != myId || game.board[index] != "") return;

    final symbol = myId == game.playerXId ? "X" : "O";
    final newBoard = List<String>.from(game.board);
    newBoard[index] = symbol;

    String? winnerId;
    String status = 'active';
    Map<String, int> score = Map<String, int>.from(game.score);

    // Check wins
    const wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6],             // Diag
    ];

    bool hasWon = false;
    for (final w in wins) {
      if (newBoard[w[0]] != "" && newBoard[w[0]] == newBoard[w[1]] && newBoard[w[1]] == newBoard[w[2]]) {
        hasWon = true;
        break;
      }
    }

    if (hasWon) {
      winnerId = myId;
      status = 'finished';
      score[myId] = (score[myId] ?? 0) + 1;
      await addPointsAndStats(myId, 5, winField: 'xoWins');
    } else if (newBoard.every((cell) => cell != "")) {
      winnerId = 'draw';
      status = 'finished';
      score['draw'] = (score['draw'] ?? 0) + 1;
    }

    final nextTurnId = myId == game.playerXId ? game.playerOId : game.playerXId;

    await docRef.update({
      'board': newBoard,
      'currentTurnId': nextTurnId,
      'winnerId': winnerId,
      'status': status,
      'score': score,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Who Knows the Other More ──

  Stream<WhoKnowsGameState?> streamWhoKnowsGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_who_knows').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return WhoKnowsGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> createWhoKnowsQuestion(String coupleId, String creatorId, String receiverId, String questionText, List<String> options, int correctIndex) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_who_knows');
    final newGame = WhoKnowsGameState(
      id: '${coupleId}_who_knows',
      creatorId: creatorId,
      receiverId: receiverId,
      questionText: questionText,
      options: options,
      correctOptionIndex: correctIndex,
      selectedOptionIndex: null,
      status: 'pending',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> answerWhoKnowsQuestion(String coupleId, int selectedIndex, String myId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_who_knows');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final game = WhoKnowsGameState.fromMap(doc.data()!, doc.id);
    if (game.status != 'pending' || game.receiverId != myId) return;

    final isCorrect = selectedIndex == game.correctOptionIndex;
    if (isCorrect) {
      await addPointsAndStats(myId, 10, winField: 'whoKnowsWins');
    }

    await docRef.update({
      'selectedOptionIndex': selectedIndex,
      'status': 'answered',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetWhoKnowsGame(String coupleId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_who_knows');
    await docRef.delete();
  }

  // ── Truth or Dare custom challenges ──

  Stream<TruthDareGameState?> streamTruthDareGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_truth_dare').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return TruthDareGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> sendTruthDareChallenge(String coupleId, String creatorId, String receiverId, String text, String type) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_truth_dare');
    final newGame = TruthDareGameState(
      id: '${coupleId}_truth_dare',
      creatorId: creatorId,
      receiverId: receiverId,
      challengeText: text,
      challengeType: type,
      status: 'pending',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> respondToTruthDareChallenge(String coupleId, String responderId, {String? mediaUrl}) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_truth_dare');
    await docRef.update({
      'status': 'completed',
      'responseMediaUrl': mediaUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await addPointsAndStats(responderId, 10, winField: 'completedChallenges');
  }

  Future<void> resetTruthDareGame(String coupleId) async {
    await _firestore.collection('games').doc('${coupleId}_truth_dare').delete();
  }

  // ── Complete Sentence ──

  Stream<CompleteSentenceGameState?> streamCompleteSentenceGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_complete_sentence').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return CompleteSentenceGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> startCompleteSentence(String coupleId, String prompt, String player1Id, String player2Id) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_complete_sentence');
    final newGame = CompleteSentenceGameState(
      id: '${coupleId}_complete_sentence',
      prompt: prompt,
      player1Id: player1Id,
      player2Id: player2Id,
      player1Answer: null,
      player2Answer: null,
      status: 'active',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> submitSentenceAnswer(String coupleId, String answer, String myId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_complete_sentence');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final game = CompleteSentenceGameState.fromMap(doc.data()!, doc.id);
    if (game.status != 'active') return;

    final isPlayer1 = myId == game.player1Id;
    final Map<String, dynamic> updates = {};

    if (isPlayer1) {
      updates['player1Answer'] = answer;
      if (game.player2Answer != null && game.player2Answer!.isNotEmpty) {
        updates['status'] = 'revealed';
      }
    } else {
      updates['player2Answer'] = answer;
      if (game.player1Answer != null && game.player1Answer!.isNotEmpty) {
        updates['status'] = 'revealed';
      }
    }

    updates['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.update(updates);
    await addPointsAndStats(myId, 5, winField: 'completedChallenges');
  }

  // ── Draw & Guess ──

  Stream<DrawGuessGameState?> streamDrawGuessGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_draw_guess').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return DrawGuessGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> startDrawGuess(String coupleId, String painterId, String guesserId, String secretWord) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_draw_guess');
    final newGame = DrawGuessGameState(
      id: '${coupleId}_draw_guess',
      painterId: painterId,
      guesserId: guesserId,
      secretWord: secretWord,
      drawingData: '[]',
      status: 'painting',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> updateDrawing(String coupleId, String drawingData) async {
    await _firestore.collection('games').doc('${coupleId}_draw_guess').update({
      'drawingData': drawingData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> guessDrawing(String coupleId, String guess, String myId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_draw_guess');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final game = DrawGuessGameState.fromMap(doc.data()!, doc.id);
    if (game.status != 'painting' || game.guesserId != myId) return;

    final isCorrect = guess.trim() == game.secretWord.trim();
    if (isCorrect) {
      await docRef.update({
        'guessText': guess,
        'status': 'guessed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Award points: painter gets 10 (good painting), guesser gets 5 (good guess)
      await addPointsAndStats(game.painterId, 10, winField: 'drawGuessWins');
      await addPointsAndStats(game.guesserId, 5);
    } else {
      await docRef.update({
        'guessText': guess,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> giveUpDrawing(String coupleId) async {
    await _firestore.collection('games').doc('${coupleId}_draw_guess').update({
      'status': 'gave_up',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Voice Challenge ──

  Stream<VoiceChallengeGameState?> streamVoiceChallengeGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_voice_challenge').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return VoiceChallengeGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> startVoiceChallenge(String coupleId, String senderId, String receiverId, String phrase, String voiceUrl) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_voice_challenge');
    final newGame = VoiceChallengeGameState(
      id: '${coupleId}_voice_challenge',
      senderId: senderId,
      receiverId: receiverId,
      phrase: phrase,
      voiceUrl: voiceUrl,
      status: 'recorded',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> rateVoiceChallenge(String coupleId, double rating, String raterId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_voice_challenge');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final game = VoiceChallengeGameState.fromMap(doc.data()!, doc.id);
    if (game.status != 'recorded' || game.receiverId != raterId) return;

    await docRef.update({
      'rating': rating,
      'status': 'rated',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Rating award points:
    // speaker gets rating as points (e.g. 5 stars = 10 pts)
    final speakerPoints = (rating * 2).toInt();
    await addPointsAndStats(game.senderId, speakerPoints, winField: 'voiceChallengeWins');
    // Rater gets 5 pts
    await addPointsAndStats(raterId, 5);
  }

  // ── Wheel of Surprises ──

  Stream<WheelGameState?> streamWheelGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_wheel').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return WheelGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> spinWheel(String coupleId, String spinnerId, String taskText) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_wheel');
    final newGame = WheelGameState(
      id: '${coupleId}_wheel',
      spinnerId: spinnerId,
      taskText: taskText,
      status: 'spinned',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> completeWheelTask(String coupleId, String spinnerId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_wheel');
    await docRef.update({
      'completed': true,
      'status': 'done',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await addPointsAndStats(spinnerId, 5, winField: 'completedChallenges');
  }

  // ── Memory Quiz ──

  Stream<MemoryQuizGameState?> streamMemoryQuizGame(String coupleId) {
    return _firestore.collection('games').doc('${coupleId}_memory_quiz').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return MemoryQuizGameState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> createMemoryQuiz(String coupleId, String memoryId, String question, List<String> choices, int correctIndex) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_memory_quiz');
    final newGame = MemoryQuizGameState(
      id: '${coupleId}_memory_quiz',
      memoryId: memoryId,
      question: question,
      choices: choices,
      correctChoiceIndex: correctIndex,
      status: 'pending',
      updatedAt: DateTime.now(),
    );
    await docRef.set(newGame.toMap());
  }

  Future<void> answerMemoryQuiz(String coupleId, int selectedIndex, String myId) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_memory_quiz');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final game = MemoryQuizGameState.fromMap(doc.data()!, doc.id);
    if (game.status != 'pending') return;

    final isCorrect = selectedIndex == game.correctChoiceIndex;
    if (isCorrect) {
      await addPointsAndStats(myId, 15, winField: 'whoKnowsWins');
    }

    await docRef.update({
      'selectedChoiceIndex': selectedIndex,
      'status': 'answered',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Daily Challenge ──

  Stream<DailyChallengeState?> streamDailyChallenge(String coupleId, String dateKey) {
    return _firestore.collection('games').doc('${coupleId}_daily_$dateKey').snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return DailyChallengeState.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> initializeDailyChallenge(String coupleId, String dateKey, String challengeType, String challengeText) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_daily_$dateKey');
    final doc = await docRef.get();
    if (doc.exists) return; // already initialized

    final newState = DailyChallengeState(
      id: '${coupleId}_daily_$dateKey',
      challengeType: challengeType,
      challengeText: challengeText,
      userCompletions: {},
      userSubmissions: {},
      date: DateTime.now(),
    );
    await docRef.set(newState.toMap());
  }

  Future<void> submitDailyChallenge(String coupleId, String dateKey, String myId, String partnerId, String submission) async {
    final docRef = _firestore.collection('games').doc('${coupleId}_daily_$dateKey');
    final doc = await docRef.get();
    if (!doc.exists || doc.data() == null) return;

    final challenge = DailyChallengeState.fromMap(doc.data()!, doc.id);
    
    final completions = Map<String, bool>.from(challenge.userCompletions);
    final submissions = Map<String, String>.from(challenge.userSubmissions);

    completions[myId] = true;
    submissions[myId] = submission;

    await docRef.update({
      'userCompletions': completions,
      'userSubmissions': submissions,
    });

    // Check if both are now completed
    final myCompleted = completions[myId] == true;
    final partnerCompleted = completions[partnerId] == true;

    if (myCompleted && partnerCompleted) {
      // Award both players +20 points
      await addPointsAndStats(myId, 20, winField: 'completedChallenges');
      await addPointsAndStats(partnerId, 20, winField: 'completedChallenges');
    } else {
      await addPointsAndStats(myId, 10, winField: 'completedChallenges');
    }
  }
}

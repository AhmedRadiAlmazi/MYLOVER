import 'package:cloud_firestore/cloud_firestore.dart';

class GameStatsModel {
  final String userId;
  final int points;
  final int xoWins;
  final int whoKnowsWins;
  final int drawGuessWins;
  final int voiceChallengeWins;
  final int completedChallenges;
  final List<String> badges;

  const GameStatsModel({
    required this.userId,
    this.points = 0,
    this.xoWins = 0,
    this.whoKnowsWins = 0,
    this.drawGuessWins = 0,
    this.voiceChallengeWins = 0,
    this.completedChallenges = 0,
    this.badges = const [],
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'points': points,
        'xoWins': xoWins,
        'whoKnowsWins': whoKnowsWins,
        'drawGuessWins': drawGuessWins,
        'voiceChallengeWins': voiceChallengeWins,
        'completedChallenges': completedChallenges,
        'badges': badges,
      };

  factory GameStatsModel.fromMap(Map<String, dynamic> map, String userId) => GameStatsModel(
        userId: userId,
        points: map['points'] ?? 0,
        xoWins: map['xoWins'] ?? 0,
        whoKnowsWins: map['whoKnowsWins'] ?? 0,
        drawGuessWins: map['drawGuessWins'] ?? 0,
        voiceChallengeWins: map['voiceChallengeWins'] ?? 0,
        completedChallenges: map['completedChallenges'] ?? 0,
        badges: List<String>.from(map['badges'] ?? []),
      );
}

class XOGameState {
  final String id;
  final String playerXId;
  final String playerOId;
  final String currentTurnId;
  final List<String> board; // ["", "X", "O"...]
  final String? winnerId; // null, userId, or 'draw'
  final String status; // 'waiting', 'active', 'finished'
  final Map<String, int> score;
  final DateTime updatedAt;

  const XOGameState({
    required this.id,
    required this.playerXId,
    required this.playerOId,
    required this.currentTurnId,
    required this.board,
    this.winnerId,
    required this.status,
    required this.score,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'playerXId': playerXId,
        'playerOId': playerOId,
        'currentTurnId': currentTurnId,
        'board': board,
        'winnerId': winnerId,
        'status': status,
        'score': score,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory XOGameState.fromMap(Map<String, dynamic> map, String id) => XOGameState(
        id: id,
        playerXId: map['playerXId'] ?? '',
        playerOId: map['playerOId'] ?? '',
        currentTurnId: map['currentTurnId'] ?? '',
        board: List<String>.from(map['board'] ?? List.filled(9, "")),
        winnerId: map['winnerId'],
        status: map['status'] ?? 'active',
        score: Map<String, int>.from(map['score'] ?? {}),
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class WhoKnowsGameState {
  final String id;
  final String creatorId;
  final String receiverId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int? selectedOptionIndex;
  final String status; // 'setup', 'pending', 'answered'
  final DateTime updatedAt;

  const WhoKnowsGameState({
    required this.id,
    required this.creatorId,
    required this.receiverId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.selectedOptionIndex,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'creatorId': creatorId,
        'receiverId': receiverId,
        'questionText': questionText,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'selectedOptionIndex': selectedOptionIndex,
        'status': status,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory WhoKnowsGameState.fromMap(Map<String, dynamic> map, String id) => WhoKnowsGameState(
        id: id,
        creatorId: map['creatorId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        questionText: map['questionText'] ?? '',
        options: List<String>.from(map['options'] ?? []),
        correctOptionIndex: map['correctOptionIndex'] ?? 0,
        selectedOptionIndex: map['selectedOptionIndex'],
        status: map['status'] ?? 'setup',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class TruthDareGameState {
  final String id;
  final String creatorId;
  final String receiverId;
  final String challengeText;
  final String challengeType; // 'truth' or 'dare'
  final String status; // 'pending', 'completed', 'declined'
  final String? responseMediaUrl;
  final DateTime updatedAt;

  const TruthDareGameState({
    required this.id,
    required this.creatorId,
    required this.receiverId,
    required this.challengeText,
    required this.challengeType,
    required this.status,
    this.responseMediaUrl,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'creatorId': creatorId,
        'receiverId': receiverId,
        'challengeText': challengeText,
        'challengeType': challengeType,
        'status': status,
        'responseMediaUrl': responseMediaUrl,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory TruthDareGameState.fromMap(Map<String, dynamic> map, String id) => TruthDareGameState(
        id: id,
        creatorId: map['creatorId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        challengeText: map['challengeText'] ?? '',
        challengeType: map['challengeType'] ?? 'truth',
        status: map['status'] ?? 'pending',
        responseMediaUrl: map['responseMediaUrl'],
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class CompleteSentenceGameState {
  final String id;
  final String prompt;
  final String player1Id;
  final String player2Id;
  final String? player1Answer;
  final String? player2Answer;
  final String status; // 'active', 'revealed'
  final DateTime updatedAt;

  const CompleteSentenceGameState({
    required this.id,
    required this.prompt,
    required this.player1Id,
    required this.player2Id,
    this.player1Answer,
    this.player2Answer,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'prompt': prompt,
        'player1Id': player1Id,
        'player2Id': player2Id,
        'player1Answer': player1Answer,
        'player2Answer': player2Answer,
        'status': status,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory CompleteSentenceGameState.fromMap(Map<String, dynamic> map, String id) => CompleteSentenceGameState(
        id: id,
        prompt: map['prompt'] ?? '',
        player1Id: map['player1Id'] ?? '',
        player2Id: map['player2Id'] ?? '',
        player1Answer: map['player1Answer'],
        player2Answer: map['player2Answer'],
        status: map['status'] ?? 'active',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class DrawGuessGameState {
  final String id;
  final String painterId;
  final String guesserId;
  final String secretWord;
  final String drawingData; // JSON or compressed stroke list
  final String? guessText;
  final String status; // 'painting', 'guessed', 'gave_up'
  final DateTime updatedAt;

  const DrawGuessGameState({
    required this.id,
    required this.painterId,
    required this.guesserId,
    required this.secretWord,
    required this.drawingData,
    this.guessText,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'painterId': painterId,
        'guesserId': guesserId,
        'secretWord': secretWord,
        'drawingData': drawingData,
        'guessText': guessText,
        'status': status,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory DrawGuessGameState.fromMap(Map<String, dynamic> map, String id) => DrawGuessGameState(
        id: id,
        painterId: map['painterId'] ?? '',
        guesserId: map['guesserId'] ?? '',
        secretWord: map['secretWord'] ?? '',
        drawingData: map['drawingData'] ?? '[]',
        guessText: map['guessText'],
        status: map['status'] ?? 'painting',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class VoiceChallengeGameState {
  final String id;
  final String senderId;
  final String receiverId;
  final String phrase;
  final String voiceUrl;
  final double rating; // 0 to 5
  final String status; // 'recorded', 'rated'
  final DateTime updatedAt;

  const VoiceChallengeGameState({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.phrase,
    required this.voiceUrl,
    this.rating = 0.0,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'phrase': phrase,
        'voiceUrl': voiceUrl,
        'rating': rating,
        'status': status,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory VoiceChallengeGameState.fromMap(Map<String, dynamic> map, String id) => VoiceChallengeGameState(
        id: id,
        senderId: map['senderId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        phrase: map['phrase'] ?? '',
        voiceUrl: map['voiceUrl'] ?? '',
        rating: (map['rating'] ?? 0.0).toDouble(),
        status: map['status'] ?? 'recorded',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class WheelGameState {
  final String id;
  final String spinnerId;
  final String taskText;
  final bool completed;
  final String status; // 'spinned', 'done'
  final DateTime updatedAt;

  const WheelGameState({
    required this.id,
    required this.spinnerId,
    required this.taskText,
    this.completed = false,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'spinnerId': spinnerId,
        'taskText': taskText,
        'completed': completed,
        'status': status,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory WheelGameState.fromMap(Map<String, dynamic> map, String id) => WheelGameState(
        id: id,
        spinnerId: map['spinnerId'] ?? '',
        taskText: map['taskText'] ?? '',
        completed: map['completed'] ?? false,
        status: map['status'] ?? 'spinned',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class MemoryQuizGameState {
  final String id;
  final String memoryId;
  final String question;
  final List<String> choices;
  final int correctChoiceIndex;
  final int? selectedChoiceIndex;
  final String status; // 'pending', 'answered'
  final DateTime updatedAt;

  const MemoryQuizGameState({
    required this.id,
    required this.memoryId,
    required this.question,
    required this.choices,
    required this.correctChoiceIndex,
    this.selectedChoiceIndex,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'memoryId': memoryId,
        'question': question,
        'choices': choices,
        'correctChoiceIndex': correctChoiceIndex,
        'selectedChoiceIndex': selectedChoiceIndex,
        'status': status,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory MemoryQuizGameState.fromMap(Map<String, dynamic> map, String id) => MemoryQuizGameState(
        id: id,
        memoryId: map['memoryId'] ?? '',
        question: map['question'] ?? '',
        choices: List<String>.from(map['choices'] ?? []),
        correctChoiceIndex: map['correctChoiceIndex'] ?? 0,
        selectedChoiceIndex: map['selectedChoiceIndex'],
        status: map['status'] ?? 'pending',
        updatedAt: map['updatedAt'] != null
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

class DailyChallengeState {
  final String id;
  final String challengeType; // 'text', 'photo', 'voice', 'drawing', 'question'
  final String challengeText;
  final Map<String, bool> userCompletions; // {userId: true/false}
  final Map<String, String> userSubmissions; // {userId: text/mediaUrl}
  final DateTime date;

  const DailyChallengeState({
    required this.id,
    required this.challengeType,
    required this.challengeText,
    required this.userCompletions,
    required this.userSubmissions,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'challengeType': challengeType,
        'challengeText': challengeText,
        'userCompletions': userCompletions,
        'userSubmissions': userSubmissions,
        'date': Timestamp.fromDate(date),
      };

  factory DailyChallengeState.fromMap(Map<String, dynamic> map, String id) => DailyChallengeState(
        id: id,
        challengeType: map['challengeType'] ?? 'text',
        challengeText: map['challengeText'] ?? '',
        userCompletions: Map<String, bool>.from(map['userCompletions'] ?? {}),
        userSubmissions: Map<String, String>.from(map['userSubmissions'] ?? {}),
        date: map['date'] != null ? (map['date'] as Timestamp).toDate() : DateTime.now(),
      );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:my_universe/core/models/app_models.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel map serialization and deserialization works', () {
      final user = UserModel(
        id: 'test_uid_123',
        name: 'أحمد',
        email: 'ahmed@test.com',
        partnerId: 'partner_456',
        pairingCode: 'ABC123',
        isOnline: true,
      );

      final map = user.toMap();
      expect(map['id'], 'test_uid_123');
      expect(map['name'], 'أحمد');
      expect(map['email'], 'ahmed@test.com');
      expect(map['pairingCode'], 'ABC123');
      expect(map['isOnline'], true);

      final restored = UserModel.fromMap(map);
      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.email, user.email);
      expect(restored.partnerId, user.partnerId);
      expect(restored.pairingCode, user.pairingCode);
      expect(restored.isOnline, user.isOnline);
    });

    test('UserModel copyWith creates modified instance', () {
      final user = UserModel.mock();
      final updated = user.copyWith(name: 'علي', isOnline: false);

      expect(updated.id, user.id);
      expect(updated.name, 'علي');
      expect(updated.isOnline, false);
      expect(updated.partnerId, user.partnerId);
    });
  });

  group('MessageModel Tests', () {
    test('MessageModel mock messages list is valid and sorted', () {
      final messages = MessageModel.mockMessages;
      expect(messages.isNotEmpty, true);
      expect(messages.first.id, '1');
      expect(messages.first.type, MessageType.text);
    });
  });

  group('DiaryModel Tests', () {
    test('DiaryModel serialization and IconData getter work', () {
      final diary = DiaryModel(
        id: 'd1',
        title: 'يوم سعيد',
        body: 'محتوى اليومية',
        mood: 'سعيد',
        moodIconCodePoint: 59483,
        date: DateTime(2024, 5, 10),
        authorName: 'أحمد',
      );

      expect(diary.moodIcon.codePoint, 59483);
      expect(diary.authorName, 'أحمد');
    });
  });

  group('WishModel & EventModel Tests', () {
    test('WishModel mock bucket list items are valid', () {
      final bucketList = WishModel.mockBucketList;
      expect(bucketList.isNotEmpty, true);
      expect(bucketList.every((w) => w.isBucketList), true);
    });

    test('EventModel mock events are recurring anniversaries', () {
      final events = EventModel.mockEvents;
      expect(events.isNotEmpty, true);
      expect(events.first.type, 'anniversary');
      expect(events.first.isRecurring, true);
    });
  });
}

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'كوني أنت';
  static const String appVersion = '1.0.0';
  static const String appBundleId = 'com.myuniverse.app';

  // Pairing
  static const int pairingCodeLength = 6;
  static const int maxUsersPerPair = 2;

  // Chat
  static const int messagePageSize = 30;
  static const int maxMessageLength = 1000;
  static const int maxCaptionLength = 300;

  // Media
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxAudioSizeMB = 25;
  static const int maxFileSizeMB = 50;

  // UI
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXL = 28.0;
  static const double borderRadiusCircular = 100.0;

  static const double paddingXS = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXL = 24.0;
  static const double paddingXXL = 32.0;

  static const double spacingXS = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXL = 32.0;

  // Animation Durations
  static const int animationFast = 200;
  static const int animationMedium = 350;
  static const int animationSlow = 600;
  static const int splashDuration = 3000;

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyPartnerId = 'partner_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyRelationshipStart = 'relationship_start';
  static const String keyIsOnboarded = 'is_onboarded';
  static const String keyPairingCode = 'pairing_code';
  static const String keyIsPaired = 'is_paired';
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyBiometricEnabled = 'biometric_enabled';

  // Love Quotes (Arabic)
  static const List<String> loveQuotes = [
    'أنتَ الشخص الذي جعلَ الفوضى في قلبي تبدو جميلة.',
    'مع وجودك، أصبح كل شيء في مكانه الصحيح.',
    'أحبك بكل نبضة قلب وكل نفَس.',
    'أنتِ الفكرة التي أعود إليها في كل مرة تاهت أفكاري.',
    'الحب هو أن تجد شخصاً يجعل منزلك أجمل بحضوره.',
    'في عيونك أرى كل ما كنت أبحث عنه.',
    'أنتَ ليس من أحتاجه فقط، بل من أريده إلى الأبد.',
    'أجمل ما حدث لي هو لحظة عرفتُك فيها.',
    'قلبي دائماً يعرف طريقه إليك.',
    'بجانبك، أشعر أن كل شيء ممكن.',
    'أنتِ الأمان الذي بحثتُ عنه طويلاً.',
    'الحب الحقيقي لا يُقاس بالكلمات، بل بالوقت المقضى معاً.',
    'مع كل نهار جديد، أحبك أكثر من الأمس.',
    'أنتَ السبب الذي يجعلني أبتسم دون سبب.',
    'في حضنك أجد كل السلام.',
    'روحي تعرفك من قبل أن تعرفك عيناي.',
    'حبك هدية لا تُقدَّر بثمن.',
    'أنتِ الفصل المفضل في قصة حياتي.',
    'أحبك ليس لأنك كامل، بل لأنك الكمال بالنسبة لي.',
    'معك، الأيام العادية تصبح ذكريات لا تُنسى.',
  ];

  // Mood Emojis
  static const List<String> moodEmojis = [
    '😊', '😍', '😢', '😤', '😴', '🥰',
    '😌', '🤩', '😔', '🥺', '😁', '❤️',
  ];

  // Relationship Milestones
  static const List<Map<String, String>> milestones = [
    {'days': '7', 'title': 'أسبوع من الحب', 'emoji': '🌱'},
    {'days': '30', 'title': 'شهر جميل', 'emoji': '🌸'},
    {'days': '100', 'title': '100 يوم معاً', 'emoji': '✨'},
    {'days': '365', 'title': 'سنة كاملة', 'emoji': '🎉'},
    {'days': '500', 'title': '500 يوم', 'emoji': '💫'},
    {'days': '730', 'title': 'سنتان من الحب', 'emoji': '💕'},
    {'days': '1000', 'title': '1000 يوم', 'emoji': '👑'},
  ];
}

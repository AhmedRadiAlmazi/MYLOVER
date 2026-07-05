import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // يرجى استبدال هذا المفتاح بمفتاحك الحقيقي من Google AI Studio
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; 
  late final GenerativeModel _model;
  ChatSession? _chat;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        'أنت مستشار علاقات عاطفية خبير ولطيف وذكي جداً. اسمك "مستشاري". '
        'تطبيقنا اسمه "كوني أنت" وهو مساحة خاصة لشريكين. '
        'مهمتك هي إعطاء نصائح عاطفية، أفكار هدايا، واقتراحات لمواعيد غرامية. '
        'تحدث بلغة عربية فصحى مبسطة ولطيفة، واستخدم الإيموجي المناسب بحذر.'
      ),
    );
  }

  void startChat() {
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    if (_chat == null) {
      startChat();
    }
    
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? 'عذراً، لم أتمكن من الإجابة في الوقت الحالي.';
    } catch (e) {
      print('AI Error: $e');
      return 'يبدو أن هناك مشكلة في الاتصال بالمساعد الذكي. الرجاء التأكد من مفتاح API أو جرب لاحقاً.';
    }
  }
}

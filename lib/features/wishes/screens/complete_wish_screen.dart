import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/wishes_providers.dart';

class CompleteWishScreen extends ConsumerStatefulWidget {
  final String wishId;

  const CompleteWishScreen({super.key, required this.wishId});

  @override
  ConsumerState<CompleteWishScreen> createState() => _CompleteWishScreenState();
}

class _CompleteWishScreenState extends ConsumerState<CompleteWishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storyController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  List<File> _pickedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 30,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (images.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _completeWish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(wishesRepositoryProvider);
      
      // Get the current wish
      final wishesAsyncValue = ref.read(wishesStreamProvider);
      final wish = wishesAsyncValue.value?.firstWhere((w) => w.id == widget.wishId);
      
      if (wish == null) throw Exception('Wish not found');

      // Convert images to base64 and check size
      List<String> imageBase64List = [];
      int totalSize = 0;
      for (var file in _pickedImages) {
        List<int> imageBytes = file.readAsBytesSync();
        String base64Str = base64Encode(imageBytes);
        imageBase64List.add(base64Str);
        totalSize += base64Str.length;
      }

      if (totalSize > 800000) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('عذراً، حجم الصور كبير جداً ولن يتم حفظه! يرجى اختيار عدد أقل.')),
          );
        }
        return;
      }

      await repository.completeWishAndConvertToMemory(
        wish,
        _storyController.text,
        imageBase64List,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحقيق الأمنية وحفظها في كتاب الذكريات! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنجاز الأمنية ✅'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'مبارك تحقيق الأمنية! 🎉\nحول هذه الأمنية إلى ذكرى جميلة في كتابكما المشترك.',
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _storyController,
                decoration: const InputDecoration(
                  labelText: 'اكتب قصة الذكرى...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) => value!.isEmpty ? 'يرجى كتابة القصة أو الملاحظات' : null,
              ),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('إضافة صور الذكرى'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_pickedImages.isNotEmpty) ...[
                const Text('الصور المختارة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pickedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_pickedImages[index], width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _completeWish,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ في الكتاب المشترك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book_page_model.dart';
import '../providers/shared_book_providers.dart';

class AddEditPageScreen extends ConsumerStatefulWidget {
  final String? pageId;

  const AddEditPageScreen({super.key, this.pageId});

  @override
  ConsumerState<AddEditPageScreen> createState() => _AddEditPageScreenState();
}

class _AddEditPageScreenState extends ConsumerState<AddEditPageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  
  // Local files picked by user
  List<File> _pickedImages = [];
  List<File> _pickedVideos = [];
  List<File> _pickedAudios = [];

  // Existing URLs if editing
  List<String> _existingImageUrls = [];
  List<String> _existingVideoUrls = [];
  List<String> _existingAudioUrls = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPage();
  }

  void _loadExistingPage() {
    if (widget.pageId != null) {
      // Async value might be loaded, we can read it directly from the state if it's there
      // For simplicity, let's assume we can fetch it or pass it. 
      // If we need to fetch it from the provider:
      final pages = ref.read(filteredBookPagesProvider);
      try {
        final page = pages.firstWhere((p) => p.id == widget.pageId);
        _titleController.text = page.title;
        _contentController.text = page.content;
        _selectedDate = page.date;
        _existingImageUrls = List.from(page.imageUrls);
        _existingVideoUrls = List.from(page.videoUrls);
        _existingAudioUrls = List.from(page.audioUrls);
      } catch (e) {
        // Page not found in current state
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 30, // المزيد من الضغط
      maxWidth: 500, // تصغير الأبعاد
      maxHeight: 500,
    );
    if (images.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _pickVideo() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('عذراً، مساحة التخزين المجانية في قاعدة البيانات لا تدعم مقاطع الفيديو كبيرة الحجم حالياً.')),
    );
  }

  Future<void> _pickAudio() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('عذراً، التسجيل الصوتي متوقف حالياً لنفس سبب تخزين الفيديو.')),
    );
  }

  Future<void> _savePage() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(sharedBookRepositoryProvider);
      
      // Convert local images to base64 strings
      List<String> newImageBase64 = [];
      int totalSize = 0;
      for (var file in _pickedImages) {
        List<int> imageBytes = file.readAsBytesSync();
        String base64Str = base64Encode(imageBytes);
        newImageBase64.add(base64Str);
        totalSize += base64Str.length;
      }
      
      for (var existingUrl in _existingImageUrls) {
        totalSize += existingUrl.length;
      }

      if (totalSize > 800000) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('عذراً، حجم الصور كبير جداً ولن يتم حفظه! يرجى اختيار عدد أقل من الصور.')),
          );
        }
        return;
      }

      final newPage = BookPageModel(
        id: widget.pageId ?? const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        date: _selectedDate,
        imageUrls: [..._existingImageUrls, ...newImageBase64],
        videoUrls: _existingVideoUrls, // kept empty for now
        audioUrls: _existingAudioUrls, // kept empty for now
        createdBy: 'currentUser', 
        createdAt: DateTime.now(),
      );

      if (widget.pageId == null) {
        await repository.createPage(newPage);
      } else {
        await repository.updatePage(newPage);
      }
      
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageId == null ? 'إضافة صفحة جديدة' : 'تعديل الصفحة'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _savePage,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الصفحة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('التاريخ'),
                subtitle: Text(DateFormat('yyyy / MM / dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'اكتب القصة...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) => value!.isEmpty ? 'يرجى إدخال القصة' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MediaButton(
                    icon: Icons.image,
                    label: 'صورة',
                    onTap: _pickImages,
                  ),
                  _MediaButton(
                    icon: Icons.videocam,
                    label: 'فيديو',
                    onTap: _pickVideo,
                  ),
                  _MediaButton(
                    icon: Icons.mic,
                    label: 'صوت',
                    onTap: _pickAudio,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              if (_pickedImages.isNotEmpty || _existingImageUrls.isNotEmpty) ...[
                const Text('الصور:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._existingImageUrls.map((base64String) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: base64String.startsWith('http') 
                                ? Image.network(base64String, width: 100, height: 100, fit: BoxFit.cover)
                                : Image.memory(base64Decode(base64String), width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        );
                      }),
                      ..._pickedImages.map((file) => Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_pickedVideos.isNotEmpty || _existingVideoUrls.isNotEmpty) ...[
                const Text('الفيديوهات:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._existingVideoUrls.map((url) => const ListTile(leading: Icon(Icons.video_file), title: Text('فيديو مرفوع'))),
                ..._pickedVideos.map((file) => ListTile(leading: const Icon(Icons.video_file), title: Text(file.path.split('/').last))),
                const SizedBox(height: 16),
              ],

              if (_pickedAudios.isNotEmpty || _existingAudioUrls.isNotEmpty) ...[
                const Text('الملفات الصوتية:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._existingAudioUrls.map((url) => const ListTile(leading: Icon(Icons.audio_file), title: Text('صوت مرفوع'))),
                ..._pickedAudios.map((file) => ListTile(leading: const Icon(Icons.audio_file), title: Text(file.path.split('/').last))),
                const SizedBox(height: 32),
              ],

              ElevatedButton(
                onPressed: _isLoading ? null : _savePage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('حفظ', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

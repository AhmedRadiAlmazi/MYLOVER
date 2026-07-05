import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/wish_model.dart';
import '../providers/wishes_providers.dart';

class AddEditWishScreen extends ConsumerStatefulWidget {
  const AddEditWishScreen({super.key});

  @override
  ConsumerState<AddEditWishScreen> createState() => _AddEditWishScreenState();
}

class _AddEditWishScreenState extends ConsumerState<AddEditWishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  WishCategory _selectedCategory = WishCategory.other;
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveWish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final repository = ref.read(wishesRepositoryProvider);
      
      final newWish = WishModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        category: _selectedCategory,
        targetDate: _targetDate,
        createdBy: 'currentUser',
        createdAt: DateTime.now(),
      );

      await repository.createWish(newWish);

      if (mounted) {
        context.pop();
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
        title: const Text('إضافة أمنية جديدة'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveWish,
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
                  labelText: 'عنوان الأمنية',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<WishCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                ),
                items: WishCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${category.emoji} ${category.label}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                title: const Text('الموعد المستهدف (اختياري)'),
                subtitle: Text(_targetDate != null ? DateFormat('yyyy / MM / dd').format(_targetDate!) : 'لم يتم تحديده'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveWish,
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

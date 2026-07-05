import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class DailyMessagesScreen extends StatefulWidget {
  const DailyMessagesScreen({super.key});

  @override
  State<DailyMessagesScreen> createState() => _DailyMessagesScreenState();
}

class _DailyMessagesScreenState extends State<DailyMessagesScreen> {
  bool _morningEnabled = true;
  bool _eveningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 22, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isMorning) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? _morningTime : _eveningTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'الرسائل الصباحية والمسائية',
          style: GoogleFonts.tajawal(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تخصيص الإشعارات التلقائية للرسائل الصباحية والمسائية بينكما.',
              style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // Morning Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'رسالة الصباح',
                            style: GoogleFonts.tajawal(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _morningEnabled,
                        onChanged: (val) => setState(() => _morningEnabled = val),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (_morningEnabled) ...[
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('وقت الإرسال', style: GoogleFonts.tajawal(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => _selectTime(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _morningTime.format(context),
                              style: GoogleFonts.tajawal(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Evening Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.nightlight_round, color: Colors.indigoAccent, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'رسالة المساء',
                            style: GoogleFonts.tajawal(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _eveningEnabled,
                        onChanged: (val) => setState(() => _eveningEnabled = val),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (_eveningEnabled) ...[
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('وقت الإرسال', style: GoogleFonts.tajawal(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => _selectTime(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _eveningTime.format(context),
                              style: GoogleFonts.tajawal(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'حفظ الإعدادات',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ إعدادات الرسائل بنجاح')),
                  );
                  context.pop();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

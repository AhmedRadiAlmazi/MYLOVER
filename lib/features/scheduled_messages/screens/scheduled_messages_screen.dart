import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../features/scheduled_messages/services/schedule_service.dart';
import '../../auth/providers/auth_provider.dart';

final scheduleServiceProvider = Provider<ScheduleService>((ref) => ScheduleService());

final scheduledMessagesStreamProvider = StreamProvider<List<ScheduledMsgModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(scheduleServiceProvider).getScheduledMessagesStream(user.id, user.partnerId!);
});

class ScheduledMessagesScreen extends ConsumerStatefulWidget {
  const ScheduledMessagesScreen({super.key});

  @override
  ConsumerState<ScheduledMessagesScreen> createState() => _ScheduledMessagesScreenState();
}

class _ScheduledMessagesScreenState extends ConsumerState<ScheduledMessagesScreen> {
  void _showAddDialog() {
    final textController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('رسالة مجدولة جديدة ⏰', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 3,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppColors.card,
                leading: const Icon(Icons.access_time_rounded, color: AppColors.primary),
                title: Text('وقت الإرسال', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
                trailing: Text(selectedTime.format(context), style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime);
                  if (time != null) setStateDialog(() => selectedTime = time);
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            ),
            isSaving
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () async {
                      if (textController.text.trim().isEmpty) return;
                      setStateDialog(() => isSaving = true);
                      
                      try {
                        final user = ref.read(currentUserProvider).value;
                        if (user != null && user.partnerId != null) {
                          final now = DateTime.now();
                          final scheduleDate = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                          
                          final newMsg = ScheduledMsgModel(
                            id: const Uuid().v4(),
                            text: textController.text.trim(),
                            scheduledTime: scheduleDate.isBefore(now) ? scheduleDate.add(const Duration(days: 1)) : scheduleDate, // Next day if time passed
                            senderId: user.id,
                            repeatMode: 'مرة واحدة'
                          );
                          await ref.read(scheduleServiceProvider).addMessage(message: newMsg, userId: user.id, partnerId: user.partnerId!);
                        }
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setStateDialog(() => isSaving = false);
                      }
                    },
                    child: Text('جدولة', style: GoogleFonts.tajawal()),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(scheduledMessagesStreamProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('الرسائل المجدولة ⏰', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Info card
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              child: Row(
                children: [
                  const Text('⏰', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('الرسائل المجدولة', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      Text('أرسل رسائل تلقائياً في الوقت المحدد', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ),
          
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.white))),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text('لا توجد رسائل مجدولة. قم بإضافة رسالة لتفاجئ بها شريكك!', style: GoogleFonts.tajawal(color: AppColors.textHint), textAlign: TextAlign.center),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMyMessage = msg.senderId == user?.id;
                    final timeString = DateFormat('hh:mm a').format(msg.scheduledTime);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: msg.isEnabled ? AppColors.primary.withOpacity(0.3) : AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: msg.isEnabled ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.divider,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.schedule_rounded, color: msg.isEnabled ? AppColors.primary : AppColors.textHint, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(msg.text, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(children: [
                                Text(timeString, style: GoogleFonts.tajawal(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(8)),
                                  child: Text(msg.repeatMode, style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 10)),
                                ),
                                if (!isMyMessage)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.person, size: 12, color: AppColors.secondary),
                                  )
                              ]),
                            ]),
                          ),
                          Switch(
                            value: msg.isEnabled, 
                            onChanged: (val) {
                              if (user != null && user.partnerId != null) {
                                ref.read(scheduleServiceProvider).toggleMessageStatus(
                                  messageId: msg.id, 
                                  isEnabled: val, 
                                  userId: user.id, 
                                  partnerId: user.partnerId!
                                );
                              }
                            }, 
                            activeColor: AppColors.primary
                          ),
                        ],
                      ),
                    ).animate().slideX(delay: Duration(milliseconds: i * 80)).fadeIn(delay: Duration(milliseconds: i * 80));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _showAddDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}


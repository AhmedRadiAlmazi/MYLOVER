import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';

class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({
    super.key,
    required this.dailyQuote,
  });

  final String dailyQuote;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                AppStrings.dailyQuote,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dailyQuote,
            style: GoogleFonts.tajawal(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

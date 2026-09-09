import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/fact.dart';
import '../theme/app_theme.dart';

class FactCard extends StatelessWidget {
  final DailyFact fact;
  const FactCard({super.key, required this.fact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF211C14),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.amber.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('ФАКТ ДНЯ', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            fact.yearLabel,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.amber,
                  fontSize: 32,
                ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 14),
          Text(
            fact.text,
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
          if (fact.pageTitle != null) ...[
            const SizedBox(height: 18),
            Divider(color: AppTheme.muted.withOpacity(0.2)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.menu_book_rounded,
                    size: 16, color: AppTheme.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    fact.pageTitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06, end: 0);
  }
}

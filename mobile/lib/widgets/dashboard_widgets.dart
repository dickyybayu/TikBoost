import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'common_widgets.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final bool isWide;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconContainer(
                icon: icon,
                iconColor: AppColors.beige,
                backgroundColor: AppColors.beige.withOpacity(0.2),
                size: AppConstants.iconMedium,
                padding: AppConstants.paddingSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class AIRecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final VoidCallback? onAction;

  const AIRecommendationCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: AppColors.softGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconContainer(
                icon: Icons.auto_awesome,
                iconColor: AppColors.accent,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                size: AppConstants.iconMedium,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          AppButton(
            text: actionText,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

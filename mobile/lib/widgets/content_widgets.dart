import 'package:flutter/material.dart';
import '../models/content_models.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'common_widgets.dart';

class ContentSuggestionCard extends StatelessWidget {
  final ContentSuggestion suggestion;

  const ContentSuggestionCard({
    super.key,
    required this.suggestion,
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
                icon: suggestion.icon,
                iconColor: suggestion.color,
                backgroundColor: suggestion.color.withOpacity(0.2),
                size: AppConstants.iconLarge,
                padding: AppConstants.paddingMedium,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          AppButton(
            text: 'Get Started',
            onPressed: suggestion.onTap,
            backgroundColor: suggestion.color.withOpacity(0.2),
            textColor: suggestion.color,
            isOutlined: true,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final LiveSession session;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      border: Border(
        left: BorderSide(color: session.color, width: 4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.formattedTime,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    session.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.secondaryText(Theme.of(context).brightness == Brightness.dark),
              size: AppConstants.iconSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final String monthYear;
  final List<int> highlightedDates;
  final int selectedDate;

  const CalendarWidget({
    super.key,
    required this.monthYear,
    this.highlightedDates = const [],
    this.selectedDate = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            monthYear,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Text(
                      day,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isHighlighted = highlightedDates.contains(day);
              final isSelected = day == selectedDate;
              
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppColors.accent
                      : isSelected
                          ? AppColors.accent.withOpacity(0.3)
                          : null,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isHighlighted || isSelected
                          ? AppColors.white
                          : AppColors.white,
                      fontWeight: isHighlighted || isSelected
                          ? FontWeight.bold
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

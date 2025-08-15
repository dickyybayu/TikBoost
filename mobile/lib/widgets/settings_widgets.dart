import 'package:flutter/material.dart';
import '../models/settings_models.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'common_widgets.dart';

class SettingsTile extends StatelessWidget {
  final SettingsItem item;
  final bool isDark;

  const SettingsTile({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                IconContainer(
                  icon: item.icon,
                  iconColor: AppColors.accent,
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  size: AppConstants.iconMedium,
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: AppColors.primaryText(isDark),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            color: AppColors.secondaryText(isDark),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.trailing != null) ...[
                  const SizedBox(width: AppConstants.paddingSmall),
                  item.trailing!,
                ] else ...[
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppConstants.iconSmall,
                    color: AppColors.secondaryText(isDark),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (item.showDivider)
          Divider(
            height: 1,
            indent: 68,
            color: AppColors.secondaryText(isDark).withOpacity(0.2),
          ),
      ],
    );
  }
}

class SettingsSectionWidget extends StatelessWidget {
  final SettingsSection section;
  final bool isDark;

  const SettingsSectionWidget({
    super.key,
    required this.section,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLarge,
            AppConstants.paddingLarge,
            AppConstants.paddingLarge,
            AppConstants.paddingSmall,
          ),
          child: Text(
            section.title.toUpperCase(),
            style: TextStyle(
              color: AppColors.secondaryText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        AppCard(
          backgroundColor: AppColors.cardBackground(isDark),
          padding: EdgeInsets.zero,
          child: Column(
            children: section.items.map((item) => 
              SettingsTile(item: item, isDark: isDark)
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class ThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const ThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: isDark,
      onChanged: onChanged,
      activeColor: AppColors.accent,
      activeTrackColor: AppColors.accent.withOpacity(0.3),
      inactiveThumbColor: AppColors.secondaryText(isDark),
      inactiveTrackColor: AppColors.secondaryText(isDark).withOpacity(0.2),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.cardBackground(isDark),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.softPeach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TikBoost User',
                  style: TextStyle(
                    color: AppColors.primaryText(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'user@tikboost.com',
                  style: TextStyle(
                    color: AppColors.secondaryText(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_rounded,
            color: AppColors.secondaryText(isDark),
            size: AppConstants.iconMedium,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'common_widgets.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      border: notification.isUrgent 
          ? Border.all(color: AppColors.accent, width: 1) 
          : null,
      child: Row(
        children: [
          IconContainer(
            icon: notification.icon,
            iconColor: notification.color,
            backgroundColor: notification.color.withOpacity(0.2),
            size: AppConstants.iconLarge,
            padding: AppConstants.paddingMedium,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                AppButton(
                  text: notification.actionText,
                  onPressed: notification.onAction,
                  backgroundColor: notification.color.withOpacity(0.2),
                  textColor: notification.color,
                  isOutlined: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(
                              Icons.image_rounded,
                              color: AppColors.secondaryText(Theme.of(context).brightness == Brightness.dark),
                              size: 40,
                            ),
                      ),
                    )
                  : Icon(
                      Icons.image_rounded,
                      color: AppColors.secondaryText(Theme.of(context).brightness == Brightness.dark),
                      size: 40,
                    ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (product.discountPercentage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: Text(
                            product.discountPercentage!,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      if (product.formattedOriginalPrice != null)
                        Text(
                          product.formattedOriginalPrice!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (product.rating > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: AppConstants.iconSmall,
                        ),
                        Text(
                          product.rating.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductBundleCard extends StatelessWidget {
  final ProductBundle bundle;
  final VoidCallback? onTap;

  const ProductBundleCard({
    super.key,
    required this.bundle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gradient: LinearGradient(colors: AppColors.greenPeachGradient),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconContainer(
                  icon: Icons.inventory_2_rounded,
                  iconColor: AppColors.mutedGreen,
                  backgroundColor: AppColors.mutedGreen.withOpacity(0.3),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Text(
                    bundle.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: const Text(
                    'BUNDLE',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (bundle.description.isNotEmpty)
              Text(
                bundle.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                Text(
                  bundle.formattedBundlePrice,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  bundle.formattedTotalPrice,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    'Save ${bundle.formattedSavings}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

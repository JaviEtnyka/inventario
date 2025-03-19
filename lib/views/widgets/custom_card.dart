// views/widgets/custom_card.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  
  const CustomCard({
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      elevation: 2,
      color: color ?? AppTheme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  
  const InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.captionStyle,
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.titleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
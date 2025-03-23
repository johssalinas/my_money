import 'package:flutter/material.dart';
import 'package:my_money/shared/theme/app_theme.dart';

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final bool isLoading;
  final ButtonSize size;
  final IconData? icon;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.icon,
    this.width,
    this.borderRadius = 10,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir tamaños predeterminados
    final sizeMap = {
      ButtonSize.small: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ButtonSize.medium: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ButtonSize.large: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    };

    final buttonPadding = padding ?? sizeMap[size];
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final btnTextColor = textColor ?? Colors.white;

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bgColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: buttonPadding,
          ),
          child: _buildContent(context, bgColor, btnTextColor),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: btnTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: buttonPadding,
        ),
        child: _buildContent(context, bgColor, btnTextColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color bgColor, Color txtColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            isOutlined ? bgColor : txtColor,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isOutlined ? bgColor : txtColor, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isOutlined ? bgColor : txtColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: isOutlined ? bgColor : txtColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
} 
import 'package:flutter/material.dart';

import '../color.dart';
import '../typography.dart';

class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool disabled;
  final Gradient? gradient;
  final Color textColor;
  final Color textColorDisabled;
  final Size? maximumSize;
  final Color backgroundColor;
  final Color disabledColor;
  final Size? minimumSize;
  final Border? border;

  const CustomButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.disabled = false,
    this.gradient,
    this.textColor = textButtonPrimary,
    this.textColorDisabled = textDisabled,
    this.maximumSize,
    this.minimumSize,
    this.backgroundColor = bgButtonPrimaryDefault,
    this.border,
    this.disabledColor = bgDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: border,
      ),
      child: Material(
        color: onPressed != null ? backgroundColor : disabledColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed != null
              ? () {
            /// Dismiss keyboard
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed!();
          }
              : null,
          child: Container(
            decoration: const BoxDecoration(color: Colors.transparent),
            child: DefaultTextStyle.merge(
              style: mMedium.copyWith(color: onPressed != null ? textColor : textColorDisabled),
              textAlign: TextAlign.center,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
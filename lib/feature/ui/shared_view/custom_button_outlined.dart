import 'package:flutter/material.dart';
import '../color.dart';
import '../typography.dart';

class CustomButtonOutline extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool disabled;
  final Gradient? gradient;
  final Color? textColor;
  final Size? maximumSize;
  final Color backgroundColor;
  final Color disabledColor;
  final Size? minimumSize;
  final Border? border;

  const CustomButtonOutline({
    Key? key,
    required this.child,
    this.onPressed,
    this.disabled = false,
    this.gradient,
    this.textColor,
    this.maximumSize,
    this.minimumSize,
    this.backgroundColor = bgButtonPrimaryDefault,
    this.border,
    this.disabledColor = bgDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          splashColor: bgButtonPrimaryDefault,
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed != null
              ? () {
            /// Dismiss keyboard
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed!();
          }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: DefaultTextStyle.merge(
                style: smMedium.copyWith(color: textColor),
                textAlign: TextAlign.center,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
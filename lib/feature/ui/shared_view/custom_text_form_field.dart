import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../color.dart';
import '../dimension.dart';
import '../typography.dart';


class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.titleSection,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.placeholder,
    this.errorText,
    this.prefixText,
    this.focusNode,
    this.obsecureText,
    this.validator,
    this.helper,
    this.helperText,
    this.onChanged,
    this.onSubmit,
    this.suffixIcon,
    this.maxLines,
    this.minLines,
    this.defaultValue,
    this.enabled,
    this.hintColor,
    this.onTap,
    this.inputFormatters,
    this.prefix,
    this.textValidator,
    this.prefixIcon,
    this.textInputAction,
    this.readOnly,
    this.suffixIconConstraints,
    this.subtitleSection,
    this.backgroundColor,
    this.suffixWidget
  });

  final String? titleSection;
  final String? subtitleSection;
  final BoxConstraints? suffixIconConstraints;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? defaultValue;
  final String? placeholder;
  final String? errorText;
  final String? prefixText;
  final Widget? helper;
  final String? helperText;
  final FocusNode? focusNode;
  final bool? obsecureText;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final String? Function(String)? validator;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final void Function()? onTap;
  final Color? hintColor;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final String? textValidator;
  final TextInputAction? textInputAction;
  final bool? readOnly;
  final Color? backgroundColor;
  final Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    const inputStyle = TextStyle(
      fontSize: 14,
    );
    if (defaultValue != null) {
      controller.text = defaultValue!;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (titleSection != null && titleSection!.isNotEmpty)
              Text(
                titleSection!,
                style: const TextStyle(
                  // color: black50,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (subtitleSection != null && subtitleSection!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: space250),
                child: Text(
                  subtitleSection!,
                  style: xsRegular.copyWith(color: textNeutralSecondary),
                ),
              ),
          ],
        ),
        const SizedBox(height: space150),
        TextFormField(
          readOnly: readOnly ?? false,
          onTap: onTap,
          textInputAction: textInputAction ?? TextInputAction.next,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obsecureText ?? false,
          style: inputStyle,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          onFieldSubmitted: onSubmit,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: hintColor ?? Colors.grey.shade600),
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: bg),
            prefix: prefix,
            prefixIcon: prefixIcon,
            suffixIcon: suffixWidget,
            suffixIconConstraints: suffixIconConstraints,
            errorText: validator == null ? null : errorText,
            enabled: true,
            fillColor: backgroundColor,
            filled: true,
            border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius200), // Sesuaikan radius sesuai kebutuhan
            borderSide: BorderSide(color: bgFillNeutral.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius200), // Sesuaikan radius sesuai kebutuhan
            borderSide: BorderSide(color: bgFillNeutral.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius200), // Sesuaikan radius sesuai kebutuhan
            borderSide: BorderSide(color: bgFillNeutral.withOpacity(0.4)),
          ),
          ),
          validator: (input) {
            if (validator != null) {
              return validator!(input ?? "");
            }
            return null;
          },
          onChanged: onChanged,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
        if (helper != null || helperText != null) const SizedBox(height: 6),
        _generateHelper(),
      ],
    );
  }

  Widget _generateHelper() {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontSize: 12,
      height: 1.6,
    );

    if (helper != null) {
      return DefaultTextStyle.merge(
        style: textStyle,
        child: helper!,
      );
    } else {
      return Text(helperText ?? "", style: textStyle);
    }
  }
}

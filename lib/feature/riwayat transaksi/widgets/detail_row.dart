import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? trailing;
  final bool isBold;

  const DetailRow({
    Key? key,
    required this.label,
    this.value,
    this.trailing,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}

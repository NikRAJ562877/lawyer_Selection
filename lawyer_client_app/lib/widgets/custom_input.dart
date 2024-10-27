import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller; // Required controller
  final VoidCallback? onPressed; // Optional onPressed function
  final bool obscureText;

  const CustomInput({
    required this.label,
    required this.controller, // Require controller
    this.onPressed,
    this.obscureText = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter your $label',
          ),
        ),
        const SizedBox(height: 10),
        if (onPressed != null)
          ElevatedButton(
            onPressed: onPressed,
            child: Text(label),
          ),
      ],
    );
  }
}

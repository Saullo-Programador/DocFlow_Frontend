import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CustomInput({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.onChanged,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          textInputAction: textInputAction,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            prefixIconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
            suffixIconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            suffixIcon: isPassword
                ? IconButton( 
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : null,

            filled: true,
            fillColor: Theme.of(context).colorScheme.background.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    required this.icon,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outline.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          filled: true,
          fillColor: scheme.surfaceBright,
          hintText: hintText,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: scheme.primary, size: 20),
        ),
      ),
    );
  }
}

class MyTextFields extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;

  const MyTextFields({
    super.key,
    required this.icon,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outline.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          filled: true,
          fillColor: scheme.surfaceBright,
          hintText: hintText,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: scheme.primary, size: 20),
        ),
      ),
    );
  }
}

class MyTextFieldSearch extends StatelessWidget {
  final IconData icon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final VoidCallback? onPrefixTap;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const MyTextFieldSearch({
    super.key,
    required this.icon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onPrefixTap,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        onTap: onTap,
        onChanged: onChanged,
        readOnly: onTap != null,
        style: TextStyle(color: scheme.onSurface, fontSize: 15),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: scheme.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
          filled: true,
          fillColor: scheme.surfaceBright,
          hintText: hintText,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.6)),
          prefixIcon: onPrefixTap == null
              ? Icon(icon, color: scheme.onSurfaceVariant, size: 20)
              : IconButton(
                  icon: Icon(icon, color: scheme.onSurfaceVariant, size: 20),
                  onPressed: onPrefixTap,
                ),
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
                  icon: Icon(suffixIcon, color: scheme.primary, size: 20),
                  onPressed: onSuffixTap,
                ),
        ),
      ),
    );
  }
}

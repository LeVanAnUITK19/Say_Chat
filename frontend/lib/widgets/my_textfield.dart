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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class MyTextFieldSearch extends StatelessWidget {
  final IconData icon;
  final IconData? suffixIcon; // 👈 icon bên phải
  final VoidCallback? onSuffixTap; // 👈 sự kiện bấm suffix
  final VoidCallback? onPrefixTap; // 👈 sự kiện bấm prefix (icon trái)
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,

        obscureText: obscureText,
        onTap: onTap,
        onChanged: onChanged,
        readOnly: onTap != null,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primaryContainer,

          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          /// ICON TRÁI
          prefixIcon: onPrefixTap == null
              ? Icon(icon, color: Theme.of(context).colorScheme.primary)
              : IconButton(
                  icon: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onPrefixTap,
                ),

          /// ICON PHẢI 👇
          suffixIcon: suffixIcon == null
              ? null
              : IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onSuffixTap,
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CommonTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final Function(String) onChanged;

  CommonTextField({
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    required this.onChanged,
  });

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText =
        widget.obscureText; // Initialize with the passed obscureText value
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      controller: widget.controller,
      obscureText: _obscureText, // Toggle obscureText based on the state
      decoration: InputDecoration(
        labelText: widget.labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget
                .obscureText // Only show icon if the field is a password field
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText; // Toggle visibility
                  });
                },
              )
            : null, // If not password, don't show suffix icon
      ),
    );
  }
}

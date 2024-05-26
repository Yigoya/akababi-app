import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String hint;
  final void Function() fun;
  final TextEditingController controller;

  const PasswordTextField(
      {Key? key,
      required this.controller,
      required this.hint,
      required this.fun})
      : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  int strength = 0;
  bool showRules = false;
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 15, right: 0),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                )
              ],
              border:
                  Border.all(color: Colors.black.withOpacity(0.7), width: 1),
              borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: widget.controller,
            obscureText: obscureText,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 15),
              hintText: widget.hint,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getStrengthIcon(strength),
                  IconButton(
                    icon: Icon(
                      showRules ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                    onPressed: () => setState(() => showRules = !showRules),
                  ),
                  IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => obscureText = !obscureText),
                  ),
                ],
              ),
            ),
            onChanged: (value) {
              setState(() {
                strength = _calculatePasswordStrength(value);
              });
            },
          ),
        ),
        showRules ? _buildPasswordRules() : const SizedBox(),
      ],
    );
  }

  Icon _getStrengthIcon(int strength) {
    if (strength < 3) {
      return const Icon(Icons.warning, color: Colors.red);
    } else if (strength < 4) {
      return const Icon(Icons.security, color: Colors.orange);
    } else {
      // widget.fun();
      return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  Widget _buildPasswordRules() {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password Rules:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text("- At least 8 characters long"),
              Text("- At least one lowercase letter (a-z)"),
              Text("- At least one uppercase letter (A-Z)"),
              Text("- At least one number (0-9)"),
              Text("- At least one special character (!@#\$%^&*)"),
            ],
          ),
        ),
      ),
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) {
      strength++;
    }
    if (password.contains(RegExp(r'[a-z]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[A-Z]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[!@#$%^&*()]'))) {
      strength++;
    }
    return strength;
  }
}

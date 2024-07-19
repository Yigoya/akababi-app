import 'package:flutter/material.dart';

/// A custom text field widget for entering passwords.
class PasswordTextField extends StatefulWidget {
  final String hint;
  final void Function() fun;
  final TextEditingController controller;

  /// Creates a [PasswordTextField] widget.
  ///
  /// The [controller], [hint], and [fun] parameters are required.
  const PasswordTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.fun,
  }) : super(key: key);

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
          padding: const EdgeInsets.only(left: 15, right: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.black.withOpacity(0.7),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: obscureText,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: const TextStyle(fontSize: 15),
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

  /// Returns an [Icon] based on the strength of the password.
  ///
  /// The strength parameter represents the strength of the password, with a value
  /// less than 3 indicating a weak password, a value less than 5 indicating a
  /// moderate password, and any other value indicating a strong password.
  ///
  /// Returns an [Icon] widget with different colors based on the strength of the
  /// password. A strength less than 3 will return a warning icon with red color,
  /// a strength less than 5 will return a security icon with orange color, and
  /// any other strength will return a check circle icon with green color.
  Icon _getStrengthIcon(int strength) {
    if (strength < 3) {
      return const Icon(Icons.warning, color: Colors.red);
    } else if (strength < 5) {
      return const Icon(Icons.security, color: Colors.orange);
    } else {
      // widget.fun();
      return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  /// Builds a widget that displays password rules.
  ///
  /// This method returns a [Container] widget containing a [Card] widget with padding.
  /// Inside the [Card], a [Column] widget is used to display the password rules.
  /// The rules include:
  /// - At least 8 characters long
  /// - At least one lowercase letter (a-z)
  /// - At least one uppercase letter (A-Z)
  /// - At least one number (0-9)
  /// - At least one special character (!@#\$%^&*)
  ///
  /// Returns:
  ///   A widget that displays password rules.
  Widget _buildPasswordRules() {
    return Container(
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Password Rules:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
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

  /// Calculates the strength of a password based on certain criteria.
  ///
  /// The strength of the password is determined by the following criteria:
  /// - The password length should be at least 8 characters.
  /// - The password should contain at least one lowercase letter.
  /// - The password should contain at least one uppercase letter.
  /// - The password should contain at least one digit.
  /// - The password should contain at least one special character.
  ///
  /// Returns the strength of the password as an integer value.
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
    if (password
        .contains(RegExp(r'''[!@#$%^&*(),.?":{}|<>+÷_=[\];\-\\\/`~']'''))) {
      strength++;
    }
    return strength;
  }
}

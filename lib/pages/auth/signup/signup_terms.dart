import 'package:akababi/pages/auth/signup/signup_profile_picture.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to add this package in pubspec.yaml

class SignUpTermsPage extends StatelessWidget {
  const SignUpTermsPage({Key? key}) : super(key: key);

  // Method to open links
  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Agree to Akababi’s terms and policies",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            const Text(
              "People who use our service may have uploaded your contact information to Akababi.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ),
            InkWell(
              onTap: () => _launchURL("https://www.facebook.com/help/"),
              child: const Text(
                "Learn more",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text:
                          "By tapping I agree, you agree to create an account and to Akababi's "),
                  TextSpan(
                    text: "terms",
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/terms"),
                  ),
                  const TextSpan(text: ", "),
                  TextSpan(
                    text: "Privacy Policy",
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/policy"),
                  ),
                  const TextSpan(text: " and "),
                  TextSpan(
                    text: "Cookies Policy",
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/cookies"),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  const TextSpan(
                      text:
                          "The Privacy Policy describes the ways we can use the information we collect when you create an account. For example, we use this information to provide, personalise and improve our products, including ads."),
                  TextSpan(
                    text: " Privacy Policy",
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/policy"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CommonButton(
              buttonText: "I Agree",
              onPressed: () {
                // Handle save action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePicturePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CommonButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const CommonButton(
      {super.key, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}

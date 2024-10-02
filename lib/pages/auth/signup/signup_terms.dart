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
            Text(
              "Agree to Akababi’s terms and policies",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 20),
            Text(
              "People who use our service may have uploaded your contact information to Akababi.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ),
            InkWell(
              onTap: () => _launchURL("https://www.facebook.com/help/"),
              child: Text(
                "Learn more",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                      text:
                          "By tapping I agree, you agree to create an account and to Akababi's "),
                  TextSpan(
                    text: "terms",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/terms"),
                  ),
                  TextSpan(text: ", "),
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/policy"),
                  ),
                  TextSpan(text: " and "),
                  TextSpan(
                    text: "Cookies Policy",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/cookies"),
                  ),
                  TextSpan(text: "."),
                ],
              ),
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                      text:
                          "The Privacy Policy describes the ways we can use the information we collect when you create an account. For example, we use this information to provide, personalise and improve our products, including ads."),
                  TextSpan(
                    text: " Privacy Policy",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL("https://www.facebook.com/policy"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            CommonButton(
              buttonText: "I Agree",
              onPressed: () {
                // Handle save action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePicturePage(),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Center(
              child: InkWell(
                onTap: () {
                  // Handle "I already have an account" action
                },
                child: Text(
                  "I already have an account",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
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

  CommonButton({required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}

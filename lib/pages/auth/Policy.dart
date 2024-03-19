import 'package:flutter/material.dart';

class Policy extends StatelessWidget {
  Policy({super.key});
  final titles = [
    "Platform User Agreement",
    "1. Acceptance of Terms",
    "2. User Conduct",
    "3. Account Registration",
    "4. Content",
    "5. Intellectual Property",
    "6. Privacy",
    "7. Limitation of Liability",
    "8. Termination",
    "9. Changes to Terms",
  ];

  final bodys = [
    "Welcome to AKABABI! Before you start using our platform, it's important to understand and agree to the following terms and policies. By accessing or using our platform, you acknowledge that you have read, understood, and agree to be bound by these terms and policies. If you do not agree with any part of these terms, then you may not access the platform.",
    "By accessing or using our platform, you agree to be bound by these Terms of Service, our Privacy Policy, and any other policies or guidelines posted on the platform. These terms constitute a legally binding agreement between you and AKABABI.",
    "You agree to use the platform in compliance with all applicable laws, regulations, and these terms. You agree not to engage in any activity that interferes with or disrupts the platform's functionality or security, or that infringes upon the rights of others.",
    "In order to access certain features of the platform, you may be required to create an account. You agree to provide accurate and complete information during the registration process, and to keep your account information up-to-date at all times.",
    "You are solely responsible for any content that you post, upload, or otherwise make available on the platform. You agree not to post any content that is illegal, obscene, defamatory, or otherwise objectionable. AKABABI reserves the right to remove any content that violates these terms or is otherwise inappropriate.",
    "All content and materials available on the platform, including but not limited to text, graphics, logos, images, and software, are the property of AKABABI or its licensors and are protected by copyright, trademark, and other intellectual property laws. You agree not to reproduce, modify, or distribute any such content without the express written consent of AKABABI.",
    "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and disclose information about you.",
    "In no event shall AKABABI be liable for any direct, indirect, incidental, special, or consequential damages arising out of or in any way connected with your use of the platform, whether based on contract, tort, strict liability, or any other legal theory.",
    "AKABABI reserves the right to suspend or terminate your access to the platform at any time, for any reason, without prior notice or liability.",
    "AKABABI reserves the right to update or modify these terms at any time without prior notice. Your continued use of the platform after any such changes constitutes your acceptance of the new terms.",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("TERMS AND CONDITIONS"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: ListView.builder(
              itemCount: bodys.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Titles(titles[index]),
                    body(bodys[index]),
                    SizedBox(
                      height: 20,
                    )
                  ],
                );
              }),
        ));
  }

  Widget Titles(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
    );
  }

  Widget body(String text) {
    return Text(text);
  }
}

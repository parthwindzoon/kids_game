import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForParentsPage extends StatelessWidget {
  const ForParentsPage({super.key});

  final String policyUrl = "https://thelearnberry.com/kids-privacy-policy"; // <-- CHANGE THIS

  void _openPolicy() async {
    final uri = Uri.parse(policyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final double fontSize = isTablet ? 22 : 16;
    final double titleSize = isTablet ? 30 : 22;
    final double spacing = isTablet ? 20 : 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text("For Parents"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
        child: ListView(
          children: [
            Text(
              "Advertising Information for Parents",
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing),

            Text(
              "This app may display limited third-party contextual ads to help support development. "
                  "We do NOT show personalized or interest-based ads, and we do not collect personal "
                  "information from children for advertising purposes.",
              style: TextStyle(fontSize: fontSize),
            ),
            SizedBox(height: spacing),

            Text(
              "Child-Safe Ad Settings",
              style: TextStyle(
                fontSize: titleSize - 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing / 2),

            Text(
              "• All ads are configured as child-directed.\n"
                  "• Ads are strictly non-personalized.\n"
                  "• We block categories unsuitable for children (violence, gambling, dating, drugs, alcohol, adult content).\n"
                  "• We review ad categories and creatives to maintain appropriateness.\n",
              style: TextStyle(fontSize: fontSize),
            ),

            SizedBox(height: spacing),

            Text(
              "Full Kids Advertising Policy",
              style: TextStyle(
                fontSize: titleSize - 4,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: spacing / 2),

            Text(
              "For full details about how ads are handled in this child-directed app, please review "
                  "our Kids Advertising Policy available on our website:",
              style: TextStyle(fontSize: fontSize),
            ),

            SizedBox(height: spacing),

            ElevatedButton(
              onPressed: _openPolicy,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 20 : 14,
                  horizontal: isTablet ? 30 : 20,
                ),
              ),
              child: Text(
                "Open Kids Advertising Policy",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: spacing * 2),

            Text(
              "Contact",
              style: TextStyle(
                fontSize: titleSize - 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing / 2),

            Text(
              "If you ever see an ad that seems inappropriate for children, please report it to us:",
              style: TextStyle(fontSize: fontSize),
            ),

            SizedBox(height: spacing / 2),

            Text(
              "Email: info@windzoon.com",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

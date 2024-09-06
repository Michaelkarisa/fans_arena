import 'package:flutter/material.dart';
class AboutTheApp extends StatefulWidget {
  const AboutTheApp({super.key});

  @override
  State<AboutTheApp> createState() => _AboutTheAppState();
}

class _AboutTheAppState extends State<AboutTheApp> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About the app',style:TextStyle(color: Colors.black) ),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: InkWell(
                onTap: (){ Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicy(),
                  ),
                );},
                child: Container(
                  height: 50,
                  color: Colors.grey[200],
                  width: MediaQuery.of(context).size.width,
                  child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Privacy policy')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: InkWell(
                onTap: (){ Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TermsOfUse(),
                  ),
                );},
                child: Container(
                  height: 50,
                  color: Colors.grey[200],
                  width: MediaQuery.of(context).size.width,
                  child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Terms of use')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: InkWell(
                onTap: (){ Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Updates(),
                  ),
                );},
                child: Container(
                  height: 50,
                  color: Colors.grey[200],
                  width: MediaQuery.of(context).size.width,
                  child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Updates')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We value your privacy and are committed to protecting your personal information. This policy outlines how we collect, use, and safeguard your data when you use our application.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '2. Information We Collect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We may collect personal information such as your name, email address, and other details you provide when using our services. We may also collect usage data and analytics to improve our application.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '3. How We Use Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your information is used to provide and enhance our services, communicate with you, and ensure the security of our application. We may also use your information for research and analytics purposes.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '4. Sharing Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We do not share your personal information with third parties except as required by law or with your consent. We may share aggregated and anonymized data for research purposes.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '5. Data Security',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We implement appropriate security measures to protect your data from unauthorized access, alteration, or disclosure. However, no method of transmission over the internet is completely secure.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '6. Your Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'You have the right to access, correct, or delete your personal information. You may also opt-out of certain data collection practices. Please contact us to exercise your rights.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '7. Changes to This Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We may update this privacy policy from time to time. Any changes will be posted on this page, and we encourage you to review this policy periodically.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '8. Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'If you have any questions about this privacy policy or our data practices, please contact us at support@example.com.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsOfUse extends StatefulWidget {
  const TermsOfUse({super.key});

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introduction',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Welcome to Fans Arena, a platform that allows users to stream and view online content, including but not limited to video, audio, and live broadcasts. By accessing or using the App, you agree to comply with and be bound by these Terms of Use (“Terms”). If you do not agree to these Terms, please do not use the App.',
              ),
              SizedBox(height: 16),
              Text(
                '1. Acceptance of Terms',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'By creating an account, accessing, or using the App, you agree to these Terms and any additional terms, policies, and guidelines that the App may provide from time to time. You also acknowledge that you are of legal age to enter into these Terms or have obtained permission from a legal guardian.',
              ),
              SizedBox(height: 16),
              Text(
                '2. Changes to the Terms',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'We reserve the right to modify or revise these Terms at any time. Any changes will be effective immediately upon posting the revised Terms. Your continued use of the App after any such changes constitutes your acceptance of the new Terms.',
              ),
              SizedBox(height: 16),
              Text(
                '3. User Accounts',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                '- Account Creation: To access certain features of the App, you may be required to create an account. You are responsible for maintaining the confidentiality of your account and password and for all activities that occur under your account.\n\n'
                    '- Account Information: You agree to provide accurate and complete information when creating your account and to update your information to keep it accurate and complete.\n\n'
                    '- Account Termination: We reserve the right to suspend or terminate your account at our discretion if you violate any part of these Terms or for any other reason.',
              ),
              SizedBox(height: 16),
              Text(
                '4. Use of the App',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                '- License: We grant you a limited, non-exclusive, non-transferable, and revocable license to access and use the App for personal and non-commercial purposes, subject to these Terms.\n\n'
                    '- Prohibited Conduct: You agree not to use the App to:\n'
                    '  - Violate any laws or regulations.\n'
                    '  - Post or transmit any content that is unlawful, defamatory, obscene, or otherwise objectionable.\n'
                    '  - Engage in any activity that could interfere with or disrupt the App or the servers and networks connected to the App.\n'
                    '  - Impersonate any person or entity or misrepresent your affiliation with any person or entity.',
              ),
              SizedBox(height: 16),
              Text(
                '5. Content Ownership and Rights',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                '- User-Generated Content: By uploading, posting, or otherwise making available any content on the App, you grant us a worldwide, non-exclusive, royalty-free, sublicensable, and transferable license to use, reproduce, distribute, prepare derivative works of, display, and perform the content in connection with the App and our business.\n\n'
                    '- App Content: All content provided by the App, including but not limited to text, graphics, logos, and software, is the property of [Application Name] or its content suppliers and is protected by copyright and other intellectual property laws. You may not reproduce, distribute, or create derivative works from the content without our express written permission.',
              ),
              SizedBox(height: 16),
              Text(
                '6. Privacy Policy',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Your use of the App is also governed by our Privacy Policy, which explains how we collect, use, and disclose information about you. By using the App, you agree to our Privacy Policy.',
              ),
              SizedBox(height: 16),
              Text(
                '7. Termination',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'We may terminate or suspend your access to the App, with or without notice, for any reason, including if you violate these Terms. Upon termination, your right to use the App will immediately cease, and we may delete your account and any content you have provided.',
              ),
              SizedBox(height: 16),
              Text(
                '8. Limitation of Liability',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'To the fullest extent permitted by law, Fans Arena and its affiliates, officers, directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from:\n'
                    '  - Your access to or use of or inability to access or use the App.\n'
                    '  - Any unauthorized access to or use of our servers and/or any personal information stored therein.\n'
                    '  - Any interruption or cessation of transmission to or from the App.',
              ),
              SizedBox(height: 16),
              Text(
                '9. Indemnification',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'You agree to indemnify and hold Fans Arena and its affiliates, officers, directors, employees, and agents harmless from and against any claims, liabilities, damages, losses, and expenses, including without limitation reasonable legal and accounting fees, arising out of or in any way connected with your access to or use of the App, your violation of these Terms, or your infringement of any third-party rights.',
              ),
              SizedBox(height: 16),
              Text(
                '10. Governing Law',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'These Terms shall be governed by and construed in accordance with the laws of Kenya, without regard to its conflict of law principles. You agree to submit to the exclusive jurisdiction of the courts located within Kenya to resolve any legal matter arising from these Terms or your use of the App.',
              ),
              SizedBox(height: 16),
              Text(
                '11. Contact Information',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'If you have any questions about these Terms, please email us at fansarenakenya@gmail.com, or visit us on www.fansarenakenya.site.',
              ),
              SizedBox(height: 16),
              Text(
                '12. Miscellaneous',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                '- Entire Agreement: These Terms, along with our Privacy Policy, constitute the entire agreement between you and Fans Arena regarding your use of the App.\n\n'
                    '- Waiver and Severability: The failure of Fans Arena to enforce any right or provision of these Terms shall not constitute a waiver of such right or provision. If any provision of these Terms is held to be invalid or unenforceable, the remaining provisions of these Terms will remain in full force and effect.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Updates extends StatefulWidget {
  const Updates({super.key});

  @override
  State<Updates> createState() => _UpdatesState();
}

class _UpdatesState extends State<Updates> {
  bool _notifyUpdates = false;

  void _toggleNotification(bool value) {
    setState(() {
      _notifyUpdates = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Updates',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Container(
          height: 60,
          color: Colors.grey[200],
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child:   SwitchListTile(
              title: const Text('Notify when updates are available'),
              value: _notifyUpdates,
              onChanged: _toggleNotification,
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_app/core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String routeName = '/privacy-policy';

  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSection(
              context,
              title: 'Information We Collect',
              content: _getInformationWeCollectContent(),
            ),
            _buildSection(
              context,
              title: 'Device Security',
              content: _getDeviceSecurityContent(),
              isHighlight: true,
            ),
            _buildSection(
              context,
              title: 'How We Use Your Information',
              content: _getHowWeUseContent(),
            ),
            _buildSection(
              context,
              title: 'Information Sharing',
              content: _getInformationSharingContent(),
            ),
            _buildSection(
              context,
              title: 'Data Security',
              content: _getDataSecurityContent(),
            ),
            _buildSection(
              context,
              title: 'Your Rights',
              content: _getYourRightsContent(),
            ),
            _buildSection(
              context,
              title: 'Contact Us',
              content: _getContactContent(),
            ),
            const SizedBox(height: 32),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.privacy_tip,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: textDark,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last updated: 2025-06-7', // Update this when privacy policy changes
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textLight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ExamHub is committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our exam preparation application.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textDark,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(color: primaryColor.withOpacity(0.2))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isHighlight)
                Icon(
                  Icons.security,
                  color: primaryColor,
                  size: 20,
                ),
              if (isHighlight) const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isHighlight ? primaryColor : textDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textDark,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school,
            color: primaryColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'ExamHub',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trusted partner in exam preparation',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getInformationWeCollectContent() {
    return '''We collect the following types of information to provide you with the best exam preparation experience:

• Personal Information: Name, email address, phone number, and educational institution details
• Academic Information: Your chosen exam type, subject preferences, and study progress
• Usage Data: How you interact with our app, including quiz performance and study patterns
• Technical Information: App version, operating system, and basic device information for compatibility

All information is collected with your explicit consent and is used solely to enhance your learning experience.''';
  }

  String _getDeviceSecurityContent() {
    return '''🔒 Device ID for Security Only

We want to be completely transparent about our use of your device identifier (Device ID):

• Purpose: We collect your device ID EXCLUSIVELY for security purposes
• Security Use: To prevent unauthorized access and protect your account from fraud
• Account Protection: To ensure only you can access your exam progress and personal data
• No Advertising: We DO NOT use your device ID for advertising, marketing, or tracking purposes
• No Sharing: Your device ID is never shared with third parties or advertising networks
• Secure Storage: Device IDs are encrypted and stored securely in our protected systems
• Data Retention: Device IDs are retained only as long as your account is active

Your device ID helps us maintain the integrity and security of your account while ensuring your privacy is fully protected.''';
  }

  String _getHowWeUseContent() {
    return '''We use your information for the following legitimate purposes:

• Educational Services: To provide personalized exam preparation content and track your progress
• Account Management: To create and maintain your user account and preferences
• Communication: To send important updates about your studies and app improvements
• Support: To provide customer service and technical assistance when needed
• Analytics: To improve our app performance and develop better study features
• Security: To protect against unauthorized access and maintain platform safety

We never use your personal information for purposes beyond what is necessary to provide our educational services.''';
  }

  String _getInformationSharingContent() {
    return '''We are committed to keeping your information private and secure:

• No Sale of Data: We never sell, rent, or trade your personal information to third parties
• Limited Sharing: Information is only shared with trusted service providers who help us operate the app
• Educational Purpose Only: Any data sharing is strictly limited to providing educational services
• Your Consent: We will always ask for your explicit consent before sharing information for new purposes
• Legal Requirements: We may disclose information only when required by law or to protect user safety

Your trust is important to us, and we maintain strict controls over how your information is handled.''';
  }

  String _getDataSecurityContent() {
    return '''We implement comprehensive security measures to protect your information:

• Encryption: All data is encrypted both in transit and at rest using industry-standard protocols
• Secure Servers: Your information is stored on secure servers with multi-layer protection
• Access Controls: Strict access controls ensure only authorized personnel can access user data
• Regular Audits: We conduct regular security audits and updates to maintain protection standards
• Privacy by Design: Our systems are built with privacy and security as fundamental principles

We continuously monitor and improve our security practices to keep your information safe.''';
  }

  String _getYourRightsContent() {
    return '''You have full control over your personal information:

• Access: You can request a copy of all personal information we have about you
• Correction: You can update or correct any inaccurate information in your profile
• Deletion: You can request deletion of your account and all associated data
• Portability: You can request your data in a portable format to transfer elsewhere
• Withdrawal: You can withdraw consent for data processing at any time
• Objection: You can object to certain types of data processing

To exercise any of these rights, please contact us using the information provided below.''';
  }

  String _getContactContent() {
    return '''If you have any questions about this Privacy Policy or our data practices, please don't hesitate to contact us:

• Email: privacy@examhub.et
• Phone: +251-940855439
• Address: Addis Ababa, Ethiopia

We are committed to addressing your privacy concerns promptly and transparently. Your privacy matters to us, and we're here to help with any questions you may have.''';
  }
}

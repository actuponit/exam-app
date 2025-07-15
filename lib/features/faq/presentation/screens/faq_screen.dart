import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQCategory> _categories = [
    FAQCategory(
      title: 'General App Usage',
      faqs: [
        FAQ(
          question: 'What is this app used for?',
          answer:
              'Ethio Exam Hub helps students access past exam papers for Grade 8 and university first-year freshman courses to prepare effectively.',
        ),
        FAQ(
          question: 'How do I use the app?',
          answer:
              'Go to the Home screen, choose a subject,select year, filter by chapter or region and browse available past exams.',
        ),
        FAQ(
          question: 'How do I track my progress?',
          answer: 'Your practice history and performance are recorded.',
        ),
        FAQ(
          question: 'Are explanations provided for all questions?',
          answer:
              'Yes, every question includes a detailed explanation after answering — to help you learn better.',
        ),
        FAQ(
          question: 'Is an internet connection required?',
          answer:
              'Internet is needed to download or update exams. Once downloaded, you can access them offline.',
        ),
      ],
    ),
    FAQCategory(
      title: 'About Referral System',
      faqs: [
        FAQ(
          question: 'Can I earn rewards by referring friends?',
          answer:
              'Yes! Invite your friends to join Ethio Exam Hub using your referral code and earn rewards.',
        ),
        FAQ(
          question: 'How do I refer my friends?',
          answer:
              'Share your referral code. When friends use it during registration, it\'s automatically linked to you.',
        ),
        FAQ(
          question: 'Where can I find my referral code?',
          answer:
              'Your referral code is located in your Profile section — simply copy and share.',
        ),
        FAQ(
          question: 'How can I track my referrals?',
          answer:
              'In your profile, referrals are auto-counted. To take rewards, send a screenshot of your referral count to our Telegram support:@Ethio_exam_hub_support',
        ),
      ],
    ),
    FAQCategory(
      title: 'App Features',
      faqs: [
        FAQ(
          question: 'Is the content organized and easy to use?',
          answer:
              'Yes! Exams are well-structured by subject, year, and region.',
        ),
        FAQ(
          question: 'Are answer keys provided?',
          answer:
              'Most exams include answer keys, and more detailed solutions are being added.',
        ),
        FAQ(
          question: 'Are explanations provided for all questions?',
          answer: 'Yes — each question has an explanation after you answer it.',
        ),
        FAQ(
          question: 'Can I study offline?',
          answer:
              'Yes — once content is downloaded, you can access it without internet.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Exam Content',
      faqs: [
        FAQ(
          question: 'Where do the past exams come from?',
          answer:
              'Collected from official sources, regional exams, Freshman exams and teacher contributions.',
        ),
        FAQ(
          question: 'How are the questions organized?',
          answer: 'By year, subject, and chapter — easy to navigate and focus.',
        ),
        FAQ(
          question: 'Are the exams from trusted sources?',
          answer:
              '100%. All content is verified and sourced from official materials.',
        ),
        FAQ(
          question: 'How often is new content added?',
          answer: 'New exams are uploaded yearly as they become available.',
        ),
        FAQ(
          question: 'What subjects are available for 8th grade ministry exam?',
          answer: 'All major subjects relevant to Grade 8.',
        ),
        FAQ(
          question: 'Does this help with the Grade 8 regional exam?',
          answer:
              'Yes! It includes previous regional exams to prepare effectively.',
        ),
        FAQ(
          question: 'Are all regional exams included?',
          answer:
              'Absolutely — exams from all regions (Addis Ababa, Afar, Amhara, Benishangul-Gumuz, Central Ethiopia, Dire Dawa, Gambella, Harari, Oromia, Sidama, Somali, South Ethiopia, South West Ethiopia, Tigray.) are covered.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ',
          style: displayStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Frequently Asked Questions',
            style: displayStyle.copyWith(
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about using the app',
            style: bodyStyle.copyWith(
              color: textLight,
            ),
          ),
          const SizedBox(height: 24),
          ..._categories.map((category) => _buildCategory(category)).toList(),
        ],
      ),
    );
  }

  Widget _buildCategory(FAQCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          category.title,
          style: titleStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...category.faqs.map((faq) => _FAQExpansionCard(faq: faq)).toList(),
      ],
    );
  }
}

class _FAQExpansionCard extends StatefulWidget {
  final FAQ faq;

  const _FAQExpansionCard({required this.faq});

  @override
  State<_FAQExpansionCard> createState() => _FAQExpansionCardState();
}

class _FAQExpansionCardState extends State<_FAQExpansionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.5).chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    );
    _heightFactor = _controller.drive(
      CurveTween(curve: Curves.easeInOut),
    );
    _fadeAnimation = _controller.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(
          color:
              _isExpanded ? primaryColor.withOpacity(0.5) : Colors.grey[200]!,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: _handleExpansion,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: titleStyle.copyWith(
                        fontSize: 16,
                        color: _isExpanded ? primaryColor : textDark,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _isExpanded ? primaryColor : textLight,
                    ),
                  ),
                ],
              ),
            ),
            ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Align(
                    heightFactor: _heightFactor.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    widget.faq.answer,
                    style: bodyStyle.copyWith(
                      color: textLight,
                      height: 1.5,
                    ),
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

class FAQCategory {
  final String title;
  final List<FAQ> faqs;

  FAQCategory({
    required this.title,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}

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
      title: 'Getting Started',
      faqs: [
        FAQ(
          question: 'How do I start practicing?',
          answer:
              'To start practicing, go to the home screen and tap on "Practice" or select "Practice Exams" from the menu. Choose your subject and preferred exam year to begin.',
        ),
        FAQ(
          question: 'Can I practice specific subjects?',
          answer:
              'Yes! You can select specific subjects to practice. Navigate to the subject selection screen and choose the subject you want to focus on.',
        ),
        FAQ(
          question: 'How are the questions organized?',
          answer:
              'Questions are organized by year and subject. You can choose to practice questions from specific years or focus on particular subjects.',
        ),
      ],
    ),
    FAQCategory(
      title: 'Exam Practice',
      faqs: [
        FAQ(
          question: 'How long is each practice exam?',
          answer:
              'Each practice exam typically contains 75 questions and is designed to be completed in 2 hours and 30 minutes, matching the actual exam format.',
        ),
        FAQ(
          question: 'Can I review my answers?',
          answer:
              'Yes, after completing a practice exam, you can review all your answers. Each question will show the correct answer and a detailed explanation.',
        ),
        FAQ(
          question: 'Are the questions from real exams?',
          answer:
              'Yes, our questions are sourced from previous National Entrance Exams (EUEE) and are carefully verified for accuracy.',
        ),
      ],
    ),
    FAQCategory(
      title: 'App Features',
      faqs: [
        FAQ(
          question: 'Can I use the app offline?',
          answer:
              'Yes! Once you\'ve downloaded the content, you can use the app without an internet connection. All questions are stored locally on your device.',
        ),
        FAQ(
          question: 'How do I track my progress?',
          answer:
              'The app keeps track of your practice history and performance. You can view your progress and areas for improvement in your profile.',
        ),
        FAQ(
          question: 'Are explanations provided for all questions?',
          answer:
              'Yes, every question comes with a detailed explanation. After answering a question, you can view the explanation to understand the concept better.',
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

class _FAQExpansionCardState extends State<_FAQExpansionCard> with SingleTickerProviderStateMixin {
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
          color: _isExpanded ? primaryColor.withOpacity(0.5) : Colors.grey[200]!,
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
import 'package:flutter/material.dart';
import 'package:exam_app/core/theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About Us',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'Our Mission',
                    Icons.flag_outlined,
                    '''To make exam preparation simple, fair, and accessible for every student in Ethiopia — helping them score better💯, achieve their goals,  and succeed anywhere, anytime
🇪🇹 በኢትዮጵያ ለሚገኙ ሁሉም ተማሪዎች የፈተና ዝግጅትን ቀላል፣ ፍትሃዊ እና ተደራሽ በማድረግ—ግዜና ቦታ ሰይገድባቻው የተሻለ ውጤት እንዲያስመዘግቡ፣ ግባቸውን እንዲያሳኩ እና እንዲሳካላቸው መርዳት ነው!''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'What We Do',
                    Icons.school_outlined,
                    '''✅ Real past papers (Grade-8 & freshman exams)
✅ Verified answers with clear explanations
✅ Offline access & progress tracking
✅ Regular updates with new content''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Our Story',
                    Icons.history_outlined,
                    '''
Many students across Ethiopia miss out on opportunities — not because they lack potential, but because they don’t have access to the right previous exam materials. This unfair gap inspired us to take action.

📲Ethio Exam Hub was created to make exam preparation smarter, simpler, and more reliable for every student, no matter where they are.

✨ All content is carefully prepared by a team of top-performing students from different universities across Ethiopia — bringing together the best minds to support your success.

🇪🇹በሀገራችን በርካታ ተማሪዎች ዕድሎችን ያጣሉ — ይህ የሚሆነው ብቃት ስላነሳቸው ሳይሆን፣ ትክክለኛ ያላፋ ዓመታት የትምህርት ቁሳቁሶችን በአግባቡ ማግኘት ስለማይችሉ ነው። ይህ ፍትሃዊ ያልሆነ ክፍተት ይህን መተግበሪያ እንድናዘጋጅ አነሳስቶናል።

📲Ethio Exam - Hub የተዘጋጀው ፣ የትም ቦታ ላሉ ሁሉም ተማሪዎች የፈተና ዝግጅትን ይበልጥ ተደራሽነት ያለው፣ ቀላልና አስተማማኝ ለማድረግ ነው።

✨ ሁሉም ይዘቶች በኢትዮጵያ ከሚገኙ የተለያዩ ዩኒቨርሲቲዎች በተውጣጡ ምርጥ Top senior  ተማሪዎች ቡድን በጥንቃቄ የተዘጋጁ ስለሆነ —በመንገዱ ለማለፍ በመንገዱ ያለፉትን ጠይቅ እንደሚበለው ለስኬትዎ የአንበሳውን ድርሻ ይጋራል!''',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Our Values',
                    Icons.favorite_outline,
                    'Excellence: We strive for the highest quality in everything we do, from content creation to user experience.\n\nAccessibility: Education should be available to everyone, regardless of their background or circumstances.\n\nInnovation: We constantly seek new ways to improve learning outcomes through technology and pedagogical research.\n\nIntegrity: We maintain the highest ethical standards in all our practices and interactions.',
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Why Choose Us?',
                    Icons.star_outline,
                    'Comprehensive Content: Our extensive question bank covers all major subjects and exam formats.\n\nExpert-Crafted Questions: All content is created and reviewed by subject matter experts with years of teaching experience.\n\nPersonalized Learning: Advanced algorithms adapt to your learning pace and identify areas for improvement.\n\nReal-time Progress Tracking: Monitor your improvement with detailed analytics and performance insights.\n\nCommunity Support: Join a vibrant community of learners sharing tips, strategies, and encouragement.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, IconData icon, String content) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[200]!,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: bodyStyle.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

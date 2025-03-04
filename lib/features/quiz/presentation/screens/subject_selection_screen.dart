import 'package:exam_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// TEMPORARY SUBJECT CLASS - REMOVE LATER
class Subject {
  final String id;
  final String name;
  final IconData icon;  // Using Material Icons directly
  final double progress;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.progress,
  });
}

class SubjectSelectionScreen extends StatelessWidget {
  final List<Subject> subjects = [
    Subject(
      id: '1',
      name: 'Physics',
      icon: Icons.psychology,  // Direct icon reference
      progress: 0.4,
    ),
    Subject(
      id: '2', 
      name: 'Chemistry',
      icon: Icons.science,  // Different icon
      progress: 0.8,
    ),
    Subject(
      id: '3',
      name: 'Biology',
      icon: Icons.eco,  // Another icon
      progress: 0.6,
    ),
    Subject(
      id: '4',
      name: 'Math',
      icon: Icons.calculate,  // Another icon
      progress: 0.9,
    ),
    Subject(
      id: '5',
      name: 'English',
      icon: Icons.language,  // Another icon
      progress: 0.1,
    ),
    Subject(
      id: '7',
      name: 'SAT',
      icon: Icons.book,  // Another icon
      progress: 0.3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Subject', style: displayStyle.copyWith(color: Colors.white)),
        actions: [IconButton(icon: Icon(Icons.person), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) => SubjectCard(subject: subjects[index]),
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final Subject subject;
  
  const SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            secondaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(cardRadius),
          onTap: () => context.push('/years'),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    subject.icon,  // Use the icon from Subject
                    size: 28,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(subject.name, style: titleStyle),
                Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: subject.progress,
                    backgroundColor: secondaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(primaryColor),
                  ),
                ),
                Text(
                  '${(subject.progress * 100).toInt()}% Completed',
                  style: bodyStyle.copyWith(
                    color: textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:exam_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';  
import 'package:go_router/go_router.dart';

// Temporary question model
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty; // Easy/Medium/Hard

  const Question({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.difficulty = 'Medium',
  });
}

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  QuestionScreenState createState() => QuestionScreenState();
}

class QuestionScreenState extends State<QuestionScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late TabController _tabController;
  int selectedOption = -1;
  int currentQuestionIndex = 0;
  late Timer _timer;
  Duration _remainingTime = Duration(minutes: 30);
  final Map<int, bool> _answeredQuestions = {};
  final List<Question> questions = [
    Question(
      text: 'Which of the following is NOT a fundamental particle in an atom?',
      options: ['Proton', 'Neutron', 'Electron', 'Molecule'],
      correctIndex: 3,
      explanation: 'Molecule is not a fundamental particle. Fundamental particles are the basic building blocks of atoms...',
      difficulty: 'Easy',
    ),
    Question(
      text: 'What is the chemical symbol for Gold?',
      options: ['Ag', 'Fe', 'Au', 'Cu'],
      correctIndex: 2,
      explanation: 'The chemical symbol for Gold is Au, derived from the Latin word "Aurum".',
      difficulty: 'Medium',
    ),
    Question(
      text: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctIndex: 2,
      explanation: 'Paris is the capital city of France...',
      difficulty: 'Easy',
    ),
    Question(
      text: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      correctIndex: 1,
      explanation: 'Mars is called the Red Planet...',
      difficulty: 'Easy',
    ),
    Question(
      text: 'Who wrote "Romeo and Juliet"?',
      options: ['Charles Dickens', 'Jane Austen', 'William Shakespeare', 'Mark Twain'],
      correctIndex: 2,
      explanation: 'William Shakespeare wrote...',
      difficulty: 'Medium',
    ),
    Question(
      text: 'What is the largest mammal in the world?',
      options: ['African Elephant', 'Blue Whale', 'Giraffe', 'Hippopotamus'],
      correctIndex: 1,
      explanation: 'The Blue Whale is the largest mammal...',
      difficulty: 'Medium',
    ),
    Question(
      text: 'In which year did World War II end?',
      options: ['1943', '1945', '1950', '1939'],
      correctIndex: 1,
      explanation: 'World War II ended in 1945...',
      difficulty: 'Hard',
    ),
    Question(
      text: 'What is the square root of 64?',
      options: ['4', '6', '8', '10'],
      correctIndex: 2,
      explanation: 'The square root of 64 is 8...',
      difficulty: 'Easy',
    ),
    Question(
      text: 'Which element has the atomic number 1?',
      options: ['Helium', 'Carbon', 'Hydrogen', 'Oxygen'],
      correctIndex: 2,
      explanation: 'Hydrogen has the atomic number 1...',
      difficulty: 'Medium',
    ),
    Question(
      text: 'What is the largest organ in the human body?',
      options: ['Liver', 'Brain', 'Skin', 'Heart'],
      correctIndex: 2,
      explanation: 'The skin is the largest organ...',
      difficulty: 'Hard',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _tabController = TabController(length: 2, vsync: this);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() => _remainingTime -= Duration(seconds: 1));
      } else {
        _timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time Up!', style: titleStyle),
        content: Text('The allocated time for this quiz has expired.', style: bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: titleStyle.copyWith(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _handleAnswer(int index) {
    setState(() {
      selectedOption = index;
      _answeredQuestions[currentQuestionIndex] = 
          index == questions[currentQuestionIndex].correctIndex;
    });
    if(index == questions[currentQuestionIndex].correctIndex) {
      _confettiController.play();
    }
  }

  void _navigateToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
      selectedOption = -1;
      _tabController.animateTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        leadingWidth: 0,
        toolbarHeight: 120,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}', 
              style: titleStyle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[400],
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _formatDuration(_remainingTime),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: primaryColor,
            ),
          ],
        ),
        actions: [
          // _buildQuestionJumpList(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Question', icon: Icon(Icons.question_answer)),
            Tab(text: 'Explanation', icon: Icon(Icons.lightbulb_outline)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildQuestionTab(question),
              _buildExplanationTab(question),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [primaryColor, secondaryColor],
            ),
          ),
        ],
      ),
    bottomSheet: _buildNavigationControls(),
    );
  }

  Widget _buildQuestionJumpList() {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text('${index + 1}'),
            selected: currentQuestionIndex == index,
            selectedColor: primaryColor,
            labelStyle: TextStyle(
              color: currentQuestionIndex == index ? Colors.white : null,
            ),
            onSelected: (_) => _navigateToQuestion(index),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTab(Question question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              Flexible(
                child: Text(
                  question.text,
                  style: titleStyle.copyWith(fontSize: 18),
                ),
              ),
          
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) => _buildOption(index, question)),
        ],
      ),
    );
  }

  Widget _buildExplanationTab(Question question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Explanation',
            style: titleStyle.copyWith(fontSize: 20, color: primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            question.explanation,
            style: bodyStyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 20),
          if(selectedOption != -1)
            Text(
              selectedOption == question.correctIndex 
                  ? 'Correct Answer!' 
                  : '❌ Incorrect Answer',
              style: titleStyle.copyWith(
                color: selectedOption == question.correctIndex ? Colors.green : Colors.red,
                fontSize: 18
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, Question question) {
    final isCorrect = index == question.correctIndex;
    final isSelected = selectedOption == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _handleAnswer(index),
        borderRadius: BorderRadius.circular(inputFieldRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isCorrect ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08))
                : Colors.transparent,
            border: Border.all(
              color: isSelected 
                  ? (isCorrect ? Colors.green : Colors.red)
                  : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(inputFieldRadius),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Colors.grey[400]!,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        isCorrect ? Icons.check : Icons.close,
                        size: 16,
                        color: isCorrect ? Colors.green : Colors.red,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question.options[index],
                  style: bodyStyle.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? (isCorrect ? Colors.green : Colors.red) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            onPressed: currentQuestionIndex > 0 
                ? () => _navigateToQuestion(currentQuestionIndex - 1)
                : null,
            backgroundColor: primaryColor,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          _buildQuickNavButton(),
          FloatingActionButton(
            onPressed: () {
              if (currentQuestionIndex < questions.length - 1) {
                _navigateToQuestion(currentQuestionIndex + 1);
              } else if (_answeredQuestions.length == questions.length) {
                _showResultDialog();
              }
            },
            backgroundColor: primaryColor,
            child: Icon(
              currentQuestionIndex == questions.length - 1
                  ? Icons.check
                  : Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavButton() {
    return FloatingActionButton(
      onPressed: _showQuestionMap,
      backgroundColor: primaryColor,
      child: Icon(Icons.map, color: Colors.white),
    );
  }

  void _showQuestionMap() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: questions.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _navigateToQuestion(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _getQuestionColor(index),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentQuestionIndex == index 
                      ? primaryColor 
                      : Colors.grey[300]!,
                  width: currentQuestionIndex == index ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _getTextColor(index),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getQuestionColor(int index) {
    if (!_answeredQuestions.containsKey(index)) return Colors.white;
    return _answeredQuestions[index]! ? Colors.green.shade100 : Colors.red.shade100;
  }

  Color _getTextColor(int index) {
    if (!_answeredQuestions.containsKey(index)) return Colors.black;
    return _answeredQuestions[index]! ? Colors.green.shade800 : Colors.red.shade800;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds % 60)}';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return primaryColor;
    }
  }

  void _showResultDialog() {
    final correctAnswers = _answeredQuestions.values.where((v) => v).length;
    final totalQuestions = questions.length;
    final percentage = (correctAnswers / totalQuestions) * 100;
    
    String resultText;
    Color resultColor;
    IconData resultIcon;
    String resultEmoji;

    if (percentage >= 90) {
      resultText = 'Outstanding Performance!';
      resultColor = Colors.green;
      resultIcon = Icons.celebration;
      resultEmoji = '🎉';
      _confettiController.play();
    } else if (percentage >= 70) {
      resultText = 'Great Job!';
      resultColor = Colors.lightGreen;
      resultIcon = Icons.emoji_events;
      resultEmoji = '🌟';
      _confettiController.play();
    } else if (percentage >= 50) {
      resultText = 'Good Effort!';
      resultColor = Colors.orange;
      resultIcon = Icons.thumb_up;
      resultEmoji = '👍';
    } else {
      resultText = 'Keep Practicing!';
      resultColor = Colors.red;
      resultIcon = Icons.refresh;
      resultEmoji = '💪';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                resultColor.withOpacity(0.1),
                resultColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(resultIcon, size: 60, color: resultColor),
              SizedBox(height: 16),
              Text(
                resultEmoji,
                style: TextStyle(fontSize: 40),
              ),
              SizedBox(height: 10),
              Text(
                resultText,
                style: titleStyle.copyWith(
                  fontSize: 24,
                  color: resultColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '$correctAnswers/$totalQuestions Correct Answers',
                style: bodyStyle.copyWith(fontSize: 18),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Score: ',
                    style: bodyStyle.copyWith(fontSize: 18),
                  ),
                  Text(
                    '${percentage.round()}%',
                    style: titleStyle.copyWith(
                      fontSize: 24,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              FilledButton.icon(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                label: Text('Back to Subjects'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/subjects'); // Navigate back
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
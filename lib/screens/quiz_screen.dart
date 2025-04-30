import 'package:flutter/material.dart';
import 'package:quizzing/data_sets/study_set.dart';
import 'package:quizzing/screens/home_screen.dart';

class QuizScreen extends StatefulWidget {
  final StudySet studySet;

  const QuizScreen({super.key, required this.studySet});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0; // Tracks the current question
  int?
      _selectedAnswerIndex; // Tracks the user's selected answer, null if no answer selected
  int _score = 0; // Tracks the user's score
  bool _isAnswered = false; // Tracks if the current question is answered

  // List of flashcards with quiz data (options and correctIndex)
  late List<Flashcard> _quizFlashcards;

  @override
  void initState() {
    super.initState();
    // Filter flashcards that have quiz data (options and correctIndex)
    _quizFlashcards = widget.studySet.flashcards
        .where((flashcard) =>
            flashcard.options != null && flashcard.correctIndex != null)
        .toList(); // add filtered flashcards to list
    // Shuffle flashcards to randomize question order
    _quizFlashcards.shuffle(); // random order for flashcards
  }

  // Check the selected answer and update the score
  void _checkAnswer() {
    if (_selectedAnswerIndex == null) {
      // if answer choice not selected show:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an answer!"),
          backgroundColor: Colors.blueGrey,
          duration: Duration(milliseconds: 850),
        ),
      );
      return;
    }

    final currentFlashcard =
        _quizFlashcards[_currentQuestionIndex]; // curent index flashcard data
    final isCorrect = _selectedAnswerIndex ==
        currentFlashcard
            .correctIndex; // true if answer choice is correct index, otherwise false

    // Update score when correct answer is submited
    setState(() {
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });

    // show correct message if correct
    // show incorrect message is incorrect
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "Correct!" : "Incorrect!"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: Duration(milliseconds: 850), // 1 second
      ),
    );
  }

  // Move to the next question or show results
  void _nextQuestion() {
    if (_currentQuestionIndex < _quizFlashcards.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      // Show results popup
      _showResults();
    }
  }

  // Show results popup when quiz is complete
  void _showResults() {
    // popup screen after quiz is finished
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside of popup
      builder: (context) => AlertDialog(
        title: const Text("Quiz Results"),
        content: Text(
          "You scored $_score out of ${_quizFlashcards.length}!",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close popup
              Navigator.of(context).pop(); // Return to StudyScreen
            },
            child: Center(child: const Text("Return to Study Set")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are no valid quiz flashcards
    if (_quizFlashcards.isEmpty) {
      // Return a AppBar and a message for empty quiz
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Quizzing",
            style: TextStyle(color: Colors.deepOrangeAccent),
          ),
        ),
        body: const Center(
          child: Text("No quiz questions available for this study set"),
        ),
      );
    }

    // Get the current flashcard based on the question index
    final currentFlashcard = _quizFlashcards[_currentQuestionIndex];
    // Create progress text showing current question number and total
    final questionNum =
        "Question ${_currentQuestionIndex + 1}/${_quizFlashcards.length}";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quizzing",
          style: TextStyle(color: Colors.deepOrangeAccent),
        ),
        // Back button to return to the previous screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Pop the current screen from navigation stack
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // indicator showing current question number
            Text(
              questionNum,
              style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            // Question display (shows flashcard term)
            Card(
              color: Colors.blueGrey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    currentFlashcard.term, // Display the flashcard term
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // List of answer options using RadioListTile
            ListView.builder(
              shrinkWrap: true, // Make List take only the space it needs
              physics:
                  const NeverScrollableScrollPhysics(), // Disable List scrolling
              itemCount:
                  currentFlashcard.options!.length, // Number of answer choices
              itemBuilder: (context, index) {
                // return each answer choice
                return RadioListTile<int>(
                  title: Text(
                    currentFlashcard
                        .options![index], // Display answer choice text
                    style: const TextStyle(fontSize: 18),
                  ),
                  value: index, // answer choice index as the value
                  groupValue: _selectedAnswerIndex, // Selected option index
                  activeColor: Colors.deepOrangeAccent,
                  onChanged: _isAnswered
                      ? null // Disable selection after answer is submitted
                      : (value) {
                          // Update selected option when user taps it
                          setState(() {
                            _selectedAnswerIndex = value;
                          });
                        },
                );
              },
            ),
            const SizedBox(height: 16),
            // Submit/Next button
            Center(
              child: ElevatedButton(
                // Call _checkAnswer if not answered, _nextQuestion if answered
                onPressed: _isAnswered ? _nextQuestion : _checkAnswer,
                child: Text(
                  _isAnswered ? "Next" : "Submit",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  // Navigates to HomeScreen
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

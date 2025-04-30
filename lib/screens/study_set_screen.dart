import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizzing/data_sets/study_set.dart';
import 'package:quizzing/widgets/term_list_widget.dart';
import 'package:quizzing/screens/home_screen.dart';
import 'package:quizzing/screens/quiz_screen.dart';
import 'dart:math';

class StudyScreen extends StatefulWidget {
  final StudySet studySet;

  const StudyScreen({super.key, required this.studySet});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    // adds TickerProvider functionality (update animations in sync with screen redraws)
    with
        SingleTickerProviderStateMixin {
  late List<bool> _isFlipped; // Tracks if flipped or not for each flashcard
  List<double> _angles = []; // Tracks current rotation angle for each card
  TabController? _tabController; // Controls the tab selector
  bool _isSaved = false; // Tracks if study set is saved

  @override
  // initState called once when the widget is inserted into the widget tree.
  // place to set up resources that persist throughout the widget’s life.
  void initState() {
    super.initState();
    // Generate a list and initialize all flashcards to false, shows term
    _isFlipped = List.generate(widget.studySet.flashcards.length, (_) => false);
    // Initialize angles to 0.0 (term) for each flashcard
    _angles = List.generate(widget.studySet.flashcards.length, (_) => 0);
    // Initialize TabController with the number of flashcards
    // class that manages the state and animations of tabbed interfaces, such as tabs or dot indicators
    _tabController = TabController(
      length: widget.studySet.flashcards.length, // Number of tabs (flashcards)
      vsync:
          this, // Links the controller to a timing mechanism for animations (TickerProvider)
    );
    _checkIfSaved(); // Check if study set is saved
  }

  @override
  // dispose called when the widget is permanently removed from the tree
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Check if the study set is saved to the user's saved study sets
  Future<void> _checkIfSaved() async {
    // asynch, saves study set to Firestore
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user == null) return;

    final userId = user.uid; // stores the user’s unique ID
    final firestore =
        FirebaseFirestore.instance; // Accesses Firestore instance and stores it
    final studySetRef = firestore // stores the study set document reference
        .collection('users') // gets users collection
        .doc(userId) // gets current user’s document
        .collection('studySets') // gets studySets subcollection
        .doc(
            '${widget.studySet.title}_$userId'); // makes Unique study set name with title and user ID

    final doc = await studySetRef.get(); // get the studyset doc
    if (mounted) {
      setState(() {
        _isSaved = doc.exists; // if doc exists, set to true otherwise false
      });
    }
  }

  // Save the study set to the user's saved study sets
  Future<void> _saveStudySetToFirestore() async {
    // asynch, saves study set to Firestore
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user == null) {
      throw Exception("User not logged in"); // Throws error if no user
    }

    final userId = user.uid; // stores the user’s unique ID
    final firestore =
        FirebaseFirestore.instance; // Accesses Firestore instance and stores it
    final studySetRef = firestore // stores the study set document reference
        .collection('users') // gets users collection
        .doc(userId) // gets current user’s document
        .collection('studySets') // gets studySets subcollection
        .doc(
            '${widget.studySet.title}_$userId'); // makes Unique study set name with title and user ID
    // Converts StudySet object (with title and flashcards) into a Map<String, dynamic>
    // an object into a format that can be stored in Firestore
    await studySetRef // await pauses until the Future is done
        .set(widget.studySet
            .toFirestore()); // Saves study set data into Firestore database

    final flashcardsRef =
        studySetRef.collection('flashcards'); // stores flashcards subcollection
    for (var i = 0; i < widget.studySet.flashcards.length; i++) {
      // Loops through flashcards
      await flashcardsRef // Saves each flashcard
          .doc('flashcard_$i') // flashcard name with index
          // Saves flashcard data into Firestore database
          .set(widget.studySet.flashcards[i]
              .toFirestore()); // Converts to Firestore format
    }
    if (mounted) {
      setState(() {
        _isSaved = true; // Update _isSaved to true
      });
    }
  }

  // Unsave the study set from the user's saved study sets
  Future<void> _unsaveStudySetFromFirestore() async {
    // asynch, deletes study set from Firestore
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user == null) {
      throw Exception("User not logged in"); // Throws error if no user
    }

    final userId = user.uid; // stores the user’s unique ID
    final firestore =
        FirebaseFirestore.instance; // Accesses Firestore instance and stores it
    final studySetRef = firestore // stores the study set document reference
        .collection('users') // gets users collection
        .doc(userId) // gets current user’s document
        .collection('studySets') // gets studySets subcollection
        .doc(
            '${widget.studySet.title}_$userId'); // makes Unique study set name with title and user ID

    // Delete the study set doc and its flashcards subcollection
    final flashcardsRef =
        studySetRef.collection('flashcards'); // stores flashcards subcollection
    final flashcards = await flashcardsRef.get(); // Gets all flashcard docs
    for (var doc in flashcards.docs) {
      await doc.reference.delete(); // Deletes each flashcard doc
    }
    await studySetRef.delete(); // Deletes the study set doc

    if (mounted) {
      setState(() {
        _isSaved = false; // Update _isSaved to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height
    final double screenHeight = MediaQuery.of(context).size.height;
    // Calculate 1/3 of the screen height
    final double cardHeight = screenHeight / 3;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(cardHeight + 75),
        child: AppBar(
          title: const Text("Quizzing",
              style: TextStyle(color: Colors.deepOrangeAccent)),
          flexibleSpace: Column(
            children: [
              SizedBox(height: cardHeight / 3.0), // Space for title
              SizedBox(
                height: cardHeight, // Flashcard height is 1/3 of screen
                child: PageView.builder(
                  // Number of flashcards in the study set
                  itemCount: widget.studySet.flashcards.length,
                  // triggered when the user swipes to a new page (flashcard)
                  onPageChanged: (index) {
                    // Sync TabController with the current page
                    setState(() {
                      // Updates the TabController’s index to match the PageView’s current page
                      // (match dot with flashcard)
                      _tabController?.index = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    // Gets the current flashcard
                    final card = widget.studySet.flashcards[index];
                    return GestureDetector(
                      // Flips the flashcard
                      onTap: () {
                        setState(() {
                          _isFlipped[index] = !_isFlipped[index];
                          // Update angle to target value (0 or 180 degrees)
                          _angles[index] = _isFlipped[index]
                              ? pi // pi is definition
                              : 0.0; // 0 is term
                        });
                      },
                      // animates a property of a Widget to a target value whenever the target value changes
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          // Tween Defines the range of values to animate
                          begin: _angles[index], // Start from current angle
                          end: _angles[index], // End at current angle
                        ),
                        duration: const Duration(
                            milliseconds: 300), // Animation duration
                        curve: // animation pacing
                            Curves.easeInOut,
                        // builder rotates the card
                        // angle is a double ranging from the begin value to the end value.
                        builder: (context, angle, child) {
                          // Determine if term or definition is visible
                          final isFrontVisible = angle <
                              pi /
                                  2; // pi / 2 (90 degrees) halfway point of the flip.

                          return Stack(
                            children: [
                              // Term side
                              Visibility(
                                visible: isFrontVisible,
                                // transform applies a 3D rotation to the card
                                child: Transform(
                                  transform:
                                      Matrix4.identity() // 4x4 identity matrix
                                        ..setEntry(
                                            3, 2, 0.001) // Adds perspective
                                        // rotation around the Y-axis
                                        ..rotateY(angle),
                                  alignment: Alignment.center,
                                  child: Card(
                                    color: Colors.blueGrey,
                                    margin: const EdgeInsets.all(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          card.term, // Show term
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
                                ),
                              ),
                              // definition side
                              Visibility(
                                visible: !isFrontVisible,
                                // transform applies a 3D rotation to the card
                                child: Transform(
                                  transform: Matrix4
                                      .identity() // 4x4 identity matrix to handle transformations in 3D space
                                    // fourth row (3) handles perspective and translation
                                    // third row (2) handles z-coordinate in 3D transformations
                                    // value (.001) makes farther parts of the card during rotation appear smaller
                                    ..setEntry(3, 2,
                                        0.001) // setEntry(row, column, value) in matrix
                                    // rotation around the Y-axis
                                    ..rotateY(angle +
                                        pi), // Extra π to fix text direction
                                  alignment: Alignment.center,
                                  child: Card(
                                    color: Colors.blueGrey,
                                    margin: const EdgeInsets.all(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          card.definition, // Show definition
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
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              FlashcardIndicatorWidget(
                tabController: _tabController,
                flashcardCount: widget.studySet.flashcards.length,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
            child: Text(
              widget.studySet.title,
              style: const TextStyle(fontSize: 36, color: Colors.blueAccent),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // Builds a scrollable list
              itemCount:
                  widget.studySet.flashcards.length, // Number of flashcards
              itemBuilder: (context, index) {
                final flashcard = widget
                    .studySet.flashcards[index]; // gets the current flashcard
                return FlashcardListWidget(
                    flashcard); // Displays the flashcard in list
              },
            ),
          ),
        ],
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
            ElevatedButton(
              onPressed: () async {
                try {
                  if (_isSaved) {
                    await _unsaveStudySetFromFirestore();
                    if (context.mounted) {
                      // checks if the widget is still on screen (widget is still in the tree)
                      // Shows a confirmation message when the study set is unsaved
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Study set unsaved!")),
                      );
                    }
                  } else {
                    await _saveStudySetToFirestore();
                    if (context.mounted) {
                      // checks if the widget is still on screen (widget is still in the tree)
                      // Shows a confirmation message when the study set is saved
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Study set saved!")),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    // checks if the widget is still on screen (widget is still in the tree)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error saving study set: $e")),
                    );
                  }
                }
              },
              child: Text(
                _isSaved ? "Unsave Study Set" : "Save Study Set",
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.quiz),
              onPressed: () {
                Navigator.of(context).push(
                  // Navigates to HomeScreen
                  MaterialPageRoute(
                      builder: (_) => QuizScreen(studySet: widget.studySet)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// displays a TabPageSelector, showing dots to indicate the current flashcard in the PageView
class FlashcardIndicatorWidget extends StatelessWidget {
  // Provides the current index (which dot is highlighted) and length (number of dots, matching flashcards)
  final TabController? tabController;
  // the number of flashcards
  final int flashcardCount;

  const FlashcardIndicatorWidget({
    super.key,
    required this.tabController,
    required this.flashcardCount,
  });

  @override
  Widget build(BuildContext context) {
    // TabPageSelector widget displays a horizontal row of dots
    return TabPageSelector(
      controller: tabController,
      color: Colors.grey, // Background for unselected dots
      selectedColor: Colors.deepOrangeAccent, // Color for the current dot
      indicatorSize: 12, // Size of each dot
    );
  }
}

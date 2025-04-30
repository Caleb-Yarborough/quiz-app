import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizzing/screens/about.dart';
import 'package:quizzing/screens/login_screen.dart';
import 'package:quizzing/screens/study_set_screen.dart';
import 'package:quizzing/widgets/study_set_list_widget.dart';
import 'package:quizzing/data_sets/study_set.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = ''; // Stores the user's search input, empty at first

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser; // Gets the currently logged-in user
    if (user == null) {
      // Checks if no user is logged in
      return const LoginScreen(); // Redirects to login if not logged in
    }

    return Scaffold(
      // App bar with title
      appBar: AppBar(
          title: const Text("Quizzing",
              style: TextStyle(color: Colors.deepOrangeAccent))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search Study Sets",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                //  trigger a rebuild whenever _searchQuery changes (text in search bar)
                setState(() {
                  _searchQuery =
                      value.toLowerCase(); // Converts input to lowercase
                });
              },
            ),
          ),
          // Search Results Section
          if (_searchQuery.isNotEmpty)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // listens to real-time data updates and rebuilds itself when new data comes in
                // Streams data from Firestore
                stream: FirebaseFirestore
                    .instance // Accesses Firestore database
                    .collection(
                        'globalStudySets') // looks for the globalStudySets collection
                    .snapshots(), // Listens for update
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error searching study sets"));
                  }
                  if (!snapshot.hasData) {
                    // Checks if data hasn’t loaded yet
                    return const Center(child: CircularProgressIndicator());
                  }
                  final studySetDocs =
                      snapshot.data!.docs; // Gets list of study set docs
                  return FutureBuilder<List<StudySet>>(
                    // A Future is a value that will be available later
                    // async, gets flashcards from StudySet
                    future: Future.wait(
                      // Waits for all flashcards
                      studySetDocs.map((doc) async {
                        // Maps each doc to a StudySet
                        final flashcardsSnapshot =
                            await doc.reference.collection('flashcards').get();
                        final flashcards = flashcardsSnapshot.docs
                            .map((flashDoc) =>
                                Flashcard.fromFirestore(flashDoc.data()))
                            .toList();
                        return StudySet.fromFirestore(
                            doc, flashcards); // Creates a StudySet object
                      }),
                    ),
                    builder: (context, futureSnapshot) {
                      if (!futureSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final searchResults = futureSnapshot
                          .data! // Filters study sets by search input
                          .where((studySet) => studySet.title
                              .toLowerCase()
                              .contains(
                                  _searchQuery)) // contains gets partial title matches from _searchQuery
                          .toList();
                      return Column(
                        // Puts search results in column
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Search Results",
                              style: const TextStyle(
                                  fontSize: 36, color: Colors.blueAccent),
                            ),
                          ),
                          Expanded(
                            // fill remaining space
                            child: ListView.builder(
                              // Builds a scrollable list
                              itemCount: searchResults
                                  .length, // Number of items in the list
                              itemBuilder: (context, index) {
                                // Builds each list item
                                final studySet = searchResults[
                                    index]; // Gets the current study set
                                return StudySetListWidget(
                                  // Displays the study set
                                  studySet, // Passes the study set to the widget
                                  onTap: () {
                                    Navigator.of(context).push(
                                      // Navigates to StudyScreen
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudyScreen(studySet: studySet)),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            )
          else ...[
            // spread operator (...) because 'List<Widget>'
            // Shows saved study sets when there is no search input
            const SizedBox(height: 16),
            // Saved Sets Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Saved Study Sets",
                style: const TextStyle(fontSize: 36, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Streams user’s saved study sets
                stream: FirebaseFirestore.instance // Accesses Firestore
                    .collection('users') // gets users collection
                    .doc(user.uid) // gets current user’s document
                    .collection('studySets') // gets studySets subcollection
                    .snapshots(), // Listens for update
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error loading saved study sets"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text("No saved study sets yet"));
                  }
                  final studySetDocs =
                      snapshot.data!.docs; // Gets list of saved study set docs
                  return FutureBuilder<List<StudySet>>(
                    // async, gets study sets
                    future: Future.wait(
                      // takes a list of Futures and waits until all of them are completed
                      // Waits for flashcards
                      studySetDocs.map((doc) async {
                        // Maps each doc to a StudySet
                        final flashcardsSnapshot = await doc.reference
                            .collection('flashcards')
                            .get(); // Fetches flashcards
                        // Maps each doc to a flashcard
                        final flashcards = flashcardsSnapshot.docs
                            .map((flashDoc) => Flashcard.fromFirestore(flashDoc
                                .data())) // Converts to Flashcard objects
                            .toList();
                        return StudySet.fromFirestore(
                            doc, flashcards); // Creates a StudySet
                      }),
                    ),
                    // builds the study set list
                    builder: (context, futureSnapshot) {
                      if (!futureSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final studySets = futureSnapshot
                          .data!; // Gets the list of saved study sets
                      return ListView.builder(
                        // Builds a scrollable list
                        itemCount: studySets.length,
                        itemBuilder: (context, index) {
                          final studySet =
                              studySets[index]; // Gets the current study set
                          return StudySetListWidget(
                            // Displays the study set
                            studySet,
                            onTap: () {
                              Navigator.of(context).push(
                                // Navigates to StudyScreen
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StudyScreen(studySet: studySet)),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Button to navigate to the About screen
            ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
              child: const Text("About Page",
                  style: TextStyle(color: Colors.black87)),
            ),
            // Logout button
            ElevatedButton(
              onPressed: () async {
                // asynch, logout
                // await pauses until the Future is done
                await FirebaseAuth.instance.signOut(); // Signs the user out
                if (context.mounted) {
                  // Checks if widget is still in the tree
                  Navigator.of(context).pushAndRemoveUntil(
                    // clears stack, navigates to To LoginScreen
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child:
                  const Text("Logout", style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}

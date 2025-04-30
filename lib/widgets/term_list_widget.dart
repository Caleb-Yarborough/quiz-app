import 'package:flutter/material.dart';
import 'package:quizzing/data_sets/study_set.dart';

class FlashcardListWidget extends StatelessWidget {
  final Flashcard flashcard; // stores flashcard data

  const FlashcardListWidget(this.flashcard, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.blueGrey,
        // listitem term
        title: Text(
          flashcard.term,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // listitem definition
        subtitle: Text(
          flashcard.definition,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

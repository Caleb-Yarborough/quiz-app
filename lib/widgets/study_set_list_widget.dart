import 'package:flutter/material.dart';
import 'package:quizzing/data_sets/study_set.dart';

class StudySetListWidget extends StatelessWidget {
  const StudySetListWidget(this.studySet, {super.key, this.onTap});

  final StudySet studySet; // The study set data

  // callback function triggered when the study set is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        tileColor: Colors.blueGrey,
        title: Text(
          studySet.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Calls the onTap function when the study set is tapped
        onTap: onTap,
      ),
    );
  }
}

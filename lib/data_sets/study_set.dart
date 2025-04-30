import 'package:cloud_firestore/cloud_firestore.dart';

/// A class that contains a single flashcard with a [term] and [definition]
class Flashcard {
  /// The [term] or question on the flashcard
  final String term;

  /// The [definition] or answer on the flashcard
  final String definition;

  /// The [options] or answer choices for this flashcard
  final List<String>? options;

  /// The [correctIndex] or answer for this flashcard
  final int? correctIndex;

  /// Creates a [Flashcard] with a required [term], [definition], [options], and [correctIndex]
  const Flashcard({
    required this.term,
    required this.definition,
    this.options,
    this.correctIndex,
  });

  /// Converts a [Flashcard] object to a Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'term': term,
      'definition': definition,
      if (options != null && correctIndex != null) // Checks if quiz data exists
        'quiz': {
          // Adds a quiz map if options and correctIndex are present
          'options': options,
          'correctIndex': correctIndex,
        },
    };
  }

  /// Creates a Flashcard object from Firestore data (factory is custom object creation)
  factory Flashcard.fromFirestore(Map<String, dynamic> data) {
    // Factory constructor for deserialization (converting data back into Flashcard object)
    final quizData = data['quiz']
        as Map<String, dynamic>?; // Extracts quiz data if it exists
    return Flashcard(
      // Sets term, definition, options, and correctIndex
      term: data['term'] as String,
      definition: data['definition'] as String,
      // Converts options to List<String> if quizData exists, otherwise null
      options: quizData != null ? List<String>.from(quizData['options']) : null,
      // Sets correctIndex if quizData exists, casts to int, otherwise null
      correctIndex: quizData != null ? quizData['correctIndex'] as int : null,
    );
  }
}

/// A class that contains a collection of [flashcards] with a specific [title]
class StudySet {
  /// [title] of the study set
  final String title;

  /// A list of [flashcards] associated with study set
  final List<Flashcard> flashcards;

  /// Creates a [StudySet] with a required [title] and [flashcards]
  const StudySet({
    required this.title,
    required this.flashcards,
  });

  /// Converts a StudySet object to a Firestore map
  Map<String, dynamic> toFirestore() {
    // toFirestore converts an object into a format that can be stored
    return {
      'title': title,
    };
  }

  /// Creates a StudySet object from Firestore data and a list of flashcards (factory is custom object creation)
  factory StudySet.fromFirestore(
      // Factory constructor for deserialization
      DocumentSnapshot // DocumentSnapshot is a single Firestore document at the time you queried it
          doc, // Firestore document snapshot containing study set data
      List<Flashcard> flashcards) {
    // List of flashcards passed separately
    final data =
        doc.data() as Map<String, dynamic>; // Casts document data to a map
    return StudySet(
      title:
          data['title'] as String, // Sets title from the map, casts to String
      flashcards: flashcards, // Assigns the flashcards list
    );
  }
}

// List of all study sets
final List<StudySet> studySets = [
  StudySet(
    title: "Biology Basics",
    flashcards: [
      Flashcard(
          term: "Cell",
          definition: "Basic unit of life",
          options: ["Basic unit of life", "Plant", "Organ", "Mineral"],
          correctIndex: 0),
      Flashcard(
          term: "DNA",
          definition: "Genetic material",
          options: ["Genetic material", "Protein", "Sugar", "Virus"],
          correctIndex: 0),
      Flashcard(
          term: "Mitochondria",
          definition: "Powerhouse of the cell",
          options: ["Powerhouse of the cell", "Nucleus", "Wall", "Fluid"],
          correctIndex: 0),
      Flashcard(
          term: "Nucleus",
          definition: "Control center of the cell",
          options: [
            "Control center of the cell",
            "Membrane",
            "Ribosome",
            "Vacuole"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Photosynthesis",
          definition: "Process converting light to energy",
          options: [
            "Process converting light to energy",
            "Digestion",
            "Respiration",
            "Fermentation"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Enzyme",
          definition: "Biological catalyst",
          options: ["Biological catalyst", "Sugar", "Fat", "Vitamin"],
          correctIndex: 0),
      Flashcard(
          term: "Ribosome",
          definition: "Protein synthesis site",
          options: [
            "Protein synthesis site",
            "Energy store",
            "Cell wall",
            "Nucleus"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Chloroplast",
          definition: "Site of photosynthesis",
          options: [
            "Site of photosynthesis",
            "Mitochondria",
            "Lysosome",
            "Golgi"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Gene",
          definition: "Unit of heredity",
          options: ["Unit of heredity", "Cell", "Protein", "Enzyme"],
          correctIndex: 0),
      Flashcard(
          term: "Mitosis",
          definition: "Cell division process",
          options: [
            "Cell division process",
            "Photosynthesis",
            "Diffusion",
            "Osmosis"
          ],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Spanish Vocabulary",
    flashcards: [
      Flashcard(
          term: "Hola",
          definition: "Hello",
          options: ["Hello", "Goodbye", "Yes", "No"],
          correctIndex: 0),
      Flashcard(
          term: "Adiós",
          definition: "Goodbye",
          options: ["Goodbye", "Hello", "Thank you", "Please"],
          correctIndex: 0),
      Flashcard(
          term: "Gracias",
          definition: "Thank you",
          options: ["Thank you", "Please", "Friend", "Family"],
          correctIndex: 0),
      Flashcard(
          term: "Por favor",
          definition: "Please",
          options: ["Please", "Thank you", "House", "Food"],
          correctIndex: 0),
      Flashcard(
          term: "Amigo",
          definition: "Friend",
          options: ["Friend", "Family", "Yes", "No"],
          correctIndex: 0),
      Flashcard(
          term: "Familia",
          definition: "Family",
          options: ["Family", "Friend", "Food", "House"],
          correctIndex: 0),
      Flashcard(
          term: "Comida",
          definition: "Food",
          options: ["Food", "House", "Hello", "Goodbye"],
          correctIndex: 0),
      Flashcard(
          term: "Casa",
          definition: "House",
          options: ["House", "Food", "Yes", "No"],
          correctIndex: 0),
      Flashcard(
          term: "Sí",
          definition: "Yes",
          options: ["Yes", "No", "Please", "Thank you"],
          correctIndex: 0),
      Flashcard(
          term: "No",
          definition: "No",
          options: ["No", "Yes", "Friend", "Family"],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Math Terms",
    flashcards: [
      Flashcard(
          term: "Pi",
          definition: "3.14159",
          options: ["3.14159", "2.718", "1.414", "0"],
          correctIndex: 0),
      Flashcard(
          term: "Slope",
          definition: "Rise over run",
          options: ["Rise over run", "Area", "Volume", "Sum"],
          correctIndex: 0),
      Flashcard(
          term: "Integral",
          definition: "Area under a curve",
          options: ["Area under a curve", "Rate", "Limit", "Product"],
          correctIndex: 0),
      Flashcard(
          term: "Derivative",
          definition: "Rate of change",
          options: ["Rate of change", "Sum", "Difference", "Quotient"],
          correctIndex: 0),
      Flashcard(
          term: "Matrix",
          definition: "Array of numbers",
          options: ["Array of numbers", "Single value", "Line", "Curve"],
          correctIndex: 0),
      Flashcard(
          term: "Vector",
          definition: "Magnitude and direction",
          options: ["Magnitude and direction", "Point", "Scalar", "Plane"],
          correctIndex: 0),
      Flashcard(
          term: "Factorial",
          definition: "Product of integers up to n",
          options: ["Product of integers up to n", "Sum", "Average", "Ratio"],
          correctIndex: 0),
      Flashcard(
          term: "Logarithm",
          definition: "Inverse of exponentiation",
          options: [
            "Inverse of exponentiation",
            "Addition",
            "Multiplication",
            "Division"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Quadratic",
          definition: "Second-degree polynomial",
          options: ["Second-degree polynomial", "Linear", "Cubic", "Constant"],
          correctIndex: 0),
      Flashcard(
          term: "Infinity",
          definition: "Unbounded value",
          options: ["Unbounded value", "Zero", "One", "Finite"],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "History Dates",
    flashcards: [
      Flashcard(
          term: "1492",
          definition: "Columbus sailed",
          options: [
            "Columbus sailed",
            "French Revolution",
            "Moon landing",
            "Civil War"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1776",
          definition: "Declaration of Independence",
          options: [
            "Declaration of Independence",
            "World War I",
            "Berlin Wall",
            "9/11"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1789",
          definition: "French Revolution began",
          options: [
            "French Revolution began",
            "COVID-19",
            "WWII ended",
            "Columbus"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1865",
          definition: "U.S. Civil War ended",
          options: [
            "U.S. Civil War ended",
            "Moon landing",
            "WWII began",
            "Independence"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1914",
          definition: "World War I began",
          options: [
            "World War I began",
            "Berlin Wall",
            "9/11",
            "French Revolution"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1945",
          definition: "World War II ended",
          options: [
            "World War II ended",
            "Columbus sailed",
            "COVID-19",
            "Civil War"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1969",
          definition: "Moon landing",
          options: [
            "Moon landing",
            "WWII began",
            "Independence",
            "Berlin Wall"
          ],
          correctIndex: 0),
      Flashcard(
          term: "1989",
          definition: "Berlin Wall fell",
          options: ["Berlin Wall fell", "9/11", "French Revolution", "WWI"],
          correctIndex: 0),
      Flashcard(
          term: "2001",
          definition: "9/11 attacks",
          options: ["9/11 attacks", "Civil War", "Moon landing", "WWII"],
          correctIndex: 0),
      Flashcard(
          term: "2020",
          definition: "COVID-19 pandemic declared",
          options: [
            "COVID-19 pandemic declared",
            "Columbus",
            "Berlin Wall",
            "Independence"
          ],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Elements",
    flashcards: [
      Flashcard(
          term: "H2O",
          definition: "Water",
          options: ["Water", "Salt", "Oxygen", "Gold"],
          correctIndex: 0),
      Flashcard(
          term: "NaCl",
          definition: "Salt",
          options: ["Salt", "Water", "Carbon dioxide", "Iron"],
          correctIndex: 0),
      Flashcard(
          term: "CO2",
          definition: "Carbon dioxide",
          options: ["Carbon dioxide", "Nitrogen", "Methane", "Acid"],
          correctIndex: 0),
      Flashcard(
          term: "O2",
          definition: "Oxygen",
          options: ["Oxygen", "Water", "Salt", "Gold"],
          correctIndex: 0),
      Flashcard(
          term: "HCl",
          definition: "Hydrochloric acid",
          options: ["Hydrochloric acid", "Methane", "Nitrogen", "Iron"],
          correctIndex: 0),
      Flashcard(
          term: "CH4",
          definition: "Methane",
          options: ["Methane", "Water", "Oxygen", "Salt"],
          correctIndex: 0),
      Flashcard(
          term: "N2",
          definition: "Nitrogen",
          options: ["Nitrogen", "Carbon dioxide", "Acid", "Gold"],
          correctIndex: 0),
      Flashcard(
          term: "Fe",
          definition: "Iron",
          options: ["Iron", "Water", "Salt", "Oxygen"],
          correctIndex: 0),
      Flashcard(
          term: "Au",
          definition: "Gold",
          options: ["Gold", "Methane", "Nitrogen", "Iron"],
          correctIndex: 0),
      Flashcard(
          term: "pH",
          definition: "Measure of acidity",
          options: ["Measure of acidity", "Water", "Salt", "Oxygen"],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Computer Science",
    flashcards: [
      Flashcard(
          term: "Algorithm",
          definition: "Step-by-step procedure",
          options: [
            "Step-by-step procedure",
            "Random data",
            "Hardware",
            "Memory"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Binary",
          definition: "Base-2 number system",
          options: ["Base-2 number system", "Decimal", "Hex", "Octal"],
          correctIndex: 0),
      Flashcard(
          term: "CPU",
          definition: "Central Processing Unit",
          options: ["Central Processing Unit", "Memory", "Disk", "Screen"],
          correctIndex: 0),
      Flashcard(
          term: "RAM",
          definition: "Random Access Memory",
          options: ["Random Access Memory", "Processor", "Storage", "Input"],
          correctIndex: 0),
      Flashcard(
          term: "Stack",
          definition: "LIFO data structure",
          options: ["LIFO data structure", "FIFO", "Array", "Tree"],
          correctIndex: 0),
      Flashcard(
          term: "Queue",
          definition: "FIFO data structure",
          options: ["FIFO data structure", "LIFO", "Hash", "Graph"],
          correctIndex: 0),
      Flashcard(
          term: "Hash",
          definition: "Key-value mapping",
          options: ["Key-value mapping", "List", "Stack", "Queue"],
          correctIndex: 0),
      Flashcard(
          term: "Thread",
          definition: "Smallest unit of processing",
          options: ["Smallest unit of processing", "Program", "Memory", "Disk"],
          correctIndex: 0),
      Flashcard(
          term: "API",
          definition: "Application Programming Interface",
          options: [
            "Application Programming Interface",
            "Hardware",
            "Binary",
            "CPU"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Debugging",
          definition: "Finding and fixing errors",
          options: [
            "Finding and fixing errors",
            "Compiling",
            "Running",
            "Designing"
          ],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "World Capitals",
    flashcards: [
      Flashcard(
          term: "France",
          definition: "Paris",
          options: ["Paris", "London", "Berlin", "Madrid"],
          correctIndex: 0),
      Flashcard(
          term: "Japan",
          definition: "Tokyo",
          options: ["Tokyo", "Seoul", "Beijing", "Bangkok"],
          correctIndex: 0),
      Flashcard(
          term: "Brazil",
          definition: "Brasília",
          options: ["Brasília", "Rio", "São Paulo", "Lima"],
          correctIndex: 0),
      Flashcard(
          term: "Canada",
          definition: "Ottawa",
          options: ["Ottawa", "Toronto", "Vancouver", "Montreal"],
          correctIndex: 0),
      Flashcard(
          term: "India",
          definition: "New Delhi",
          options: ["New Delhi", "Mumbai", "Kolkata", "Bangalore"],
          correctIndex: 0),
      Flashcard(
          term: "Australia",
          definition: "Canberra",
          options: ["Canberra", "Sydney", "Melbourne", "Perth"],
          correctIndex: 0),
      Flashcard(
          term: "Russia",
          definition: "Moscow",
          options: ["Moscow", "St. Petersburg", "Kiev", "Minsk"],
          correctIndex: 0),
      Flashcard(
          term: "South Africa",
          definition: "Pretoria",
          options: ["Pretoria", "Cape Town", "Johannesburg", "Durban"],
          correctIndex: 0),
      Flashcard(
          term: "Egypt",
          definition: "Cairo",
          options: ["Cairo", "Alexandria", "Giza", "Luxor"],
          correctIndex: 0),
      Flashcard(
          term: "Mexico",
          definition: "Mexico City",
          options: ["Mexico City", "Guadalajara", "Cancun", "Monterrey"],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Physics Concepts",
    flashcards: [
      Flashcard(
          term: "Gravity",
          definition: "Force of attraction",
          options: ["Force of attraction", "Light", "Sound", "Heat"],
          correctIndex: 0),
      Flashcard(
          term: "Velocity",
          definition: "Speed with direction",
          options: ["Speed with direction", "Mass", "Energy", "Pressure"],
          correctIndex: 0),
      Flashcard(
          term: "Energy",
          definition: "Capacity to do work",
          options: ["Capacity to do work", "Force", "Time", "Distance"],
          correctIndex: 0),
      Flashcard(
          term: "Momentum",
          definition: "Mass in motion",
          options: ["Mass in motion", "Weight", "Friction", "Tension"],
          correctIndex: 0),
      Flashcard(
          term: "Wavelength",
          definition: "Distance between waves",
          options: [
            "Distance between waves",
            "Speed",
            "Frequency",
            "Amplitude"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Friction",
          definition: "Opposes motion",
          options: [
            "Opposes motion",
            "Pulls objects",
            "Heats air",
            "Bends light"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Acceleration",
          definition: "Change in velocity",
          options: [
            "Change in velocity",
            "Constant speed",
            "Static force",
            "Rest"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Resistance",
          definition: "Opposes current flow",
          options: [
            "Opposes current flow",
            "Increases voltage",
            "Stores energy",
            "Emits light"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Magnetism",
          definition: "Attracts or repels",
          options: [
            "Attracts or repels",
            "Heats up",
            "Slows down",
            "Breaks apart"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Entropy",
          definition: "Measure of disorder",
          options: ["Measure of disorder", "Order", "Speed", "Force"],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Literary Terms",
    flashcards: [
      Flashcard(
          term: "Metaphor",
          definition: "Direct comparison",
          options: [
            "Direct comparison",
            "Exaggeration",
            "Repetition",
            "Question"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Simile",
          definition: "Comparison using like/as",
          options: ["Comparison using like/as", "Symbol", "Irony", "Allusion"],
          correctIndex: 0),
      Flashcard(
          term: "Irony",
          definition: "Opposite of expected",
          options: ["Opposite of expected", "Rhyme", "Meter", "Plot"],
          correctIndex: 0),
      Flashcard(
          term: "Alliteration",
          definition: "Repeated consonant sounds",
          options: [
            "Repeated consonant sounds",
            "Word play",
            "Hidden meaning",
            "Contrast"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Protagonist",
          definition: "Main character",
          options: ["Main character", "Villain", "Sidekick", "Narrator"],
          correctIndex: 0),
      Flashcard(
          term: "Antagonist",
          definition: "Opposes protagonist",
          options: ["Opposes protagonist", "Helper", "Friend", "Author"],
          correctIndex: 0),
      Flashcard(
          term: "Climax",
          definition: "Turning point",
          options: ["Turning point", "Beginning", "End", "Theme"],
          correctIndex: 0),
      Flashcard(
          term: "Theme",
          definition: "Central message",
          options: ["Central message", "Setting", "Character", "Conflict"],
          correctIndex: 0),
      Flashcard(
          term: "Foreshadowing",
          definition: "Hints at future events",
          options: [
            "Hints at future events",
            "Past recall",
            "Sudden action",
            "Dialogue"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Symbolism",
          definition: "Objects represent ideas",
          options: [
            "Objects represent ideas",
            "Literal meaning",
            "Random events",
            "Sound patterns"
          ],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Music Theory",
    flashcards: [
      Flashcard(
          term: "Tempo",
          definition: "Speed of music",
          options: ["Speed of music", "Volume", "Pitch", "Rhythm"],
          correctIndex: 0),
      Flashcard(
          term: "Pitch",
          definition: "Highness or lowness",
          options: ["Highness or lowness", "Speed", "Beat", "Harmony"],
          correctIndex: 0),
      Flashcard(
          term: "Rhythm",
          definition: "Pattern of beats",
          options: ["Pattern of beats", "Melody", "Tone", "Scale"],
          correctIndex: 0),
      Flashcard(
          term: "Harmony",
          definition: "Simultaneous notes",
          options: ["Simultaneous notes", "Single note", "Silence", "Drum"],
          correctIndex: 0),
      Flashcard(
          term: "Scale",
          definition: "Sequence of notes",
          options: ["Sequence of notes", "Random sounds", "Chord", "Rest"],
          correctIndex: 0),
      Flashcard(
          term: "Chord",
          definition: "Three or more notes",
          options: ["Three or more notes", "Single pitch", "Beat", "Tempo"],
          correctIndex: 0),
      Flashcard(
          term: "Clef",
          definition: "Sets pitch range",
          options: [
            "Sets pitch range",
            "Sets volume",
            "Marks time",
            "Ends piece"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Dynamics",
          definition: "Volume levels",
          options: ["Volume levels", "Speed changes", "Note length", "Key"],
          correctIndex: 0),
      Flashcard(
          term: "Key",
          definition: "Tonal center",
          options: ["Tonal center", "Instrument", "Rhythm", "Pause"],
          correctIndex: 0),
      Flashcard(
          term: "Measure",
          definition: "Group of beats",
          options: ["Group of beats", "Single note", "Pitch shift", "Silence"],
          correctIndex: 0),
    ],
  ),
  StudySet(
    title: "Art History",
    flashcards: [
      Flashcard(
          term: "Renaissance",
          definition: "Rebirth of art",
          options: ["Rebirth of art", "Dark ages", "Modern era", "Abstract"],
          correctIndex: 0),
      Flashcard(
          term: "Impressionism",
          definition: "Light and color focus",
          options: ["Light and color focus", "Realism", "Cubism", "Surrealism"],
          correctIndex: 0),
      Flashcard(
          term: "Cubism",
          definition: "Geometric shapes",
          options: ["Geometric shapes", "Soft edges", "Nature", "Portraits"],
          correctIndex: 0),
      Flashcard(
          term: "Baroque",
          definition: "Dramatic and ornate",
          options: ["Dramatic and ornate", "Simple", "Minimal", "Flat"],
          correctIndex: 0),
      Flashcard(
          term: "Surrealism",
          definition: "Dream-like scenes",
          options: [
            "Dream-like scenes",
            "Realistic",
            "Historical",
            "Classical"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Gothic",
          definition: "Pointed arches",
          options: [
            "Pointed arches",
            "Round domes",
            "Bright colors",
            "Flat roofs"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Modernism",
          definition: "Break from tradition",
          options: [
            "Break from tradition",
            "Old styles",
            "Religious",
            "Copying"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Expressionism",
          definition: "Emotional distortion",
          options: [
            "Emotional distortion",
            "Calm realism",
            "Geometric",
            "Natural"
          ],
          correctIndex: 0),
      Flashcard(
          term: "Romanticism",
          definition: "Emotion and nature",
          options: ["Emotion and nature", "Logic", "Machines", "Order"],
          correctIndex: 0),
      Flashcard(
          term: "Realism",
          definition: "Everyday life",
          options: ["Everyday life", "Fantasy", "Abstract", "Dreams"],
          correctIndex: 0),
    ],
  ),
];

// Function to upload all study sets to globalStudySets
Future<void> uploadGlobalStudySets() async {
  // asynch function (no return value)
  final firestore = FirebaseFirestore
      .instance; // Gets the Firestore instance (access firestore database)
  for (final studySet in studySets) {
    // Iterates over each study set in the studySets list
    final studySetRef =
        firestore // Defines a reference to a document in globalStudySets
            .collection(
                'globalStudySets') // gets the globalStudySets collection
            .doc(studySet.title
                .toLowerCase()
                .replaceAll(' ', '_')); // Creates a unique doc ID from title

    await studySetRef // await pauses until the Future is done
        .set(studySet.toFirestore()); // Saves the study set data to Firestore
    final flashcardsRef = studySetRef
        .collection('flashcards'); // Stores the flashcards subcollection
    for (var i = 0; i < studySet.flashcards.length; i++) {
      // Loops through each flashcard in the study set
      await flashcardsRef // Saves each flashcard
          .doc('flashcard_$i') // flashcard name using index
          .set(studySet.flashcards[i]
              .toFirestore()); // Converts flashcard to Firestore format and saves to Firestore
    }
  }
}

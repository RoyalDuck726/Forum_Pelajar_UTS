import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forum Diskusi Pelajar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey[700]!,
          secondary: Colors.blueGrey[500]!,
          surface: Colors.blueGrey[900]!,
          background: Colors.blueGrey[800]!,
        ),
        scaffoldBackgroundColor: Colors.blueGrey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
        ),
        cardTheme: CardTheme(
          color: Colors.blueGrey[700],
        ),
      ),
      home: const ForumHomePage(title: 'Forum Diskusi Pelajar'),
    );
  }
}

class ForumHomePage extends StatefulWidget {
  const ForumHomePage({super.key, required this.title});

  final String title;

  @override
  State<ForumHomePage> createState() => _ForumHomePageState();
}

class _ForumHomePageState extends State<ForumHomePage> {
  final Map<String, List<String>> categories = {
    'Matematika': ['Kalkulus', 'Matriks', 'Aljabar'],
    'Sains': ['Fisika', 'Biologi', 'Kimia'],
    'Bahasa': ['Bahasa Inggris', 'Bahasa Indonesia', 'Bahasa China'],
  };
  final List<Question> questions = [];

  void _showNewQuestionDialog(String mainCategory) {
    String newQuestion = '';
    String selectedSubcategory = categories[mainCategory]![0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Buat Pertanyaan Baru - $mainCategory'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newQuestion = value;
                    },
                    decoration: InputDecoration(hintText: "Tulis pertanyaan Anda di sini"),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedSubcategory,
                    items: categories[mainCategory]!.map((String subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSubcategory = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Batal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (newQuestion.isNotEmpty) {
                      this.setState(() {
                        questions.add(Question(
                          text: newQuestion,
                          mainCategory: mainCategory,
                          subcategory: selectedSubcategory,
                          poster: 'User', // Ganti dengan sistem autentikasi yang sebenarnya
                        ));
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: TabBar(
            tabs: categories.keys.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.keys.map((mainCategory) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _showNewQuestionDialog(mainCategory),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange[700],
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Buat Pertanyaan Baru',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                ...questions
                    .where((q) => q.mainCategory == mainCategory)
                    .map((question) => QuestionTile(
                          question: question,
                          onUpvote: () {
                            setState(() {
                              question.toggleUpvote();
                            });
                          },
                          onDownvote: () {
                            setState(() {
                              question.toggleDownvote();
                            });
                          },
                          onPinAnswer: (Answer answer) {
                            setState(() {
                              question.togglePinAnswer(answer);
                            });
                          },
                          onAddAnswer: (String newAnswerText) {
                            setState(() {
                              question.addAnswer(Answer(
                                text: newAnswerText,
                                poster: 'User', // Ganti dengan sistem autentikasi yang sebenarnya
                              ));
                            });
                          },
                          onAnswerUpvote: (Answer answer) {
                            setState(() {
                              answer.toggleUpvote();
                            });
                          },
                          onAnswerDownvote: (Answer answer) {
                            setState(() {
                              answer.toggleDownvote();
                            });
                          },
                        ))
                    .toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final String mainCategory;
  final String subcategory;
  final String poster;
  int upvotes = 0;
  int downvotes = 0;
  List<Answer> answers = [];
  Answer? pinnedAnswer;
  String? userVote; // 'up', 'down', atau null

  Question({
    required this.text,
    required this.mainCategory,
    required this.subcategory,
    required this.poster,
  });

  void toggleUpvote() {
    if (userVote == 'up') {
      upvotes--;
      userVote = null;
    } else {
      if (userVote == 'down') {
        downvotes--;
      }
      upvotes++;
      userVote = 'up';
    }
  }

  void toggleDownvote() {
    if (userVote == 'down') {
      downvotes--;
      userVote = null;
    } else {
      if (userVote == 'up') {
        upvotes--;
      }
      downvotes++;
      userVote = 'down';
    }
  }

  void addAnswer(Answer answer) {
    answers.add(answer);
  }

  void pinAnswer(Answer answer) {
    pinnedAnswer = answer;
  }

  void togglePinAnswer(Answer answer) {
    if (pinnedAnswer == answer) {
      pinnedAnswer = null;
    } else {
      pinnedAnswer = answer;
    }
  }
}

class Answer {
  final String text;
  final String poster;
  int upvotes = 0;
  int downvotes = 0;
  String? userVote; // 'up', 'down', atau null

  Answer({required this.text, required this.poster});

  void toggleUpvote() {
    if (userVote == 'up') {
      upvotes--;
      userVote = null;
    } else {
      if (userVote == 'down') {
        downvotes--;
      }
      upvotes++;
      userVote = 'up';
    }
  }

  void toggleDownvote() {
    if (userVote == 'down') {
      downvotes--;
      userVote = null;
    } else {
      if (userVote == 'up') {
        upvotes--;
      }
      downvotes++;
      userVote = 'down';
    }
  }
}

class QuestionTile extends StatelessWidget {
  final Question question;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final Function(Answer) onPinAnswer;
  final Function(String) onAddAnswer;
  final Function(Answer) onAnswerUpvote;
  final Function(Answer) onAnswerDownvote;

  const QuestionTile({
    Key? key,
    required this.question,
    required this.onUpvote,
    required this.onDownvote,
    required this.onPinAnswer,
    required this.onAddAnswer,
    required this.onAnswerUpvote,
    required this.onAnswerDownvote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol upvote dan downvote
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: question.userVote == 'up' ? Colors.green : Colors.grey,
                    ),
                    onPressed: onUpvote,
                  ),
                  Text('${question.upvotes}'),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_downward,
                      color: question.userVote == 'down' ? Colors.red : Colors.grey,
                    ),
                    onPressed: onDownvote,
                  ),
                  Text('${question.downvotes}'),
                ],
              ),
              // Konten pertanyaan
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Posted by: ${question.poster}'),
                      Text('Category: ${question.mainCategory} - ${question.subcategory}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (question.pinnedAnswer != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
              child: Card(
                color: Colors.blueGrey[600],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pinned Answer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          IconButton(
                            icon: Icon(Icons.push_pin, color: Colors.white),
                            onPressed: () => onPinAnswer(question.pinnedAnswer!),
                          ),
                        ],
                      ),
                      Text(question.pinnedAnswer!.text, style: TextStyle(color: Colors.white)),
                      Text('By: ${question.pinnedAnswer!.poster}', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text('Answers:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...question.answers.map((answer) => Padding(
                padding: const EdgeInsets.only(left: 24, right: 8, top: 4, bottom: 4),
                child: AnswerTile(
                  answer: answer,
                  onUpvote: () => onAnswerUpvote(answer),
                  onDownvote: () => onAnswerDownvote(answer),
                  onPin: question.poster == 'User' ? () => onPinAnswer(answer) : null,
                  isPinned: question.pinnedAnswer == answer,
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_comment, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Jawaban',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              onPressed: () {
                _showAddAnswerDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAnswerDialog(BuildContext context) {
    String newAnswer = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Jawaban'),
          content: TextField(
            onChanged: (value) {
              newAnswer = value;
            },
            decoration: InputDecoration(hintText: "Tulis jawaban Anda di sini"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Batal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Kirim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              onPressed: () {
                if (newAnswer.isNotEmpty) {
                  onAddAnswer(newAnswer);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class AnswerTile extends StatelessWidget {
  final Answer answer;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback? onPin;
  final bool isPinned;

  const AnswerTile({
    Key? key,
    required this.answer,
    required this.onUpvote,
    required this.onDownvote,
    this.onPin,
    this.isPinned = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol upvote dan downvote
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    color: answer.userVote == 'up' ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onUpvote,
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                Text('${answer.upvotes}', style: TextStyle(fontSize: 12)),
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    color: answer.userVote == 'down' ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onDownvote,
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                Text('${answer.downvotes}', style: TextStyle(fontSize: 12)),
              ],
            ),
            SizedBox(width: 8),
            // Konten jawaban
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(answer.text, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text('By: ${answer.poster}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            // Tombol pin (jika ada)
            if (onPin != null)
              IconButton(
                icon: Icon(Icons.push_pin, color: isPinned ? Colors.blue : Colors.grey, size: 20),
                onPressed: onPin,
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
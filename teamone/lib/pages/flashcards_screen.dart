import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:TeamOne/services/supabase_config.dart';
import 'package:flutter/material.dart';

class FlashcardsScreen extends StatefulWidget {
  final String topic;

  FlashcardsScreen({required this.topic});

  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  SupabaseClient client = Supabase.instance.client;
  int currentCardIndex = 0;
  int timerSeconds = 30;
  List<String> cards = [];
  List<List<String>> options = [];
  List<String> questions = [];
  String? selectedOption;
  Timer? timer;
  int TotalScore = 0;
  List<String> answer = [];
  Map<int, String> correctAnswers = {};
  String? currentAnswer = '';
  List<int> questionId = [];
  List<int> mark = [];
  List<String> selectedOptionList = [];
  int question_no = 0;

  @override
  void initState() {
    super.initState();
    cards = generateRandomCards(5); // Generate 5 random cards
    generateOptions();
    generateQuestions();
    generateAnswer();
    startTimer();
  }

  void startTimer() {
  timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          timer.cancel();
          if (selectedOption == null) {
            selectedOption = '';
          }
          goToNextCard();
        }
      });
    } else {
      timer.cancel();
    }
  });
}


  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer in the dispose method
    super.dispose();
  }

  List<String> generateRandomCards(int count) {
    List<String> randomCards = [];
    for (int i = 0; i < count; i++) {
      randomCards.add('Question ${i + 1}');
    }
    return randomCards;
  }

  Future<void> generateQuestions() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('quiz')
        .select('question')
        .eq('topic_tag', widget.topic)
        .execute();
    final List<dynamic> data = response.data;
    questions = data.map<String>((row) => row['question'].toString()).toList();
  }

  Future<void> generateOptions() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('quiz')
        .select('option1,option2,option3')
        .eq('topic_tag', widget.topic)
        .execute();
    final List<dynamic> data = response.data;
    options = data
        .map<List<String>>((row) => [
              row['option1'].toString(),
              row['option2'].toString(),
              row['option3'].toString()
            ])
        .toList();
  }

  Future<void> generateAnswer() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('quiz')
        .select('answer')
        .eq('topic_tag', widget.topic)
        .execute();
    final List<dynamic> data = response.data;
    answer = data.map<String>((row) => row['answer'].toString()).toList();
    for (int i = 0; i < data.length; i++) {
      correctAnswers[i] = data[i]['answer'].toString();
    }
  }

  void showAnswers() {
    
    addToSharedPrefferences('TotalScore');
    addToSharedPrefferences('addSelectedOption');
    addScoreIfNotAdded();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            height: 370, // Set the desired height here
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Answers(Total Score: ${TotalScore}/5)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(
                        'Question ${index + 1}: ${correctAnswers[index]}',
                        style: TextStyle(fontSize: 16),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchQuestionId() async {
    final response = await client
        .from('quiz')
        .select('id')
        .eq('topic_tag', widget.topic)
        .execute();
    final List<dynamic> data = response.data;
    final questionId = data.map<int>((row) => row['id'] as int).toList();
    final question_no = questionId[currentCardIndex];
  }

//logic to repeat the question at the next given time

void addScoreIfNotAdded() async {
    fetchQuestionId();



    if (question_no == null) {
      // Handle error
      return;
    }
    final List<int> data = questionId;

    if (data.isEmpty) {
Future mark = await getFromSharedPreferences('marksPerQuestion${currentCardIndex}');
      final insertResponse = await client.from('stats').insert({
        'question_no': question_no,
        'mark': mark,
      }).execute();
      if (insertResponse.status != 200) {
        // Handle error
        return;
      }
    }
  }

  //this is for storing the answers given by the user in each stage to the shared preferences before clearning it
  void addToSharedPrefferences(String action) async {
    final prefs = await SharedPreferences.getInstance();
    switch (action) {
      case 'addSelectedOption':
        prefs.setStringList('selectedOption', selectedOptionList);
        break;
      case 'marksPerQuestion':
          prefs.setInt('marksPerQuestion${currentCardIndex}', mark[currentCardIndex]);
        break;
      case 'TotalScore':
        prefs.setInt('TotalScore', TotalScore);
        break;
      default:
        break;
    }
  }

  Future<dynamic> getFromSharedPreferences(String action) async {
    final prefs = await SharedPreferences.getInstance();
    switch (action) {
      case 'selectedOption':
        return prefs.getString('selectedOption')!;
      case 'marksPerQuestion':
        List<int> marksList = [];
        for (int i = 0; i < mark.length; i++) {
          int? markValue = prefs.getInt('marksPerQuestion$i');
          if (markValue != null) {
            marksList.add(markValue);
          }
        }
        return marksList;
      case 'TotalScore':
        return prefs.getInt('TotalScore') ?? 0;
      default:
        return '';
    }
  }

  void goToNextCard() {
    addScoreIfNotAdded();
    if (currentCardIndex == cards.length - 1) {
      showAnswers(); // Show answers before navigating to the next screen
    } else {
      setState(() {
        currentCardIndex++;
        selectedOption = null;
        timerSeconds = 30;
        startTimer();
      });
    }
  }

  String formatTime(int seconds) {
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = cards.isNotEmpty ? cards[currentCardIndex] : '';
    final currentOptions = options.isNotEmpty ? options[currentCardIndex] : [];
    final currentQuestion =
        questions.isNotEmpty ? questions[currentCardIndex] : '';
    final currentAnswer = answer.isNotEmpty ? answer[currentCardIndex] : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic), // Display topic as the app bar title
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 26, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${currentCardIndex + 1} of ${cards.length}',
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(height: 8),
                Text(
                  '$currentQuestion',
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(height: 8),
                Text(
                  'Answer the question within 30 seconds',
                  style: TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: timerSeconds / 30,
                            strokeWidth: 4,
                          ),
                          Text(
                            formatTime(timerSeconds),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Options',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          for (String option
                              in currentOptions) // Display all the options
                            RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: selectedOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedOption = value;
                                  if (selectedOption == currentAnswer) {
                                    TotalScore = TotalScore + 1;
                                    mark.add(0);
                                    addToSharedPrefferences('marksPerQuestion');
                                  } else {
                                    mark.add(
                                        1); //here we are storing the marks for each question
                                        addToSharedPrefferences('marksPerQuestion');
                                  }
                                  selectedOptionList.add(selectedOption!);
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      goToNextCard();
                    },
                    child: Text('Next Question'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

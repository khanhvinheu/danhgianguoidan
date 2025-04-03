import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  String? _satisfaction;
  TextEditingController _feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitFeedback() async {
    if (_satisfaction == null || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn mức độ hài lòng và nhập góp ý!')),
      );
    } else {
      try {
        await _firestore.collection('feedbacks').add({
          'satisfaction': _satisfaction,
          'feedback': _feedbackController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _pageController.animateToPage(
          2,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xảy ra lỗi khi gửi góp ý!')));
      }
    }
  }

  void _goToFeedbackPage() {
    if (_satisfaction != null) {
      _pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn mức độ hài lòng!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GÓP Ý NGƯỜI DÂN',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 31, 44, 52),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.goNamed(RouterName.splash);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              context.goNamed(RouterName.chart);
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          FeedbackFormPage(
            onNext: _goToFeedbackPage,
            satisfaction: _satisfaction,
            onSatisfactionChange: (value) {
              setState(() {
                _satisfaction = value;
              });
            },
          ),
          FeedbackInputPage(
            feedbackController: _feedbackController,
            onSubmit: _submitFeedback,
          ),
          ThankYouPage(
            satisfaction: _satisfaction,
            feedback: _feedbackController.text,
          ),
        ],
      ),
    );
  }
}

// Bước 1: Chọn mức độ hài lòng
class FeedbackFormPage extends StatelessWidget {
  final String? satisfaction;
  final Function(String?) onSatisfactionChange;
  final VoidCallback onNext;

  const FeedbackFormPage({
    Key? key,
    required this.onSatisfactionChange,
    required this.onNext,
    required this.satisfaction,
  }) : super(key: key);

  Widget _buildSatisfactionIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () => onSatisfactionChange(label),
      child: Column(
        children: [
          Icon(
            icon,
            size: 60,
            color: satisfaction == label ? Colors.blue : Colors.grey,
          ),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bước 1: Chọn mức độ hài lòng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSatisfactionIcon(
              Icons.sentiment_very_satisfied,
              'Rất hài lòng',
            ),
            _buildSatisfactionIcon(Icons.sentiment_satisfied, 'Hài lòng'),
            _buildSatisfactionIcon(
              Icons.sentiment_dissatisfied,
              'Không hài lòng',
            ),
            _buildSatisfactionIcon(
              Icons.sentiment_very_dissatisfied,
              'Tức giận',
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(onPressed: onNext, child: Text('Tiếp theo')),
      ],
    );
  }
}

// Bước 2: Nhập góp ý (Hỗ trợ giọng nói)
class FeedbackInputPage extends StatefulWidget {
  final TextEditingController feedbackController;
  final VoidCallback onSubmit;

  const FeedbackInputPage({
    Key? key,
    required this.feedbackController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _FeedbackInputPageState createState() => _FeedbackInputPageState();
}

class _FeedbackInputPageState extends State<FeedbackInputPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              widget.feedbackController.text = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          partialResults: true,
          onSoundLevelChange: (level) => print("Sound level: $level"),
          cancelOnError: true,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition not available!')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bước 2: Nhập góp ý',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: widget.feedbackController,
              decoration: InputDecoration(
                hintText: 'Nhập góp ý hoặc bấm mic...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
           GestureDetector(
              onTap: _toggleListening,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: Colors.grey, // Mic icon color when not listening
                  end: _isListening ? Colors.red : Colors.grey, // Mic icon color when listening
                ),
                duration: Duration(milliseconds: 300), // Duration of the transition
                builder: (context, color, child) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 40, // You can adjust the size
                      ),
                      color: color, // Animated color change
                      onPressed: _toggleListening,
                    ),
                  );
                },
              ),),
            ElevatedButton(
              onPressed: widget.onSubmit,
              child: Text('Gửi góp ý'),
            ),
          ],
        ),
      ),
    );
  }
}

// Bước 3: Cảm ơn
class ThankYouPage extends StatelessWidget {
  final String? satisfaction;
  final String feedback;

  const ThankYouPage({
    Key? key,
    required this.satisfaction,
    required this.feedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      context.goNamed(RouterName.splash);
    });
    return Center(
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/thank.json',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            repeat: true, // Set to false to play only once
            reverse: true, // Play in reverse
            animate: true, // Auto-play animation
          ),
          Text(
            'Cảm ơn bạn đã gửi góp ý!',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

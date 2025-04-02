import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  String? _satisfaction;
  TextEditingController _feedbackController = TextEditingController();

  // Hàm để điều hướng sang màn "Cảm ơn" sau khi gửi góp ý
  void _submitFeedback() {
    if (_satisfaction == null || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn mức độ hài lòng và nhập góp ý!')),
      );
    } else {
      // Điều hướng đến trang cảm ơn (page 2)
      _pageController.animateToPage(
        2, // Điều hướng đến trang cảm ơn (page 2)
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Hàm để chuyển sang màn góp ý (page 1) sau khi chọn mức độ hài lòng
  void _goToFeedbackPage() {
    if (_satisfaction != null) {
      _pageController.animateToPage(
        1, // Điều hướng đến trang góp ý (page 1)
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
      ),
      body: PageView(
        controller: _pageController,
        children: [
          // Màn đánh giá
          FeedbackFormPage(
            onNext:
                _goToFeedbackPage, // Chuyển sang màn góp ý khi chọn mức độ hài lòng
            satisfaction: _satisfaction,
            onSatisfactionChange: (value) {
              setState(() {
                _satisfaction = value;
              });
            },
          ),
          // Màn góp ý
          FeedbackInputPage(
            feedbackController: _feedbackController,
            onSubmit: _submitFeedback, // Gửi góp ý và chuyển sang màn cảm ơn
          ),
          // Màn cảm ơn
          ThankYouPage(
            satisfaction: _satisfaction,
            feedback: _feedbackController.text,
          ),
        ],
      ),
    );
  }
}

// Màn đánh giá (Bước 1)
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

  // Hàm để hiển thị các biểu tượng mặt cười
  Widget _buildSatisfactionIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () => onSatisfactionChange(label),
      child: Column(
        children: [
          Icon(
            icon,
            size: 100,
            color: satisfaction == label ? Colors.blue : Colors.grey,
          ),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước 1: Chọn mức độ hài lòng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40,),
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
          Center(
            child: ElevatedButton(
              onPressed: onNext, // Chuyển sang bước 2 khi nhấn "Tiếp theo"
              child: Text('Tiếp theo'),
            ),
          ),
        ],
      ),
    );
  }
}

// Màn góp ý (Bước 2)
class FeedbackInputPage extends StatelessWidget {
  final TextEditingController feedbackController;
  final VoidCallback onSubmit;

  const FeedbackInputPage({
    Key? key,
    required this.feedbackController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Cho phép cuộn nếu quá nhiều nội dung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bước 2: Nhập góp ý',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: 'Nhập góp ý của bạn...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: onSubmit,
                child: Text('Gửi góp ý'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Màn cảm ơn (Bước 3)
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Cho phép cuộn nếu quá nhiều nội dung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cảm ơn bạn đã gửi góp ý!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Mức độ hài lòng: $satisfaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Góp ý của bạn: $feedback', style: TextStyle(fontSize: 16)),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Quay lại màn hình chính
                },
                child: Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

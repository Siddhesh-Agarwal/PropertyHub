import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/services/auth_services.dart';
import '/services/db_service.dart';
import '/ui/button.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _loading = false;
  bool _hasSubmitted = false;
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  String? get email => authService.value.user?.email;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    setState(() => _loading = true);
    try {
      if (email == null) return;
      final doc = await db.collection("feedbacks").doc(email).get();
      if (mounted) {
        setState(() {
          _hasSubmitted = doc.exists;
        });
      }
    } catch (e) {
      if (mounted) errorSnack(context, "Error checking feedback status: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      errorSnack(context, 'Please rate your experience.');
      return;
    }
    setState(() => _loading = true);
    try {
      await db.collection("feedbacks").doc(email).set({
        "rating": _rating,
        "feedback": _feedbackController.text,
        "timestamp": DateTime.now(),
      });
      if (mounted) {
        setState(() {
          _hasSubmitted = true;
        });
        successSnack(context, 'Feedback submitted successfully!');
      }
    } catch (e) {
      if (mounted) errorSnack(context, "Error submitting feedback: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return loading();

    if (_hasSubmitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Feedback')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                'Thank you for your feedback!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your feedback has been submitted.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Rate your experience:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1.0,
                  maxRating: 5.0,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Optional Feedback:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your feedback here...',
                ),
              ),
              const SizedBox(height: 20),
              OutlineButton(
                onPressed: _submitFeedback,
                label: 'Submit Feedback',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

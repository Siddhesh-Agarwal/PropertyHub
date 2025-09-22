import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/services/auth_services.dart';
import '/services/constants.dart';
import '/services/db_service.dart';
import '/ui/button.dart';
import '/ui/loading.dart';
import '/ui/snackbar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class Feedback {
  final String email;
  final double rating;
  final String feedback;
  final DateTime timestamp;

  Feedback({
    required this.email,
    required this.rating,
    required this.feedback,
    required this.timestamp,
  });
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _loading = false;
  bool _hasSubmitted = false;
  List<Feedback> _feedbacks = [];
  String? get email => authService.value.user?.email;

  UserMode? _userMode;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      _loading = true;
    });
    final userMode = authService.value.userMode;

    if (userMode == null) {
      authService.value.signOut();
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _userMode = userMode;
    });

    if (userMode == UserMode.user) {
      checkHasSubmitted();
    } else {
      fetchFeedbacks();
    }
    setState(() {
      _loading = false;
    });
  }

  void checkHasSubmitted() async {
    final querySnapshot = await db.collection("feedbacks").doc(email).get();
    setState(() {
      _hasSubmitted = querySnapshot.exists;
    });
  }

  void fetchFeedbacks() async {
    final querySnapshot = await db.collection("feedbacks").get();
    setState(() {
      _feedbacks =
          querySnapshot.docs.map((doc) {
            return Feedback(
              email: doc.id,
              rating: doc["rating"],
              feedback: doc["feedback"],
              timestamp: (doc["timestamp"]).toDate(),
            );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return loading();
    }
    switch (_userMode) {
      case UserMode.admin:
        return AdminViewFeedbackPage(feedbacks: _feedbacks);
      case UserMode.user:
        return UserViewFeedbackPage(email: email!, hasSubmitted: _hasSubmitted);
      default:
        return Container();
    }
  }
}

class AdminViewFeedbackPage extends StatelessWidget {
  final List<Feedback> feedbacks;

  const AdminViewFeedbackPage({super.key, required this.feedbacks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback (Admin View)')),
      body:
          feedbacks.isEmpty
              ? const Center(
                child: Text(
                  'No feedback available.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : Center(
                child: ListView(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbacks[index];
                        return ListTile(
                          title: Text(
                            'Rating: ${feedback.rating.toInt().toString()}/5',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: Text(feedback.feedback),
                          subtitle: Text(feedback.email),
                          trailing: Text(
                            feedback.timestamp.toString().split(' ')[0],
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ListTileStyle.list,
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}

class UserViewFeedbackPage extends StatefulWidget {
  final String email;
  final bool hasSubmitted;

  const UserViewFeedbackPage({
    super.key,
    required this.email,
    required this.hasSubmitted,
  });

  @override
  State<UserViewFeedbackPage> createState() => _UserViewFeedbackPageState();
}

class _UserViewFeedbackPageState extends State<UserViewFeedbackPage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _hasSubmitted = widget.hasSubmitted;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      errorSnack(context, 'Please rate your experience.');
      return;
    }
    await db.collection("feedbacks").doc(widget.email).set({
      "rating": _rating,
      "feedback": _feedbackController.text,
      "timestamp": DateTime.now(),
    });
    setState(() {
      _hasSubmitted = true;
    });
    if (!mounted) return;
    successSnack(context, 'Feedback submitted successfully!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {
                  Navigator.pop(context);
                },
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
                ignoreGestures: _hasSubmitted,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
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
              readOnly: _hasSubmitted,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your feedback here...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            OutlineButton(onPressed: _submitFeedback, label: 'Submit Feedback'),
          ],
        ),
      ),
    );
  }
}

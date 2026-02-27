class FeedbackModel {
  final String email;
  final double rating;
  final String feedback;
  final DateTime timestamp;

  FeedbackModel({
    required this.email,
    required this.rating,
    required this.feedback,
    required this.timestamp,
  });
}

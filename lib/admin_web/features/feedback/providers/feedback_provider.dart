import 'dart:async';
import 'package:flutter/material.dart';
import 'package:royal_tint/admin_web/features/feedback/models/feedback_item.dart';
import 'package:royal_tint/admin_web/features/feedback/services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _service = FeedbackService();

  bool isLoading = false;
  String? error;
  List<FeedbackItem> feedbacks = [];
  StreamSubscription<List<FeedbackItem>>? _subscription;

  void loadFeedback(String? branchID) {
    isLoading = true;
    error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.streamFeedback(branchID: branchID).listen(
      (data) {
        feedbacks = data;
        isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        error = err.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> removeFeedback(String id) async {
    try {
      await _service.deleteFeedback(id);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

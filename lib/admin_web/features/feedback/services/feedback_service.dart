import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/admin_web/features/feedback/models/feedback_item.dart';
import 'package:royal_tint/core/constants/firebase_constants.dart';

class FeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FeedbackItem>> streamFeedback({String? branchID}) {
    var ref = _db.collection(FirebaseConstants.feedbackCollection);
    Query query = ref;
    
    if (branchID != null && branchID.isNotEmpty) {
      query = query.where('branchID', isEqualTo: branchID);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) {
        return FeedbackItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      // Sort in memory to avoid requiring a composite index on Firestore
      items.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return items;
    });
  }

  Future<void> deleteFeedback(String id) async {
    await _db.collection(FirebaseConstants.feedbackCollection).doc(id).delete();
  }
}

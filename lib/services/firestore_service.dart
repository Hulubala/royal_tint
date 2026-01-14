import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic create document
  Future<void> createDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  // Generic read document
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Generic update document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Generic delete document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Query documents with filters
  Future<QuerySnapshot> queryDocuments({
    required String collection,
    List<QueryFilter>? filters,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _firestore.collection(collection);

    if (filters != null) {
      for (var filter in filters) {
        query = query.where(filter.field, isEqualTo: filter.value);
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  // Stream documents
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Stream specific document
  Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String docId,
  }) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }
}

class QueryFilter {
  final String field;
  final dynamic value;

  QueryFilter({required this.field, required this.value});
}
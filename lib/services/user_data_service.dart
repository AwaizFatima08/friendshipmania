import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

/// One saved verdict in a signed-in user's history.
class SavedReport {
  final String id;
  final String yourName;
  final String friendName;
  final int percent;
  final String bandTitle;
  final String bandEmoji;
  final DateTime? createdAt;

  const SavedReport({
    required this.id,
    required this.yourName,
    required this.friendName,
    required this.percent,
    required this.bandTitle,
    required this.bandEmoji,
    this.createdAt,
  });
}

/// Everything the app stores per user, behind an interface so screens and
/// tests never touch Firestore directly.
///
/// Data layout (locked down by `firestore.rules` to the owner only):
///   users/{uid}                  — display name, email, createdAt
///   users/{uid}/reports/{id}     — one document per saved verdict
abstract class UserDataService {
  Future<void> ensureProfile(AppUser user);

  Future<void> saveReport({
    required String uid,
    required String yourName,
    required String friendName,
    required int percent,
    required String bandTitle,
    required String bandEmoji,
    required Map<String, int> tagPercents,
  });

  Stream<List<SavedReport>> watchReports(String uid);

  Future<void> deleteReport(String uid, String reportId);

  /// Wipes the user's profile and every saved verdict (account deletion).
  Future<void> deleteAllUserData(String uid);
}

class FirestoreUserDataService implements UserDataService {
  FirestoreUserDataService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _reports(String uid) =>
      _userDoc(uid).collection('reports');

  @override
  Future<void> ensureProfile(AppUser user) {
    return _userDoc(user.uid).set({
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveReport({
    required String uid,
    required String yourName,
    required String friendName,
    required int percent,
    required String bandTitle,
    required String bandEmoji,
    required Map<String, int> tagPercents,
  }) {
    return _reports(uid).add({
      'yourName': yourName,
      'friendName': friendName,
      'percent': percent,
      'bandTitle': bandTitle,
      'bandEmoji': bandEmoji,
      'tagPercents': tagPercents,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<SavedReport>> watchReports(String uid) {
    return _reports(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data();
              return SavedReport(
                id: d.id,
                yourName: (m['yourName'] as String?) ?? '',
                friendName: (m['friendName'] as String?) ?? '',
                percent: (m['percent'] as num?)?.toInt() ?? 0,
                bandTitle: (m['bandTitle'] as String?) ?? '',
                bandEmoji: (m['bandEmoji'] as String?) ?? '🕵️',
                createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }

  @override
  Future<void> deleteReport(String uid, String reportId) =>
      _reports(uid).doc(reportId).delete();

  @override
  Future<void> deleteAllUserData(String uid) async {
    // Firestore batches cap at 500 operations, so wipe reports in chunks.
    while (true) {
      final snap = await _reports(uid).limit(400).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    await _userDoc(uid).delete();
  }
}

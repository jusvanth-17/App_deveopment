import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _initialized = false;
  static String? _userId;
  
  // Get the current Firestore instance
  static FirebaseFirestore get firestore => _firestore;
  
  // Get the current Auth instance
  static FirebaseAuth get auth => _auth;
  
  // Get the current user ID
  static String? get userId => _userId;
  
  // Initialize Firebase Auth (sign in anonymously)
  static Future<void> initializeAuth() async {
    if (_initialized) return;
    
    try {
      // Sign in anonymously
      final userCredential = await _auth.signInAnonymously();
      _userId = userCredential.user?.uid;
      _initialized = true;
      debugPrint("✅ Firebase Auth initialized with anonymous user: $_userId");
    } catch (e) {
      debugPrint("🔥 Error initializing Firebase Auth: $e");
      
      if (e.toString().contains("admin-restricted-operation")) {
        debugPrint("⚠️ IMPORTANT: You need to enable Anonymous Authentication in Firebase Console:");
        debugPrint("1. Go to Firebase Console > Authentication > Sign-in method");
        debugPrint("2. Enable 'Anonymous' provider");
      }
      
      // For development, create a mock user ID if auth fails
      _userId = 'dev-user-${DateTime.now().millisecondsSinceEpoch}';
      debugPrint("📝 Created development user ID: $_userId for offline testing");
      
      // Still mark as initialized to prevent repeated attempts
      _initialized = true;
    }
  }

  // Save syllabus to Firestore
  static Future<bool> saveSyllabus(
    String language, 
    String syllabusMarkdown, 
    {String? elaboratedSyllabusMarkdown}
  ) async {
    try {
      // Ensure we're authenticated
      await initializeAuth();
      
      if (_userId == null) {
        debugPrint("⚠️ Cannot save syllabus: No user ID available");
        return false;
      }
      
      final String docId = "$language-${DateTime.now().millisecondsSinceEpoch}";
      
      Map<String, dynamic> data = {
        'language': language,
        'syllabus_markdown': syllabusMarkdown,
        'userId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      // Add elaborated syllabus if provided
      if (elaboratedSyllabusMarkdown != null && elaboratedSyllabusMarkdown.isNotEmpty) {
        data['elaborated_syllabus_markdown'] = elaboratedSyllabusMarkdown;
      }
      
      await _firestore.collection('syllabuses').doc(docId).set(data);
      
      debugPrint("✅ Syllabus for $language stored in Firebase with ID: $docId");
      if (elaboratedSyllabusMarkdown != null && elaboratedSyllabusMarkdown.isNotEmpty) {
        debugPrint("✅ Elaborated syllabus also stored");
      }
      return true;
    } catch (e) {
      debugPrint("🔥 Error saving syllabus: $e");
      
      if (e.toString().contains("permission-denied")) {
        debugPrint("⚠️ IMPORTANT: You need to update Firestore Security Rules:");
        debugPrint("""
        // Add these rules in Firebase Console > Firestore Database > Rules:
        
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            // Allow anyone to read syllabuses
            match /syllabuses/{document=**} {
              allow read: if true;
              allow write: if request.auth != null;
            }
            
            // Other collections
            match /{document=**} {
              allow read, write: if request.auth != null;
            }
          }
        }
        """);
      }
      
      return false;
    }
  }

  // Save chat message to Firestore
  static Future<void> saveMessage(String sessionId, String message, String role) async {
    try {
      await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .add({
        'text': message,
        'role': role, // 'user' or 'assistant'
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving message: $e');
      rethrow;
    }
  }

  // Get chat history for a session
  static Future<List<Map<String, dynamic>>> getChatHistory(String sessionId) async {
    try {
      final snapshot = await _firestore
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'text': doc.data()['text'],
                'role': doc.data()['role'],
                'timestamp': doc.data()['timestamp'],
              })
          .toList();
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }

  // Get syllabus details for a session
  static Future<Map<String, dynamic>?> getSyllabus(String sessionId) async {
    try {
      final doc = await _firestore.collection('sessions').doc(sessionId).get();
      if (doc.exists) {
        return {
          'language': doc.data()?['language'],
          'levels': doc.data()?['levels'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting syllabus: $e');
      return null;
    }
  }

  // -- User State Persistence Methods --

  // Save user app state to restore later
  static Future<bool> saveUserAppState({
    required String selectedLanguage,
    required int currentLessonIndex,
    required List<String> messages,
  }) async {
    try {
      // Save to shared preferences for quick local access
      final prefs = await SharedPreferences.getInstance();
      
      // Store the state
      await prefs.setString('selectedLanguage', selectedLanguage);
      await prefs.setInt('currentLessonIndex', currentLessonIndex);
      await prefs.setStringList('messages', messages);
      await prefs.setBool('hasState', true);

      // Also save to Firestore if we have authentication
      if (_userId != null) {
        await _firestore.collection('userStates').doc(_userId).set({
          'selectedLanguage': selectedLanguage,
          'currentLessonIndex': currentLessonIndex,
          'messages': messages,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      debugPrint("✅ User app state saved successfully");
      return true;
    } catch (e) {
      debugPrint("🔥 Error saving user app state: $e");
      return false;
    }
  }

  // Check if user has saved state
  static Future<bool> hasUserAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('hasState') ?? false;
    } catch (e) {
      debugPrint("🔥 Error checking user app state: $e");
      return false;
    }
  }

  // Get user app state
  static Future<Map<String, dynamic>?> getUserAppState() async {
    try {
      // First try to get from local storage
      final prefs = await SharedPreferences.getInstance();
      final hasState = prefs.getBool('hasState') ?? false;
      
      if (hasState) {
        final selectedLanguage = prefs.getString('selectedLanguage');
        final currentLessonIndex = prefs.getInt('currentLessonIndex');
        final messages = prefs.getStringList('messages');
        
        if (selectedLanguage != null && currentLessonIndex != null && messages != null) {
          debugPrint("✅ User app state retrieved from local storage");
          return {
            'selectedLanguage': selectedLanguage,
            'currentLessonIndex': currentLessonIndex,
            'messages': messages,
          };
        }
      }
      
      // If not available locally and we have a user ID, try Firestore
      if (_userId != null) {
        final docSnapshot = await _firestore.collection('userStates').doc(_userId).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          
          // Save to local storage for next time
          if (data['selectedLanguage'] != null && data['currentLessonIndex'] != null && data['messages'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('selectedLanguage', data['selectedLanguage']);
            await prefs.setInt('currentLessonIndex', data['currentLessonIndex']);
            await prefs.setStringList('messages', List<String>.from(data['messages']));
            await prefs.setBool('hasState', true);
            
            debugPrint("✅ User app state retrieved from Firestore and saved locally");
            return {
              'selectedLanguage': data['selectedLanguage'],
              'currentLessonIndex': data['currentLessonIndex'],
              'messages': List<String>.from(data['messages']),
            };
          }
        }
      }
      
      debugPrint("⚠️ No saved user app state found");
      return null;
    } catch (e) {
      debugPrint("🔥 Error retrieving user app state: $e");
      return null;
    }
  }

  // Clear user app state
  static Future<bool> clearUserAppState() async {
    try {
      // Clear from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selectedLanguage');
      await prefs.remove('currentLessonIndex');
      await prefs.remove('messages');
      await prefs.setBool('hasState', false);
      
      // Clear from Firestore if we have a user ID
      if (_userId != null) {
        await _firestore.collection('userStates').doc(_userId).delete();
      }
      
      debugPrint("✅ User app state cleared successfully");
      return true;
    } catch (e) {
      debugPrint("🔥 Error clearing user app state: $e");
      return false;
    }
  }
}

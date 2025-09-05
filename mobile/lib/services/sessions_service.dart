import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/planner_models.dart';
import 'api_service.dart';
import 'user_service.dart';

class SessionsService {
  static const String _localKey = 'user_sessions';
  
  final ApiService _apiService;
  
  SessionsService({
    required ApiService apiService,
  }) : _apiService = apiService;

  /// Load sessions from backend first, fallback to local storage
  Future<List<LiveSession>> loadSessions() async {
    try {
      print('[SessionsService] Loading sessions from backend...');
      final username = await UserService.getUsername();
      if (username != null) {
        final response = await _apiService.get('/user-sessions/load/$username');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> sessionsJson = data['sessions'] ?? [];
          final sessions = sessionsJson.map((json) => LiveSession.fromJson(json)).toList();
          print('[SessionsService] Loaded ${sessions.length} sessions from backend');
          
          // Update local storage with backend data
          await _saveToLocal(sessions);
          return sessions;
        }
      }
    } catch (e) {
      print('[SessionsService] Failed to load from backend: $e');
    }
    
    // Fallback to local storage
    print('[SessionsService] Loading sessions from local storage...');
    return await _loadFromLocal();
  }

  /// Save sessions to backend and local storage
  Future<void> saveSessions(List<LiveSession> sessions) async {
    // Save to local storage first (for immediate persistence)
    await _saveToLocal(sessions);
    
    // Then save to backend
    try {
      print('[SessionsService] Saving ${sessions.length} sessions to backend...');
      final username = await UserService.getUsername();
      if (username != null) {
        final sessionsJson = sessions.map((session) => session.toJson()).toList();
        
        final response = await _apiService.post('/user-sessions/save/$username', {
          'sessions': sessionsJson,
        });
        
        if (response.statusCode == 200) {
          print('[SessionsService] Successfully saved sessions to backend');
        } else {
          print('[SessionsService] Failed to save to backend: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('[SessionsService] Error saving to backend: $e');
    }
  }

  /// Save sessions to local storage only
  Future<void> _saveToLocal(List<LiveSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = sessions.map((session) => session.toJson()).toList();
      await prefs.setString(_localKey, json.encode(sessionsJson));
      print('[SessionsService] Saved ${sessions.length} sessions to local storage');
    } catch (e) {
      print('[SessionsService] Error saving to local storage: $e');
    }
  }

  /// Load sessions from local storage only
  Future<List<LiveSession>> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsData = prefs.getString(_localKey);
      
      if (sessionsData != null) {
        final List<dynamic> sessionsJson = json.decode(sessionsData);
        final sessions = sessionsJson.map((json) => LiveSession.fromJson(json)).toList();
        print('[SessionsService] Loaded ${sessions.length} sessions from local storage');
        return sessions;
      }
    } catch (e) {
      print('[SessionsService] Error loading from local storage: $e');
    }
    
    print('[SessionsService] No sessions found in local storage');
    return [];
  }

  /// Delete all sessions
  Future<void> clearSessions() async {
    try {
      final username = await UserService.getUsername();
      if (username != null) {
        await _apiService.delete('/user-sessions/delete/$username');
      }
    } catch (e) {
      print('[SessionsService] Error deleting from backend: $e');
    }
    
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
  }
}

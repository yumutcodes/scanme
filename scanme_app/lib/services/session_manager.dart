class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int? currentUserId;

  void login(int userId) {
    currentUserId = userId;
  }

  void logout() {
    currentUserId = null;
  }
}

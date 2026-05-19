/// Centralized error handling utility for consistent user-facing messages
class ErrorHandler {
  ErrorHandler._();

  /// Converts technical Firestore errors into user-friendly messages
  static String getFriendlyFirestoreMessage(Object? error) {
    final msg = error?.toString() ?? '';
    
    // Index errors
    if (msg.contains('FAILED_PRECONDITION') || msg.contains('requires an index')) {
      return 'Database index required. Please contact the administrator.';
    }
    
    // Permission errors
    if (msg.contains('PERMISSION_DENIED')) {
      return 'You don\'t have permission to perform this action.';
    }
    
    // Network errors
    if (msg.contains('unavailable') || 
        msg.contains('network') || 
        msg.contains('UNAVAILABLE')) {
      return 'No internet connection. Please check your network.';
    }
    
    // Not found errors
    if (msg.contains('NOT_FOUND')) {
      return 'The requested data was not found.';
    }
    
    // Timeout errors
    if (msg.contains('DEADLINE_EXCEEDED') || msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Default fallback
    return 'An error occurred. Please try again later.';
  }

  /// Converts authentication errors into user-friendly messages
  static String getFriendlyAuthMessage(Object? error) {
    final msg = error?.toString() ?? '';
    
    if (msg.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (msg.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('invalid-email')) {
      return 'Invalid email address format.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    
    return 'Authentication failed. Please try again.';
  }
}

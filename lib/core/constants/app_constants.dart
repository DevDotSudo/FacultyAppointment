class AppConstants {
  // User-friendly error messages
  static const String networkError = 'Network error. Please check your internet connection and try again.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String genericError = 'Something went wrong. Please try again later.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String permissionError = 'You do not have permission to perform this action.';

  static String parseError(dynamic e) {
    final message = e.toString();
    if (message.contains('network') || message.contains('Network')) {
      return networkError;
    }
    if (message.contains('auth') || message.contains('permission') || message.contains('Permission')) {
      return permissionError;
    }
    if (message.contains('not found') || message.contains('NOT_FOUND')) {
      return notFoundError;
    }
    // Strip the "Exception: " prefix if present
    final clean = message.replaceAll('Exception: ', '').replaceAll('_Exception: ', '');
    return clean.isNotEmpty ? clean : genericError;
  }
}
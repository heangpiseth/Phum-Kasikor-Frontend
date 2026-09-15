class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException(this.statusCode, this.message, {this.errors});

  /// The first validation error message, if any - handy for showing
  /// a single error under a form field without digging through the map.
  String? firstErrorFor(String field) {
    final fieldErrors = errors?[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }

  @override
  String toString() => message;
}
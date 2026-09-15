/// A uniform result shape returned by every repository method.
/// Controllers check .success and read .data or .message -
/// no try/catch scattered through the GetX controllers themselves.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse.success(this.data)
      : success = true,
        message = null,
        errors = null;

  ApiResponse.failure(this.message, {this.errors})
      : success = false,
        data = null;
}
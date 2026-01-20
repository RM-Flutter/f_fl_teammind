class OperationResult<T> {
  bool success;
  T? data;
  String? message;
  bool? checkAuth;
  String? errorCodeString;
  var errors;
  OperationResult(
      {this.success = false,
      this.data,
      this.errors,
      this.message,
      this.errorCodeString,
      this.checkAuth});
}

class ApiResult {
  final String result;

  ApiResult({required this.result});

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      result: json['Result'],
    );
  }
}

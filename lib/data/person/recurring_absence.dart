class RecuringAbsence {
  final int id;
  final int weekday;

  RecuringAbsence({required this.id, required this.weekday});

  factory RecuringAbsence.fromJson(Map<String, dynamic> json) {
    return RecuringAbsence(
      id: json['ID'],
      weekday: json['Weekday'],
    );
  }
}

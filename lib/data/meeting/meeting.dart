class Meeting {
	final int id;
	final String date;

  Meeting({required this.id, required this.date});

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['ID'],
      date: json['Date'],
    );
  }
}
class Meeting {
  final int id;
  final String date;
  Tag? tag;

  Meeting({required this.id, required this.date, this.tag});

  factory Meeting.fromJson(Map<String, dynamic> json) {
    Tag? t;
    if (json.containsKey('Tag') && json['Tag'] != null) {
      t = Tag.fromJson(json['Tag']);
    }
    return Meeting(
      id: json['ID'],
      date: json['Date'],
      tag: t,
    );
  }
}

class Tag {
  final int id;
  final String descr;

  Tag({required this.id, required this.descr});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['ID'],
      descr: json['Descr'],
    );
  }
}

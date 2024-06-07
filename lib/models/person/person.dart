class Person {
  final int id;
  final String givenName;
  final String lastName;

  Person({this.id = 0, required this.givenName, required this.lastName});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['ID'],
      givenName: json['GivenName'],
      lastName: json['LastName'],
    );
  }

  Map<String, dynamic> toJson() {
    if (id <= 0) {
      return {'GivenName': givenName, 'LastName': lastName};
    }
    return {'ID': id, 'GivenName': givenName, 'LastName': lastName};
  }
}

class People {
  final List<Person> absent;
  final List<Person> available;
  final Person assigned;

  People(
      {required this.absent, required this.available, required this.assigned});

  factory People.fromJson(Map<String, dynamic> json) {
    var absentList = json['absent'] as List;
    var availableList = json['available'] as List;
    var assignedJson = json['assigned'];

    List<Person> absent = absentList.map((i) => Person.fromJson(i)).toList();
    List<Person> available =
        availableList.map((i) => Person.fromJson(i)).toList();
    Person assigned = Person.fromJson(assignedJson);

    return People(absent: absent, available: available, assigned: assigned);
  }
}

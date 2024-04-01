class Person {
  final int id;
  final String givenName;
  final String lastName;

  Person({required this.id, required this.givenName, required this.lastName});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['ID'],
      givenName: json['GivenName'],
      lastName: json['LastName'],
    );
  }
}
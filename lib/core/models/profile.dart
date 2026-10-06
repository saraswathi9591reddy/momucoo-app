/// localStorage key `momucooProfile`. All fields are strings on web; unknown keys are preserved.
class Profile {
  String name, age, gender, bloodGroup, pregnancyStatus, pregnancyWeek, dueDate;
  final Map<String, dynamic> extra;

  Profile({
    this.name = '',
    this.age = '',
    this.gender = '',
    this.bloodGroup = '',
    this.pregnancyStatus = 'Pregnant',
    this.pregnancyWeek = '',
    this.dueDate = '',
    Map<String, dynamic>? extra,
  }) : extra = extra ?? {};

  static const _keys = ['name', 'age', 'gender', 'bloodGroup', 'pregnancyStatus', 'pregnancyWeek', 'dueDate'];

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: (j['name'] ?? '').toString(),
        age: (j['age'] ?? '').toString(),
        gender: (j['gender'] ?? '').toString(),
        bloodGroup: (j['bloodGroup'] ?? '').toString(),
        pregnancyStatus: (j['pregnancyStatus'] ?? '').toString(),
        pregnancyWeek: (j['pregnancyWeek'] ?? '').toString(),
        dueDate: (j['dueDate'] ?? '').toString(),
        extra: Map.of(j)..removeWhere((k, _) => _keys.contains(k)),
      );

  Map<String, dynamic> toJson() => {
        ...extra,
        'name': name,
        'age': age,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'pregnancyStatus': pregnancyStatus,
        'pregnancyWeek': pregnancyWeek,
        'dueDate': dueDate,
      };

  /// Same as PageLayout.jsx: first letters of words, max 2, uppercased.
  String get initials {
    final s = name.split(' ').where((p) => p.isNotEmpty).map((p) => p[0]).join();
    return (s.length > 2 ? s.substring(0, 2) : s).toUpperCase();
  }
}

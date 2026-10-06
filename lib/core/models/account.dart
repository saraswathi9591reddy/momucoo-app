/// localStorage key `momucooAccount`: {name, email, password}.
/// Demo only: the web app stores the password in plain text; kept identical for parity.
class Account {
  final String name, email, password;
  const Account({required this.name, required this.email, required this.password});

  /// Mirrors Login.jsx readAccount(): null unless email and password are strings.
  static Account? tryParse(dynamic j) {
    if (j is! Map || j['email'] is! String || j['password'] is! String) return null;
    return Account(name: (j['name'] ?? '').toString(), email: j['email'] as String, password: j['password'] as String);
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'password': password};
}

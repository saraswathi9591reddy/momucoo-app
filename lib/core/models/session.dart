/// localStorage key `momucooSession`: the raw string "true" (not JSON-encoded) when logged in; removed on logout.
class Session {
  static const loggedInValue = 'true';
  final bool loggedIn;
  const Session(this.loggedIn);
  factory Session.fromRaw(String? raw) => Session(raw == loggedInValue);
}

class User{
  String _username;
  String _password;

  User(this._username,
      this._password);

  get username => _username;
  get password => _password;

  @override
  String toString() {
    return "|$_username $_password|";
  }

  @override
  bool operator ==(other) {
    return (_username == other._username) && (_password == other._password);
  }
}
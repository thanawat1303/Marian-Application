import 'package:flutter/foundation.dart';

class UserDB {
  final String? id;
  final String? uid;
  final String? fullname;
  final String? email;
  final String? typeUser;
  final String? image;
  final String? phone;
  const UserDB(
      {this.id,
      this.uid,
      this.fullname,
      this.email,
      this.typeUser,
      this.image,
      this.phone});
}

class UserProvider with ChangeNotifier {
  List<UserDB> _profile = [];

  List<UserDB> get users {
    return _profile;
  }

  addNewUser(UserDB data) {
    _profile.clear();
    _profile.add(data);
    notifyListeners();
  }
}

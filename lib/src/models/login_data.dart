import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;
  bool isAnonymous;

  LoginData(
      {required this.name, required this.password, required this.isAnonymous});

  @override
  String toString() {
    return '$runtimeType($name, $password)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name &&
          password == other.password &&
          isAnonymous == other.isAnonymous;
    }
    return false;
  }

  @override
  int get hashCode => hash2(name, password);
}

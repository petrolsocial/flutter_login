import 'package:quiver/core.dart';

class PhoneLoginData {
  final String phoneNumber;

  PhoneLoginData({required this.phoneNumber});

  @override
  String toString() {
    return '$runtimeType($phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (other is PhoneLoginData) {
      return phoneNumber == other.phoneNumber;
    }
    return false;
  }

  @override
  int get hashCode => hash2(phoneNumber, 1);
}

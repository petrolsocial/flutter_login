import 'package:quiver/core.dart';

class PhoneLoginData {
  final String phoneNumber;
  final String? otp;
  final Map<String, String>? additionalSignupData;

  PhoneLoginData({
    required this.phoneNumber,
    this.otp,
    this.additionalSignupData,
  });

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
  int get hashCode => hash3(phoneNumber, otp, additionalSignupData);
}

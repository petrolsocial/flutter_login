import 'package:quiver/core.dart';

class AnonData {
  final Map<String, String>? additionalSignupData;

  AnonData(this.additionalSignupData);

  @override
  bool operator ==(Object other) {
    if (other is AnonData) {
      return additionalSignupData == other.additionalSignupData;
    }
    return false;
  }

  @override
  int get hashCode => hashObjects([additionalSignupData]);
}

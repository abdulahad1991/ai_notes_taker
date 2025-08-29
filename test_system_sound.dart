import 'package:flutter/services.dart';

void main() {
  // Check available SystemSound values
  print('Available SystemSound values:');
  print('SystemSoundType values:');
  for (final value in SystemSoundType.values) {
    print('- ${value.toString()}');
  }
}
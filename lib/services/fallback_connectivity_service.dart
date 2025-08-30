import 'dart:async';
import 'package:flutter/material.dart';

/// Fallback connectivity service when connectivity_plus plugin fails
/// This service assumes the device is always connected
class FallbackConnectivityService {
  static final FallbackConnectivityService _instance = FallbackConnectivityService._internal();
  factory FallbackConnectivityService() => _instance;
  FallbackConnectivityService._internal();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  void initialize() {
    debugPrint('Using FallbackConnectivityService - assuming always connected');
    _isConnected = true;
  }

  Future<bool> hasConnection() async {
    return _isConnected;
  }

  void dispose() {
    _connectionController.close();
  }
}
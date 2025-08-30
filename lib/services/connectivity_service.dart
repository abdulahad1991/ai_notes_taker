import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;
  bool _isInitialized = false;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  void initialize() {
    if (_isInitialized) return;
    
    try {
      _checkInitialConnection();
      _startMonitoring();
      _isInitialized = true;
      debugPrint('ConnectivityService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ConnectivityService: $e');
      // Fallback: assume connected if we can't check connectivity
      _isConnected = true;
    }
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking initial connection: $e');
      // Fallback: assume connected
      _isConnected = true;
    }
  }

  void _startMonitoring() {
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _updateConnectionStatus(results);
        },
        onError: (error) {
          debugPrint('Connectivity monitoring error: $error');
          // On error, assume connected to avoid blocking functionality
          _isConnected = true;
          _connectionController.add(_isConnected);
        },
      );
    } catch (e) {
      debugPrint('Error starting connectivity monitoring: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    try {
      final wasConnected = _isConnected;
      _isConnected = results.any((result) => result != ConnectivityResult.none);
      
      if (wasConnected != _isConnected) {
        _connectionController.add(_isConnected);
        debugPrint('Connectivity changed: ${_isConnected ? 'Connected' : 'Disconnected'}');
      }
    } catch (e) {
      debugPrint('Error updating connection status: $e');
    }
  }

  Future<bool> hasConnection() async {
    if (!_isInitialized) {
      debugPrint('ConnectivityService not initialized, assuming connected');
      return true;
    }
    
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      // Return current cached status if check fails
      return _isConnected;
    }
  }

  String getConnectionType() {
    return _connectivity.checkConnectivity().toString();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}
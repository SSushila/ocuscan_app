import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../main.dart';

class GlobalConnectivityListener extends StatefulWidget {
  final Widget child;
  const GlobalConnectivityListener({required this.child, super.key});

  @override
  State<GlobalConnectivityListener> createState() => _GlobalConnectivityListenerState();
}

class _GlobalConnectivityListenerState extends State<GlobalConnectivityListener> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
  final hasConnection = results.any((r) => r != ConnectivityResult.none);
  print('Connectivity changed: hasConnection = ' + hasConnection.toString());
  if (!hasConnection && !_isOffline) {
    _isOffline = true;
    _showSnackbar('No internet connection', Colors.redAccent);
  } else if (hasConnection && _isOffline) {
    _isOffline = false;
    _showSnackbar('Internet connection restored', Colors.green);
  }
});
  }

  void _showSnackbar(String message, Color color) {
  print('Showing snackbar: ' + message);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  });
}

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

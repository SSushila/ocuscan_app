import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DiseasePrediction {
  final double probability;
  final bool detected;
  final String fullName;
  final MedicalAdvice? advice;

  DiseasePrediction({
    required this.probability,
    required this.detected,
    required this.fullName,
    this.advice,
  });

  factory DiseasePrediction.fromJson(Map<String, dynamic> json) {
    return DiseasePrediction(
      probability: (json['probability'] as num).toDouble(),
      detected: json['detected'] as bool,
      fullName: json['full_name'] ?? '',
      advice: json['advice'] != null ? MedicalAdvice.fromJson(json['advice']) : null,
    );
  }
}

class MedicalAdvice {
  final String severity;
  final int followUpDays;
  final List<String> recommendations;

  MedicalAdvice({
    required this.severity,
    required this.followUpDays,
    required this.recommendations,
  });

  factory MedicalAdvice.fromJson(Map<String, dynamic> json) {
    return MedicalAdvice(
      severity: json['severity'] ?? '',
      followUpDays: json['followUpDays'] ?? 0,
      recommendations: (json['recommendations'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}


class Predictions {
  final Map<String, DiseasePrediction> predictions;

  Predictions(this.predictions);

  factory Predictions.fromJson(Map<String, dynamic> json) {
    final map = <String, DiseasePrediction>{};
    json.forEach((key, value) {
      map[key] = DiseasePrediction.fromJson(value);
    });
    return Predictions(map);
  }
}

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal() {
    _initializeNetworkInfo();
  }

  String _apiUrl = 'http://localhost:8000';
  bool _isInitialized = false;

  Future<void> _initializeNetworkInfo() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final info = NetworkInfo();
      String? ip = await info.getWifiIP();
      if (connectivityResult == ConnectivityResult.wifi && ip != null) {
        _apiUrl = 'http://$ip:8000';
      }
      Connectivity().onConnectivityChanged.listen((result) async {
        String? newIp = await info.getWifiIP();
        if (result == ConnectivityResult.wifi && newIp != null) {
          _apiUrl = 'http://$newIp:8000';
        }
      });
      _isInitialized = true;
    } catch (e) {
      _apiUrl = 'http://localhost:8000';
    }
  }

  static PredictionService get instance => _instance;

  Future<Predictions?> predictImage(String imagePath) async {
    try {
      if (!_isInitialized) {
        print('[PredictionService] Network not initialized, waiting...');
        await Future.delayed(const Duration(seconds: 1));
      }
      print('[PredictionService] Sending prediction request');
      print('  API URL: $_apiUrl/predict');
      print('  Image path: $imagePath');
      var uri = Uri.parse('$_apiUrl/predict');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imagePath, contentType: MediaType('image', 'jpeg')));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('[PredictionService] Response status: ${response.statusCode}');
      print('[PredictionService] Response body: ${response.body}');

      if (response.statusCode != 200) {
        try {
          final errorData = jsonDecode(response.body);
          print('[PredictionService] Error data: $errorData');
          if (response.statusCode == 400) {
            throw Exception(errorData['detail'] ?? 'Invalid image');
          }
          throw Exception('HTTP error! status: ${response.statusCode}');
        } catch (err) {
          print('[PredictionService] Failed to decode error body: $err');
          throw Exception('HTTP error! status: ${response.statusCode}');
        }
      }
      final predictionsJson = jsonDecode(response.body);
      print('[PredictionService] Decoded predictions: $predictionsJson');
      return Predictions.fromJson(predictionsJson);
    } catch (e, stack) {
      print('[PredictionService] Exception: $e');
      print(stack);
      rethrow;
    }
  }
}



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:phum_kasikors/model/farmer/crop_model.dart';
import 'package:phum_kasikors/model/farmer/farmer_model.dart';

class FarmerService {
  FarmerService({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? 'https://your-api.example.com/api',
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Future<Map<String, String>> get _headers async => {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${await AuthStorage.getToken()}',
      };

  Future<FarmerModel> getFarmerProfile() async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/farmer/profile'),
      headers: await _headers,
    );

    if (res.statusCode == 200) {
      return FarmerModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load farmer profile (${res.statusCode})');
  }

  Future<List<CropModel>> getCrops(String farmId) async {
    final res = await _client.get(
      Uri.parse('$_baseUrl/farms/$farmId/crops'),
      headers: await _headers,
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((json) => CropModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load crops (${res.statusCode})');
  }

  Future<CropModel> addCrop(CropModel crop) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/crops'),
      headers: await _headers,
      body: jsonEncode(crop.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return CropModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to add crop (${res.statusCode})');
  }

  Future<void> deleteCrop(String cropId) async {
    final res = await _client.delete(
      Uri.parse('$_baseUrl/crops/$cropId'),
      headers: await _headers,
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete crop (${res.statusCode})');
    }
  }
}
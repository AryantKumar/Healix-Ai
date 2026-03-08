import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../core/constants/app_constants.dart';
import '../models/hospital.dart';

class HospitalService {
  static final HospitalService _instance = HospitalService._internal();
  factory HospitalService() => _instance;
  HospitalService._internal();

  /// Fetch real nearby hospitals using Google Places API.
  /// Falls back to mock data if API key not configured or request fails.
  Future<List<Hospital>> getNearbyHospitals({
    required double latitude,
    required double longitude,
    double radiusMeters = 5000,
  }) async {
    return _fetchHospitalsInternal(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
  }

  /// Search hospitals by location name and keyword
  Future<List<Hospital>> searchHospitals({
    required String query,
    required String location,
    double radiusMeters = 10000, // larger radius for text searches
  }) async {
    try {
      // 1. Geocode location to lat/lng
      final locations = await locationFromAddress(location);
      if (locations.isEmpty) return [];

      final lat = locations.first.latitude;
      final lng = locations.first.longitude;

      // 2. Fetch using lat/lng and keyword
      return _fetchHospitalsInternal(
        latitude: lat,
        longitude: lng,
        radiusMeters: radiusMeters,
        keyword: query,
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<Hospital>> _fetchHospitalsInternal({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    String? keyword,
  }) async {
    // Try Google Places API first
    if (AppConstants.placesApiKey != 'YOUR_GOOGLE_PLACES_API_KEY' &&
        AppConstants.placesApiKey.isNotEmpty) {
      try {
        return await _fetchFromGooglePlaces(latitude, longitude, radiusMeters, keyword: keyword);
      } catch (e) {
        // Fall through to mock data on failure
      }
    }

    // Fallback: use Google Maps search URL approach (no API key needed)
    try {
      return await _fetchFromOverpassAPI(latitude, longitude, radiusMeters, keyword: keyword);
    } catch (e) {
      // Final fallback to mock data
      return _generateMockHospitals(latitude, longitude, keyword: keyword);
    }
  }

  /// Fetch hospitals from Google Places Nearby Search API
  Future<List<Hospital>> _fetchFromGooglePlaces(
      double lat, double lng, double radius, {String? keyword}) async {
    String urlStr =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=${radius.toInt()}'
      '&type=hospital'
      '&key=${AppConstants.placesApiKey}';

    if (keyword != null && keyword.trim().isNotEmpty) {
      urlStr += '&keyword=${Uri.encodeComponent(keyword.trim())}';
    }

    final url = Uri.parse(urlStr);
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Places API error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception('Places API status: ${data['status']}');
    }

    final results = data['results'] as List? ?? [];
    final hospitals = <Hospital>[];

    for (int i = 0; i < results.length; i++) {
      final place = results[i];
      final location = place['geometry']?['location'];
      if (location == null) continue;

      final placeLat = (location['lat'] as num).toDouble();
      final placeLng = (location['lng'] as num).toDouble();
      final distance = _calculateDistance(lat, lng, placeLat, placeLng);

      hospitals.add(Hospital(
        id: place['place_id'] ?? 'place_$i',
        name: place['name'] ?? 'Unknown Hospital',
        address: place['vicinity'] ?? 'Address not available',
        distance: distance,
        rating: (place['rating'] as num?)?.toDouble() ?? 0.0,
        isOpen: place['opening_hours']?['open_now'] ?? true,
        latitude: placeLat,
        longitude: placeLng,
        phoneNumber: null, // Not available in Nearby Search
        totalRatings: (place['user_ratings_total'] as int?) ?? 0,
      ));
    }

    hospitals.sort((a, b) => a.distance.compareTo(b.distance));
    return hospitals;
  }

  /// Fetch hospitals from OpenStreetMap Overpass API (free, no key needed)
  Future<List<Hospital>> _fetchFromOverpassAPI(
      double lat, double lng, double radius, {String? keyword}) async {
    final query = '''
[out:json][timeout:10];
(
  node["amenity"="hospital"](around:$radius,$lat,$lng);
  way["amenity"="hospital"](around:$radius,$lat,$lng);
  node["amenity"="clinic"](around:$radius,$lat,$lng);
  way["amenity"="clinic"](around:$radius,$lat,$lng);
);
out center body;
''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    final response = await http
        .post(url, body: {'data': query})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final elements = data['elements'] as List? ?? [];
    final hospitals = <Hospital>[];

    for (int i = 0; i < elements.length; i++) {
      final el = elements[i];
      final tags = el['tags'] as Map<String, dynamic>? ?? {};

      double elLat, elLng;
      if (el['type'] == 'way' && el['center'] != null) {
        elLat = (el['center']['lat'] as num).toDouble();
        elLng = (el['center']['lon'] as num).toDouble();
      } else {
        elLat = (el['lat'] as num?)?.toDouble() ?? 0;
        elLng = (el['lon'] as num?)?.toDouble() ?? 0;
      }

      if (elLat == 0 && elLng == 0) continue;

      final name = tags['name'] ?? tags['name:en'] ?? 'Hospital';
      
      // Client side filtering for keyword
      if (keyword != null && keyword.trim().isNotEmpty) {
        final searchStr = keyword.trim().toLowerCase();
        final matchesName = name.toLowerCase().contains(searchStr);
        final matchesTags = tags.values.any((v) => v.toString().toLowerCase().contains(searchStr));
        if (!matchesName && !matchesTags) {
          continue;
        }
      }

      final distance = _calculateDistance(lat, lng, elLat, elLng);

      hospitals.add(Hospital(
        id: el['id'].toString(),
        name: name,
        address: _buildAddress(tags),
        distance: distance,
        rating: 4.0, // OSM doesn't have ratings
        isOpen: true,
        latitude: elLat,
        longitude: elLng,
        phoneNumber: tags['phone'] ?? tags['contact:phone'],
        totalRatings: 0,
      ));
    }

    hospitals.sort((a, b) => a.distance.compareTo(b.distance));

    // If Overpass returned nothing, fall back to mock
    if (hospitals.isEmpty) {
      return _generateMockHospitals(lat, lng, keyword: keyword);
    }

    return hospitals;
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:state'] != null) parts.add(tags['addr:state']);
    if (parts.isEmpty && tags['address'] != null) return tags['address'];
    return parts.isNotEmpty ? parts.join(', ') : 'Address not available';
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  /// Mock data fallback
  List<Hospital> _generateMockHospitals(double lat, double lng, {String? keyword}) {
    return [
      Hospital(
        id: 'mock_1',
        name: keyword != null && keyword.isNotEmpty ? 'Mock ${keyword} Hospital' : 'Nearby Hospital (Mock)',
        address: 'Mock data — set Google Places API key for real results',
        distance: 1.2,
        rating: 4.5,
        isOpen: true,
        latitude: lat + 0.008,
        longitude: lng + 0.005,
        phoneNumber: null,
        totalRatings: 10,
      ),
    ];
  }
}


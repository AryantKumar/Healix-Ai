class Hospital {
  final String id;
  final String name;
  final String address;
  final double distance; // km
  final double rating;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? photoUrl;
  final int? totalRatings;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.rating = 0,
    this.isOpen = true,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.photoUrl,
    this.totalRatings,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'distance': distance,
        'rating': rating,
        'isOpen': isOpen,
        'latitude': latitude,
        'longitude': longitude,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
        'totalRatings': totalRatings,
      };

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        distance: (json['distance'] ?? 0).toDouble(),
        rating: (json['rating'] ?? 0).toDouble(),
        isOpen: json['isOpen'] ?? true,
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        phoneNumber: json['phoneNumber'],
        photoUrl: json['photoUrl'],
        totalRatings: json['totalRatings'],
      );
}

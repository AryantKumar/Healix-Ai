import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/hospital.dart';
import '../../services/hospital_service.dart';
import '../../widgets/glass_card.dart';

class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});

  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  List<Hospital> _hospitals = [];
  bool _isLoading = true;
  String? _error;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission is required to find nearby hospitals.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Fetch hospitals
      final hospitals = await HospitalService().getNearbyHospitals(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to get location. Please enable GPS and try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Nearby Hospitals', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchHospitals,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text('Finding hospitals near you...',
                style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded,
                  size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 20),
              Text(_error!, style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchHospitals,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHospitals,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hospitals.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_hospitals.length} hospitals found near your location',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms);
          }

          final hospital = _hospitals[index - 1];
          return _buildHospitalCard(hospital, index - 1);
        },
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital, int index) {
    return GlassCard(
      onTap: () => _showHospitalDetails(hospital),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppColors.hospitalGradient),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name,
                        style: AppTypography.titleLarge, maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(hospital.address,
                        style: AppTypography.bodySmall, maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Distance
              _buildTag(
                icon: Icons.directions_walk_rounded,
                text: '${hospital.distance.toStringAsFixed(1)} km',
                color: AppColors.info,
              ),
              const SizedBox(width: 10),
              // Rating
              _buildTag(
                icon: Icons.star_rounded,
                text: hospital.rating.toStringAsFixed(1),
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              // Status
              _buildTag(
                icon: hospital.isOpen
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                text: hospital.isOpen ? 'Open' : 'Closed',
                color: hospital.isOpen ? AppColors.success : AppColors.error,
              ),
              const Spacer(),
              // Navigate
              GestureDetector(
                onTap: () => _openMaps(hospital),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_rounded,
                          color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text('Navigate',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 100 * index), duration: 400.ms)
        .slideX(begin: 0.05);
  }

  Widget _buildTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showHospitalDetails(Hospital hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(hospital.name, style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(hospital.address, style: AppTypography.bodyMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildDetailItem(
                    Icons.star_rounded, '${hospital.rating.toStringAsFixed(1)} Rating',
                    AppColors.warning),
                const SizedBox(width: 20),
                _buildDetailItem(Icons.directions_walk_rounded,
                    '${hospital.distance.toStringAsFixed(1)} km', AppColors.info),
                const SizedBox(width: 20),
                _buildDetailItem(
                    hospital.isOpen
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    hospital.isOpen ? 'Open Now' : 'Closed',
                    hospital.isOpen ? AppColors.success : AppColors.error),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callHospital(hospital),
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openMaps(hospital);
                    },
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(text,
            style: AppTypography.labelMedium.copyWith(color: color)),
      ],
    );
  }

  Future<void> _openMaps(Hospital hospital) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${hospital.latitude},${hospital.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callHospital(Hospital hospital) async {
    if (hospital.phoneNumber != null) {
      final url = Uri.parse('tel:${hospital.phoneNumber}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }
}

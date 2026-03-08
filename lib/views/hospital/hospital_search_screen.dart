import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/hospital.dart';
import '../../services/hospital_service.dart';
import '../../widgets/glass_card.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({super.key});

  @override
  State<HospitalSearchScreen> createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();
  
  List<Hospital> _hospitals = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;

  @override
  void dispose() {
    _locationController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final location = _locationController.text.trim();
    final query = _queryController.text.trim();

    if (location.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a location'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final results = await HospitalService().searchHospitals(
        query: query,
        location: location,
      );

      setState(() {
        _hospitals = results;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Failed to search hospitals. Please check the spelling of your location or try again later.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Search Hospitals', style: AppTypography.headlineMedium),
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find Specialized Care', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          // Location Field
          TextField(
            controller: _locationController,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Location (e.g. Bengaluru, New York)',
              prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          // Query Field
          TextField(
            controller: _queryController,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Hospital Type/Name (e.g. Diabetic, Heart)',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 16),
          // Search Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
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
            Text('Searching hospitals...', style: AppTypography.bodyMedium),
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
              Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 20),
              Text(_error!, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Enter a location to find hospitals', style: AppTypography.titleMedium.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    if (_hospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.not_interested_rounded, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('No hospitals found', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text('Try checking the spelling or use a different location', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hospitals.length,
      itemBuilder: (context, index) {
        final hospital = _hospitals[index];
        return _buildHospitalCard(hospital, index);
      },
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
                  gradient: const LinearGradient(colors: AppColors.hospitalGradient),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital.name, style: AppTypography.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(hospital.address, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Rating
              _buildTag(
                icon: Icons.star_rounded,
                text: hospital.rating.toStringAsFixed(1),
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              // Status
              _buildTag(
                icon: hospital.isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
                text: hospital.isOpen ? 'Open' : 'Closed',
                color: hospital.isOpen ? AppColors.success : AppColors.error,
              ),
              const Spacer(),
              // Navigate
              GestureDetector(
                onTap: () => _openMaps(hospital),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text('Navigate', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )..animate().fadeIn(delay: Duration(milliseconds: 100 * (index % 5)), duration: 400.ms).slideX(begin: 0.05);
  }

  Widget _buildTag({required IconData icon, required String text, required Color color}) {
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
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
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
                _buildDetailItem(Icons.star_rounded, '${hospital.rating.toStringAsFixed(1)} Rating', AppColors.warning),
                const SizedBox(width: 20),
                // Hide distance in search, since it's from search target not current location
                _buildDetailItem(
                    hospital.isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        Text(text, style: AppTypography.labelMedium.copyWith(color: color)),
      ],
    );
  }

  Future<void> _openMaps(Hospital hospital) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${hospital.latitude},${hospital.longitude}');
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('No phone number available'), backgroundColor: AppColors.error),
      );
    }
  }
}

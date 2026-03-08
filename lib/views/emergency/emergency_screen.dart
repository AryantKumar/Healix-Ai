import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/emergency_contact.dart';
import '../../models/hospital.dart';
import '../../services/database_service.dart';
import '../../services/hospital_service.dart';
import '../../widgets/glass_card.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  List<EmergencyContact> _contacts = [];
  List<Hospital> _nearbyHospitals = [];
  bool _isLoadingHospitals = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _loadContacts();
    _loadNearbyHospitals();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    final db = DatabaseService();
    final data = db.getEmergencyContacts();
    setState(() {
      _contacts = data.map((e) => EmergencyContact.fromJson(e)).toList();
    });
  }

  Future<void> _loadNearbyHospitals() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      final hospitals = await HospitalService().getNearbyHospitals(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {
        _nearbyHospitals = hospitals.take(3).toList();
        _isLoadingHospitals = false;
      });
    } catch (e) {
      setState(() => _isLoadingHospitals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergency,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergency.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('Emergency', style: AppTypography.headlineMedium),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SOS Button
            Center(
              child: AnimatedBuilder(
                listenable: _pulseController,
                builder: (context, _) {
                  final scale = 1.0 + (_pulseController.value * 0.05);
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: _callEmergency,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.emergencyGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emergency.withOpacity(
                                  0.3 + _pulseController.value * 0.2),
                              blurRadius: 30 + (_pulseController.value * 20),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos_rounded,
                                color: Colors.white, size: 40),
                            const SizedBox(height: 4),
                            Text('SOS',
                                style: AppTypography.headlineMedium
                                    .copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Tap SOS to call emergency services',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Call Buttons
            Text('Quick Call', style: AppTypography.headlineSmall)
                .animate()
                .fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickCallCard(
                    icon: Icons.local_hospital_rounded,
                    label: 'Ambulance',
                    number: '102',
                    colors: AppColors.emergencyGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickCallCard(
                    icon: Icons.local_police_rounded,
                    label: 'Police',
                    number: '100',
                    colors: [AppColors.info, AppColors.info],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickCallCard(
                    icon: Icons.fire_truck_rounded,
                    label: 'Fire',
                    number: '101',
                    colors: AppColors.medicineGradient,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

            const SizedBox(height: 28),

            // Nearest Hospitals
            Text('Nearest Hospitals', style: AppTypography.headlineSmall)
                .animate()
                .fadeIn(delay: 400.ms),

            const SizedBox(height: 12),

            if (_isLoadingHospitals)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                ),
              )
            else if (_nearbyHospitals.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.location_off_rounded,
                        color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Enable location to see nearby hospitals',
                          style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(
                _nearbyHospitals.length,
                (i) => _buildHospitalQuickCard(_nearbyHospitals[i], i),
              ),

            const SizedBox(height: 28),

            // Emergency Contacts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Emergency Contacts',
                    style: AppTypography.headlineSmall),
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.primary),
                  onPressed: _addEmergencyContact,
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 8),

            if (_contacts.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        color: AppColors.textTertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Add emergency contacts for quick access',
                          style: AppTypography.bodyMedium),
                    ),
                  ],
                ),
              )
            else
              ..._contacts
                  .asMap()
                  .entries
                  .map((e) => _buildContactCard(e.value, e.key)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCallCard({
    required IconData icon,
    required String label,
    required String number,
    required List<Color> colors,
  }) {
    return GestureDetector(
      onTap: () => _makeCall(number),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.map((c) => c.withOpacity(0.15)).toList(),
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.first.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.first, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style:
                    AppTypography.labelMedium.copyWith(color: colors.first)),
            Text(number,
                style: AppTypography.bodySmall.copyWith(color: colors.first)),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalQuickCard(Hospital hospital, int index) {
    return GlassCard(
      onTap: () => _openMaps(hospital),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: AppColors.hospitalGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name,
                    style: AppTypography.titleMedium, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${hospital.distance.toStringAsFixed(1)} km away',
                    style: AppTypography.bodySmall),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hospital.phoneNumber != null)
                IconButton(
                  icon:
                      Icon(Icons.phone_rounded, color: AppColors.success, size: 22),
                  onPressed: () => _makeCall(hospital.phoneNumber!),
                ),
              Icon(Icons.directions_rounded,
                  color: AppColors.primary, size: 22),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 200 + index * 100),
            duration: 400.ms);
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) {
        DatabaseService().deleteEmergencyContact(contact.id);
        _loadContacts();
      },
      child: GlassCard(
        onTap: () => _makeCall(contact.phone),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: AppTypography.titleMedium),
                  Row(
                    children: [
                      Text(contact.phone, style: AppTypography.bodySmall),
                      if (contact.relationship != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(contact.relationship!,
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.phone_rounded,
                  color: AppColors.success, size: 24),
              onPressed: () => _makeCall(contact.phone),
            ),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 100 * index),
            duration: 400.ms,
          ),
    );
  }

  Future<void> _makeCall(String number) async {
    final url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openMaps(Hospital hospital) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${hospital.latitude},${hospital.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _callEmergency() {
    _makeCall('112');
  }

  void _addEmergencyContact() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
            Text('Add Emergency Contact',
                style: AppTypography.headlineLarge),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: AppTypography.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Contact name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              style: AppTypography.bodyLarge,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Phone number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: relationController,
              style: AppTypography.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Relationship (optional)',
                prefixIcon: Icon(Icons.people_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty ||
                      phoneController.text.trim().isEmpty) return;

                  final contact = EmergencyContact(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    relationship: relationController.text.trim().isEmpty
                        ? null
                        : relationController.text.trim(),
                  );

                  DatabaseService()
                      .addEmergencyContact(contact.toJson());
                  Navigator.pop(context);
                  _loadContacts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergency,
                ),
                child: const Text('Save Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

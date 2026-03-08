import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../models/medicine.dart';
import '../../models/health_event.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/glass_card.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    final db = DatabaseService();
    final data = db.getMedicines();
    setState(() {
      _medicines = data.map((e) => Medicine.fromJson(e)).toList()
        ..sort((a, b) {
          if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medicine Reminders', style: AppTypography.headlineMedium),
      ),
      body: _medicines.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medicines.length,
              itemBuilder: (context, index) =>
                  _buildMedicineCard(_medicines[index], index),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addMedicine',
        onPressed: _showAddMedicineDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Medicine', style: AppTypography.button),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_rounded,
              size: 72, color: AppColors.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No medicines added', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text('Set reminders for your medications',
              style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine, int index) {
    return Dismissible(
      key: Key(medicine.id),
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
      onDismissed: (_) => _deleteMedicine(medicine),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: medicine.isActive
                      ? AppColors.medicineGradient
                      : [AppColors.textTertiary, AppColors.textTertiary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.medication_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medicine.name,
                      style: AppTypography.titleLarge.copyWith(
                        color: medicine.isActive
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    '${medicine.dosage} • ${medicine.frequency}',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  if (medicine.reminderTimes.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: medicine.reminderTimes.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.alarm_rounded,
                                  size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(t,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            Switch(
              value: medicine.isActive,
              activeColor: AppColors.primary,
              onChanged: (v) => _toggleMedicine(medicine, v),
            ),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 80 * index),
            duration: 400.ms,
          ),
    );
  }

  void _toggleMedicine(Medicine medicine, bool isActive) {
    final updated = Medicine(
      id: medicine.id,
      name: medicine.name,
      dosage: medicine.dosage,
      frequency: medicine.frequency,
      reminderTimes: medicine.reminderTimes,
      isActive: isActive,
      notes: medicine.notes,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
    );
    DatabaseService().updateMedicine(medicine.id, updated.toJson());
    _loadMedicines();
  }

  void _deleteMedicine(Medicine medicine) {
    DatabaseService().deleteMedicine(medicine.id);
    NotificationService().cancelReminder(medicine.id.hashCode);
    _loadMedicines();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medicine.name} deleted')),
    );
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    String frequency = AppConstants.frequencies.first;
    final List<TimeOfDay> reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
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
                Text('Add Medicine', style: AppTypography.headlineLarge),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Medicine name',
                    prefixIcon: Icon(Icons.medication_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: dosageController,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Dosage (e.g., 500mg)',
                    prefixIcon: Icon(Icons.medical_information_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: frequency,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceLight,
                      style: AppTypography.bodyLarge,
                      items: AppConstants.frequencies
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setSheetState(() => frequency = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Reminder Times', style: AppTypography.titleMedium),
                const SizedBox(height: 10),
                ...List.generate(reminderTimes.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: reminderTimes[i],
                              );
                              if (picked != null) {
                                setSheetState(() => reminderTimes[i] = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    reminderTimes[i].format(context),
                                    style: AppTypography.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (reminderTimes.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: AppColors.error),
                            onPressed: () =>
                                setSheetState(() => reminderTimes.removeAt(i)),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setSheetState(() =>
                      reminderTimes.add(const TimeOfDay(hour: 20, minute: 0))),
                  icon: Icon(Icons.add_rounded, color: AppColors.primary),
                  label: Text('Add Time',
                      style: TextStyle(color: AppColors.primary)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;

                      final medicine = Medicine(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        dosage: dosageController.text.trim(),
                        frequency: frequency,
                        reminderTimes: reminderTimes
                            .map((t) =>
                                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
                            .toList(),
                        startDate: DateTime.now(),
                      );

                      DatabaseService().addMedicine(medicine.toJson());

                      // Schedule notifications and native alarms
                      for (int i = 0; i < reminderTimes.length; i++) {
                        NotificationService().scheduleMedicineReminder(
                          id: medicine.id.hashCode + i,
                          medicineName: medicine.name,
                          dosage: medicine.dosage,
                          hour: reminderTimes[i].hour,
                          minute: reminderTimes[i].minute,
                        );
                        
                        // Set native device alarm
                        NotificationService().setNativeAlarm(
                          hour: reminderTimes[i].hour,
                          minute: reminderTimes[i].minute,
                          message: 'Time to take ${medicine.name} (${medicine.dosage})',
                        );
                      }

                      // Add to history
                      DatabaseService().addHealthEvent(HealthEvent(
                        id: const Uuid().v4(),
                        title: 'Medicine Added: ${medicine.name}',
                        description: '${medicine.dosage} - ${medicine.frequency}',
                        type: HealthEventType.medicine,
                        date: DateTime.now(),
                      ).toJson());

                      Navigator.pop(context);
                      _loadMedicines();
                    },
                    child: const Text('Save Medicine'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

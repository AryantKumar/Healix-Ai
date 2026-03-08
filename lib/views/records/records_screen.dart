import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../models/health_record.dart';
import '../../models/health_event.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_card.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<HealthRecord> _records = [];
  String _selectedCategory = 'All';
  final _categories = ['All', ...AppConstants.documentTypes];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    final db = DatabaseService();
    final data = db.getRecords();
    setState(() {
      _records = data.map((e) => HealthRecord.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  List<HealthRecord> get _filteredRecords {
    if (_selectedCategory == 'All') return _records;
    return _records.where((r) => r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medical Records', style: AppTypography.headlineMedium),
      ),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Records list
          Expanded(
            child: _filteredRecords.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      return _buildRecordCard(_filteredRecords[index], index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addRecord',
        onPressed: _showAddRecordDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Record', style: AppTypography.button),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded,
              size: 72, color: AppColors.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No records yet', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text('Tap + to add your first medical record',
              style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRecordCard(HealthRecord record, int index) {
    final iconMap = {
      'Prescription': Icons.description_rounded,
      'Lab Report': Icons.science_rounded,
      'X-Ray': Icons.image_rounded,
      'Medical Note': Icons.note_alt_rounded,
      'Insurance': Icons.health_and_safety_rounded,
      'Other': Icons.folder_rounded,
    };

    final colorMap = {
      'Prescription': AppColors.chatGradient,
      'Lab Report': AppColors.recordsGradient,
      'X-Ray': AppColors.hospitalGradient,
      'Medical Note': AppColors.historyGradient,
      'Insurance': AppColors.medicineGradient,
      'Other': AppColors.primaryGradient,
    };

    return Dismissible(
      key: Key(record.id),
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
      onDismissed: (_) => _deleteRecord(record),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colorMap[record.category] ?? AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconMap[record.category] ?? Icons.folder_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.title,
                      style: AppTypography.titleMedium, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(record.category,
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(record.date),
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  if (record.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(record.notes!,
                        style: AppTypography.bodySmall, maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 22),
          ],
        ),
      ).animate().fadeIn(
            delay: Duration(milliseconds: 80 * index),
            duration: 400.ms,
          ),
    );
  }

  void _deleteRecord(HealthRecord record) {
    DatabaseService().deleteRecord(record.id);
    _loadRecords();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${record.title} deleted')),
    );
  }

  void _showAddRecordDialog() {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String category = AppConstants.documentTypes.first;
    DateTime date = DateTime.now();

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
              Text('Add Record', style: AppTypography.headlineLarge),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: AppTypography.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Record title',
                  prefixIcon: Icon(Icons.title_rounded),
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
                    value: category,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceLight,
                    style: AppTypography.bodyLarge,
                    items: AppConstants.documentTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setSheetState(() => category = v!),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: notesController,
                style: AppTypography.bodyLarge,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'File selected: ${result.files.single.name}')),
                          );
                        }
                      },
                      icon: const Icon(Icons.attach_file_rounded),
                      label: const Text('Attach File'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;

                    final record = HealthRecord(
                      id: const Uuid().v4(),
                      title: titleController.text.trim(),
                      category: category,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                      date: date,
                    );

                    DatabaseService().addRecord(record.toJson());

                    // Add to history
                    DatabaseService().addHealthEvent(HealthEvent(
                      id: const Uuid().v4(),
                      title: 'Record Added: ${record.title}',
                      description: 'Category: ${record.category}',
                      type: HealthEventType.record,
                      date: DateTime.now(),
                    ).toJson());

                    Navigator.pop(context);
                    _loadRecords();
                  },
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/health_event.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HealthEvent> _events = [];
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final db = DatabaseService();
    final data = db.getHealthHistory();
    setState(() {
      _events = data.map((e) => HealthEvent.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  List<HealthEvent> get _filteredEvents {
    if (_filter == 'All') return _events;
    return _events
        .where((e) => e.type.name.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health History', style: AppTypography.headlineMedium),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Symptom'),
                _buildFilterChip('Prescription'),
                _buildFilterChip('Visit'),
                _buildFilterChip('Record'),
                _buildFilterChip('Medicine'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _filteredEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) =>
                        _buildTimelineItem(_filteredEvents[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppColors.primary : AppColors.glassBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_rounded,
              size: 72, color: AppColors.textTertiary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No history yet', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text('Your health timeline will appear here',
              style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(HealthEvent event, int index) {
    final typeConfig = _getTypeConfig(event.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: typeConfig.color,
                  boxShadow: [
                    BoxShadow(
                      color: typeConfig.color.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (index < _filteredEvents.length - 1)
                Container(
                  width: 2,
                  height: 80,
                  color: AppColors.glassBorder,
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(typeConfig.icon, color: typeConfig.color, size: 18),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeConfig.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.type.name.toUpperCase(),
                        style: TextStyle(
                          color: typeConfig.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, HH:mm').format(event.date),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(event.title,
                    style: AppTypography.titleMedium, maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (event.description != null) ...[
                  const SizedBox(height: 4),
                  Text(event.description!,
                      style: AppTypography.bodySmall, maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 80 * index), duration: 400.ms);
  }

  _TypeConfig _getTypeConfig(HealthEventType type) {
    switch (type) {
      case HealthEventType.symptom:
        return _TypeConfig(Icons.thermostat_rounded, AppColors.warning);
      case HealthEventType.prescription:
        return _TypeConfig(Icons.description_rounded, AppColors.info);
      case HealthEventType.visit:
        return _TypeConfig(Icons.local_hospital_rounded, AppColors.error);
      case HealthEventType.record:
        return _TypeConfig(Icons.folder_rounded, AppColors.success);
      case HealthEventType.medicine:
        return _TypeConfig(Icons.medication_rounded, AppColors.accent);
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  _TypeConfig(this.icon, this.color);
}

// features/screens/history_screen.dart
// LB-Sentry | Report History Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../controllers/responder_controller.dart';
import '../models/emergency_model.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return Consumer<ResponderController>(
      builder: (context, controller, _) {
        final all = controller.historyList;
        final filtered = _filter == null
            ? all
            : all.where((e) => e.historyStatus == _filter).toList();

        final rejectedCount = all.where((e) => e.historyStatus == HistoryStatus.rejected).length;
        final missedCount = all.where((e) => e.historyStatus == HistoryStatus.missed).length;
        final completedCount = all.where((e) => e.historyStatus == HistoryStatus.completed).length;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report History'),
                Text('Your activity log', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
              ],
            ),
            actions: [
              if (_filter != null)
                TextButton(
                  onPressed: () => setState(() => _filter = null),
                  child: const Text('Clear', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          body: Column(
            children: [
              // ── Stats bar ──
              Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _StatPill(
                      label: 'Completed',
                      count: completedCount,
                      color: AppColors.resolved,
                      isActive: _filter == HistoryStatus.completed,
                      onTap: () => setState(() =>
                          _filter = _filter == HistoryStatus.completed ? null : HistoryStatus.completed),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      label: 'Rejected',
                      count: rejectedCount,
                      color: Colors.white54,
                      isActive: _filter == HistoryStatus.rejected,
                      onTap: () => setState(() =>
                          _filter = _filter == HistoryStatus.rejected ? null : HistoryStatus.rejected),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      label: 'Missed',
                      count: missedCount,
                      color: AppColors.arrived,
                      isActive: _filter == HistoryStatus.missed,
                      onTap: () => setState(() =>
                          _filter = _filter == HistoryStatus.missed ? null : HistoryStatus.missed),
                    ),
                  ],
                ),
              ),

              // ── Filter label ──
              if (_filter != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _filter!.color.withOpacity(0.08),
                  child: Row(
                    children: [
                      Icon(_filter!.icon, size: 14, color: _filter!.color),
                      const SizedBox(width: 6),
                      Text(
                        'Showing: ${_filter!.label} (${filtered.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _filter!.color,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── List ──
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty(all.isEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return HistoryCard(entry: filtered[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(bool noHistory) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noHistory ? Icons.history_toggle_off : Icons.filter_list_off,
            size: 64,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            noHistory ? 'No history yet' : 'No entries for this filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            noHistory
                ? 'Accept or reject emergencies to see them here'
                : 'Try a different filter',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StatPill({
    required this.label,
    required this.count,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.primary : Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppColors.textSecondary : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

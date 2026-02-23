import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/emergency_controller.dart';
import '../models/emergency_model.dart';

// ── Public helpers to show the dialogs ────────────────────────────────────────

/// Shows the Update Status dialog for the given [report].
void showUpdateStatusDialog(
    BuildContext context, EmergencyReport report, EmergencyController controller) {
  showDialog(
    context: context,
    builder: (_) => _UpdateStatusDialog(report: report, controller: controller),
  );
}

/// Shows the Assign Responder dialog for the given [report].
void showAssignResponderDialog(
    BuildContext context, EmergencyReport report, EmergencyController controller) {
  showDialog(
    context: context,
    builder: (_) => _AssignResponderDialog(report: report, controller: controller),
  );
}

// ── Update Status dialog ──────────────────────────────────────────────────────

class _UpdateStatusDialog extends StatelessWidget {
  const _UpdateStatusDialog({required this.report, required this.controller});
  final EmergencyReport report;
  final EmergencyController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Update Status',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: EmergencyStatus.values
            .map(
              (s) => _StatusOption(
                status: s,
                isSelected: report.status == s,
                onTap: () {
                  controller.updateStatus(report, s);
                  Navigator.of(context).pop();
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });
  final EmergencyStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      EmergencyStatus.active => AppColors.error,
      EmergencyStatus.pending => AppColors.warning,
      EmergencyStatus.resolved => AppColors.success,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(
              status.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(Icons.check_circle, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Assign Responder dialog ───────────────────────────────────────────────────

class _AssignResponderDialog extends StatefulWidget {
  const _AssignResponderDialog({required this.report, required this.controller});
  final EmergencyReport report;
  final EmergencyController controller;

  @override
  State<_AssignResponderDialog> createState() => _AssignResponderDialogState();
}

class _AssignResponderDialogState extends State<_AssignResponderDialog> {
  final _nameCtrl = TextEditingController();
  String _role = 'Firefighter';
  String _status = 'En route';

  static const _roles = [
    'Firefighter',
    'Paramedic',
    'Officer',
    'MDRRMO Rescuer',
    'Nurse',
    'Other',
  ];
  static const _statuses = ['En route', 'On scene', 'Available'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    widget.controller.assignResponder(
      widget.report,
      Responder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        role: _role,
        status: _status,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Assign Responder',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Responder Name',
              hintText: 'e.g. Firefighter Mike',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _roles
                .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _role = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _statuses
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _submit,
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

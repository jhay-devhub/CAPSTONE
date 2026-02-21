import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/help_report_model.dart';
import 'emergency_type_selector.dart';
import 'help_report_form_data.dart';
import 'report_form_fields.dart';
import 'report_photo_picker.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

/// Shows the report form as a modal bottom sheet.
///
/// Returns [HelpReportFormData] when the user submits or `null` when
/// the user cancels.
Future<HelpReportFormData?> showHelpReportFormSheet(
    BuildContext context) {
  return showModalBottomSheet<HelpReportFormData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HelpReportFormSheet(),
  );
}

// ── Root sheet widget ─────────────────────────────────────────────────────────

/// Stateful shell that owns all form state and delegates rendering to
/// focused sub-widgets imported from sibling files.
///
/// State fields:
///   [_selectedType]         – required emergency type (nullable until chosen)
///   [_descriptionController] – free-text description
///   [_injuryController]     – injury notes
///   [_photoPath]            – local path of the attached photo
///   [_isPickingPhoto]       – true while the image picker is active
///   [_showTypeError]        – true after a submit attempt with no type chosen
class _HelpReportFormSheet extends StatefulWidget {
  const _HelpReportFormSheet();

  @override
  State<_HelpReportFormSheet> createState() => _HelpReportFormSheetState();
}

class _HelpReportFormSheetState extends State<_HelpReportFormSheet> {
  EmergencyType? _selectedType;
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _injuryController = TextEditingController();
  String? _photoPath;
  bool _isPickingPhoto = false;
  bool _showTypeError = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _injuryController.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  void _handleTypeSelected(EmergencyType type) {
    setState(() {
      _selectedType = type;
      _showTypeError = false;
    });
  }

  Future<void> _handlePickPhotoRequested() async {
    setState(() => _isPickingPhoto = true);
    try {
      final path = await pickReportPhoto(context);
      if (path != null && mounted) {
        setState(() => _photoPath = path);
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _handlePhotoRemoved() => setState(() => _photoPath = null);

  void _handleSubmit() {
    if (_selectedType == null) {
      setState(() => _showTypeError = true);
      return;
    }

    final formData = HelpReportFormData(
      emergencyType: _selectedType!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      injuryNote: _injuryController.text.trim().isEmpty
          ? null
          : _injuryController.text.trim(),
      photoPath: _photoPath,
    );

    Navigator.of(context).pop(formData);
  }

  void _handleCancel() => Navigator.of(context).pop(null);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const _DragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    const _FormHeader(),
                    const SizedBox(height: 20),

                    // ── Emergency type (required) ──────────────────────────
                    _SectionLabel(
                      label: AppStrings.reportTypeLabel,
                      isRequired: true,
                    ),
                    const SizedBox(height: 8),
                    EmergencyTypeSelector(
                      selectedType: _selectedType,
                      onTypeSelected: _handleTypeSelected,
                      showValidationError: _showTypeError,
                    ),
                    const SizedBox(height: 20),

                    // ── Photo (optional) ───────────────────────────────────
                    const _SectionLabel(
                        label: AppStrings.reportPhotoLabel),
                    const SizedBox(height: 4),
                    _SectionSubtitle(
                        subtitle: AppStrings.reportPhotoSubtitle),
                    const SizedBox(height: 8),
                    ReportPhotoPicker(
                      photoPath: _photoPath,
                      isPickingPhoto: _isPickingPhoto,
                      onPickRequested: _handlePickPhotoRequested,
                      onPhotoRemoved: _handlePhotoRemoved,
                    ),
                    const SizedBox(height: 20),

                    // ── Description (optional) ─────────────────────────────
                    const _SectionLabel(
                        label: AppStrings.reportDescriptionLabel),
                    const SizedBox(height: 8),
                    ReportDescriptionField(
                        controller: _descriptionController),
                    const SizedBox(height: 20),

                    // ── Injury notes (optional) ────────────────────────────
                    const _SectionLabel(
                        label: AppStrings.reportInjuryLabel),
                    const SizedBox(height: 8),
                    ReportInjuryField(controller: _injuryController),
                    const SizedBox(height: 28),

                    // ── Action buttons ─────────────────────────────────────
                    _FormActionButtons(
                      onSubmit: _handleSubmit,
                      onCancel: _handleCancel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Private UI-only sub-widgets (no logic) ────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.reportFormTitle,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.reportFormSubtitle,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (isRequired)
          Text(
            ' *',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _SectionSubtitle extends StatelessWidget {
  const _SectionSubtitle({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Colors.black54),
    );
  }
}

class _FormActionButtons extends StatelessWidget {
  const _FormActionButtons({
    required this.onSubmit,
    required this.onCancel,
  });

  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppStrings.reportSendButton,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              AppStrings.helpDialogCancel,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}

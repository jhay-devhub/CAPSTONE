import '../../../models/help_report_model.dart';

/// Plain data object returned by [showHelpReportFormSheet] when the user
/// taps "Send Report". Contains all values collected from the form.
///
/// Returns `null` when the user cancels.
class HelpReportFormData {
  const HelpReportFormData({
    required this.emergencyType,
    this.description,
    this.injuryNote,
    this.photoPath,
  });

  /// Required – determines which response vehicle will be dispatched.
  final EmergencyType emergencyType;

  /// Optional – brief description of the situation.
  final String? description;

  /// Optional – description of any injuries.
  final String? injuryNote;

  /// Optional – local file path of the photo the user attached.
  final String? photoPath;

  @override
  String toString() =>
      'HelpReportFormData(type: ${emergencyType.label}, '
      'hasPhoto: ${photoPath != null})';
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_strings.dart';

/// Manages the image-source selection, picking, preview, and removal.
///
/// Responsibilities:
///   - Shows a bottom sheet to choose Camera vs Gallery.
///   - Calls [ImagePicker] and reports the result via [onPhotoSelected].
///   - Displays a preview of the selected photo.
///   - Allows removal via [onPhotoRemoved].
///
/// All state about whether a photo exists lives in the parent
/// (help_report_form_sheet.dart).
class ReportPhotoPicker extends StatelessWidget {
  const ReportPhotoPicker({
    super.key,
    required this.photoPath,
    required this.isPickingPhoto,
    required this.onPickRequested,
    required this.onPhotoRemoved,
  });

  /// Currently selected photo path, or `null` if none.
  final String? photoPath;

  /// True while the image picker is open / processing.
  final bool isPickingPhoto;

  /// Called when the user taps "Add Photo". The implementing widget should
  /// call [showImageSourceBottomSheet] and then update state.
  final VoidCallback onPickRequested;

  /// Called when the user taps the remove button on the preview.
  final VoidCallback onPhotoRemoved;

  @override
  Widget build(BuildContext context) {
    if (isPickingPhoto) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (photoPath != null) {
      return _PhotoPreview(
        photoPath: photoPath!,
        onRemove: onPhotoRemoved,
      );
    }

    return _AddPhotoButton(onTap: onPickRequested);
  }
}

// ── Helper function ───────────────────────────────────────────────────────────

/// Shows a bottom sheet prompting the user to choose Camera or Gallery,
/// then invokes [ImagePicker] and returns the file path on success.
///
/// Returns `null` when the user cancels or an error occurs.
Future<String?> pickReportPhoto(BuildContext context) async {
  final source = await _showImageSourceSheet(context);
  if (source == null) return null;

  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    return pickedFile?.path;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.photoPickError)),
      );
    }
    return null;
  }
}

/// Bottom sheet for choosing between Camera and Gallery.
Future<ImageSource?> _showImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text(AppStrings.photoSourceCamera),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text(AppStrings.photoSourceGallery),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

/// Button shown when no photo has been attached yet.
class _AddPhotoButton extends StatelessWidget {
  const _AddPhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text(AppStrings.reportPhotoPickButton),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(double.infinity, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Preview of the selected photo with a remove button.
class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.photoPath,
    required this.onRemove,
  });

  final String photoPath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(photoPath),
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _RemoveButton(onTap: onRemove),
        ),
      ],
    );
  }
}

/// Small circular button overlaid on the photo preview.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.close, size: 18, color: Colors.white),
      ),
    );
  }
}

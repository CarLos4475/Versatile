import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

class EditorialPhotosState {
  final bool enabled;
  final String? moodboardPath;
  final String? backCoverPath;
  final String moodboardQuote;
  final String backCoverQuote;
  final double moodboardAlignX;
  final double moodboardAlignY;
  final double backCoverAlignX;
  final double backCoverAlignY;
  final double moodboardScale;
  final double backCoverScale;

  const EditorialPhotosState({
    required this.enabled,
    this.moodboardPath,
    this.backCoverPath,
    required this.moodboardQuote,
    required this.backCoverQuote,
    required this.moodboardAlignX,
    required this.moodboardAlignY,
    required this.backCoverAlignX,
    required this.backCoverAlignY,
    required this.moodboardScale,
    required this.backCoverScale,
  });

  EditorialPhotosState copyWith({
    bool? enabled,
    String? moodboardPath,
    String? backCoverPath,
    String? moodboardQuote,
    String? backCoverQuote,
    double? moodboardAlignX,
    double? moodboardAlignY,
    double? backCoverAlignX,
    double? backCoverAlignY,
    double? moodboardScale,
    double? backCoverScale,
  }) {
    return EditorialPhotosState(
      enabled: enabled ?? this.enabled,
      moodboardPath: moodboardPath ?? this.moodboardPath,
      backCoverPath: backCoverPath ?? this.backCoverPath,
      moodboardQuote: moodboardQuote ?? this.moodboardQuote,
      backCoverQuote: backCoverQuote ?? this.backCoverQuote,
      moodboardAlignX: moodboardAlignX ?? this.moodboardAlignX,
      moodboardAlignY: moodboardAlignY ?? this.moodboardAlignY,
      backCoverAlignX: backCoverAlignX ?? this.backCoverAlignX,
      backCoverAlignY: backCoverAlignY ?? this.backCoverAlignY,
      moodboardScale: moodboardScale ?? this.moodboardScale,
      backCoverScale: backCoverScale ?? this.backCoverScale,
    );
  }
}

final editorialPhotosProvider =
    StateNotifierProvider<EditorialPhotosNotifier, EditorialPhotosState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return EditorialPhotosNotifier(repo);
});

class EditorialPhotosNotifier extends StateNotifier<EditorialPhotosState> {
  final SettingsRepository _repo;

  EditorialPhotosNotifier(this._repo)
      : super(const EditorialPhotosState(
          enabled: false,
          moodboardPath: null,
          backCoverPath: null,
          moodboardQuote: '',
          backCoverQuote: '',
          moodboardAlignX: 0.0,
          moodboardAlignY: 0.0,
          backCoverAlignX: 0.0,
          backCoverAlignY: 0.0,
          moodboardScale: 1.0,
          backCoverScale: 1.0,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _repo.getEditorialPhotosEnabled();
    final moodboard = await _repo.getEditorialPhotoMoodboardPath();
    final backCover = await _repo.getEditorialPhotoBackCoverPath();
    final moodboardQ = await _repo.getEditorialQuoteMoodboard() ?? '';
    final backCoverQ = await _repo.getEditorialQuoteBackCover() ?? '';
    final mbAlignX = await _repo.getEditorialMoodboardAlignX();
    final mbAlignY = await _repo.getEditorialMoodboardAlignY();
    final bcAlignX = await _repo.getEditorialBackCoverAlignX();
    final bcAlignY = await _repo.getEditorialBackCoverAlignY();
    final mbScale = await _repo.getEditorialMoodboardScale();
    final bcScale = await _repo.getEditorialBackCoverScale();

    // Check if files actually exist on disk, otherwise reset to null
    String? validMoodboard;
    if (moodboard != null && moodboard.isNotEmpty) {
      if (await File(moodboard).exists()) {
        validMoodboard = moodboard;
      }
    }
    String? validBackCover;
    if (backCover != null && backCover.isNotEmpty) {
      if (await File(backCover).exists()) {
        validBackCover = backCover;
      }
    }

    state = EditorialPhotosState(
      enabled: enabled,
      moodboardPath: validMoodboard,
      backCoverPath: validBackCover,
      moodboardQuote: moodboardQ,
      backCoverQuote: backCoverQ,
      moodboardAlignX: mbAlignX,
      moodboardAlignY: mbAlignY,
      backCoverAlignX: bcAlignX,
      backCoverAlignY: bcAlignY,
      moodboardScale: mbScale,
      backCoverScale: bcScale,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _repo.setEditorialPhotosEnabled(enabled);
  }

  Future<void> setMoodboardQuote(String quote) async {
    state = state.copyWith(moodboardQuote: quote);
    await _repo.setEditorialQuoteMoodboard(quote);
  }

  Future<void> setBackCoverQuote(String quote) async {
    state = state.copyWith(backCoverQuote: quote);
    await _repo.setEditorialQuoteBackCover(quote);
  }

  Future<void> saveMoodboardPhoto(PlatformFile pickedFile) async {
    final newPath = await _savePhotoLocal(pickedFile, 'moodboard');
    if (newPath != null) {
      // Delete old photo file if it exists
      if (state.moodboardPath != null) {
        await _deleteFile(state.moodboardPath!);
      }
      state = state.copyWith(moodboardPath: newPath);
      await _repo.setEditorialPhotoMoodboardPath(newPath);
    }
  }

  Future<void> saveBackCoverPhoto(PlatformFile pickedFile) async {
    final newPath = await _savePhotoLocal(pickedFile, 'back_cover');
    if (newPath != null) {
      // Delete old photo file if it exists
      if (state.backCoverPath != null) {
        await _deleteFile(state.backCoverPath!);
      }
      state = state.copyWith(backCoverPath: newPath);
      await _repo.setEditorialPhotoBackCoverPath(newPath);
    }
  }

  Future<void> removeMoodboardPhoto() async {
    if (state.moodboardPath != null) {
      await _deleteFile(state.moodboardPath!);
    }
    state = state.copyWith(moodboardPath: null);
    await _repo.setEditorialPhotoMoodboardPath(null);
  }

  Future<void> removeBackCoverPhoto() async {
    if (state.backCoverPath != null) {
      await _deleteFile(state.backCoverPath!);
    }
    state = state.copyWith(backCoverPath: null);
    await _repo.setEditorialPhotoBackCoverPath(null);
  }

  Future<void> setMoodboardTransform(double x, double y, double scale) async {
    state = state.copyWith(
      moodboardAlignX: x,
      moodboardAlignY: y,
      moodboardScale: scale,
    );
    await _repo.setEditorialMoodboardAlignX(x);
    await _repo.setEditorialMoodboardAlignY(y);
    await _repo.setEditorialMoodboardScale(scale);
  }

  Future<void> setBackCoverTransform(double x, double y, double scale) async {
    state = state.copyWith(
      backCoverAlignX: x,
      backCoverAlignY: y,
      backCoverScale: scale,
    );
    await _repo.setEditorialBackCoverAlignX(x);
    await _repo.setEditorialBackCoverAlignY(y);
    await _repo.setEditorialBackCoverScale(scale);
  }

  Future<String?> _savePhotoLocal(PlatformFile picked, String prefix) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${dir.path}/editorial_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final ext = picked.extension ?? 'jpg';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destPath = '${photosDir.path}/${prefix}_$timestamp.$ext';
      final destFile = File(destPath);

      if (picked.bytes != null) {
        await destFile.writeAsBytes(picked.bytes!);
      } else if (picked.path != null) {
        await File(picked.path!).copy(destPath);
      } else {
        return null;
      }
      return destPath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

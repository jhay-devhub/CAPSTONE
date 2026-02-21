import 'package:flutter/material.dart';
import '../models/safety_tip_model.dart';

/// Provides safety tips list and optional category filtering.
class SafetyTipsController extends ChangeNotifier {
  SafetyTipsController() {
    _loadTips();
  }

  // ── State ─────────────────────────────────────────────────────────────────
  List<SafetyTipModel> _allTips = [];
  SafetyTipCategory? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  List<SafetyTipModel> get allTips => _allTips;
  SafetyTipCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<SafetyTipModel> get filteredTips {
    if (_selectedCategory == null) return _allTips;
    return _allTips
        .where((tip) => tip.category == _selectedCategory)
        .toList(growable: false);
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  void filterByCategory(SafetyTipCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> refreshTips() async {
    _errorMessage = null;
    await _loadTips();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _loadTips() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with API / local database call.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _allTips = _defaultTips;
    } catch (e) {
      debugPrint('[SafetyTipsController] _loadTips error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const List<SafetyTipModel> _defaultTips = [
    SafetyTipModel(
      id: 1,
      title: 'Stay Calm',
      description:
          'Keep a clear head. Assess the situation before taking action to avoid making things worse.',
      icon: Icons.self_improvement,
      category: SafetyTipCategory.general,
    ),
    SafetyTipModel(
      id: 2,
      title: 'Call for Help',
      description:
          'Dial your local emergency number immediately. Provide your name, location, and the type of emergency.',
      icon: Icons.phone_in_talk,
      category: SafetyTipCategory.general,
    ),
    SafetyTipModel(
      id: 3,
      title: 'Stop, Drop & Roll',
      description:
          'If your clothes catch fire: stop moving, drop to the ground, and roll to smother the flames.',
      icon: Icons.local_fire_department,
      category: SafetyTipCategory.fire,
    ),
    SafetyTipModel(
      id: 4,
      title: 'Evacuate Early',
      description:
          'Do not wait for a fire to worsen. Leave the building through the nearest safe exit and alert others.',
      icon: Icons.exit_to_app,
      category: SafetyTipCategory.fire,
    ),
    SafetyTipModel(
      id: 5,
      title: 'Move to Higher Ground',
      description:
          'When flooding is active, immediately move to higher ground. Avoid walking through moving water.',
      icon: Icons.terrain,
      category: SafetyTipCategory.flood,
    ),
    SafetyTipModel(
      id: 6,
      title: 'Stay Away from Drains',
      description:
          'Flood water near drains and gutters can be extremely dangerous. Keep a safe distance.',
      icon: Icons.warning_amber,
      category: SafetyTipCategory.flood,
    ),
    SafetyTipModel(
      id: 7,
      title: 'Apply Pressure to Wounds',
      description:
          'For serious bleeding, apply firm pressure with a clean cloth and keep it there until help arrives.',
      icon: Icons.healing,
      category: SafetyTipCategory.medical,
    ),
    SafetyTipModel(
      id: 8,
      title: 'Recovery Position',
      description:
          'If someone is unconscious but breathing, place them on their side to prevent choking.',
      icon: Icons.accessibility_new,
      category: SafetyTipCategory.medical,
    ),
    SafetyTipModel(
      id: 9,
      title: 'Drop, Cover & Hold On',
      description:
          'During an earthquake: drop to hands and knees, take cover under sturdy furniture, and hold on.',
      icon: Icons.home,
      category: SafetyTipCategory.earthquake,
    ),
    SafetyTipModel(
      id: 10,
      title: 'Stay Indoors',
      description:
          'Most injuries occur when people try to move during shaking. Stay inside until the quake stops.',
      icon: Icons.door_front_door,
      category: SafetyTipCategory.earthquake,
    ),
  ];
}

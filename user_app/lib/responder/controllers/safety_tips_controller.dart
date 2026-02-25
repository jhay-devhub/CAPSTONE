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
    // ── General ─────────────────────────────────────────────────────────
    SafetyTipModel(
      id: 1,
      title: 'Stay Calm',
      description: 'Keep a clear head. Assess the situation before taking action.',
      icon: Icons.self_improvement,
      category: SafetyTipCategory.general,
      steps: [
        'Stop what you are doing and take a deep breath.',
        'Look around and assess the situation calmly.',
        'Identify the type of emergency you are facing.',
        'Decide on the safest course of action before moving.',
      ],
    ),
    SafetyTipModel(
      id: 2,
      title: 'Call for Help',
      description: 'Dial your local emergency number immediately.',
      icon: Icons.phone_in_talk,
      category: SafetyTipCategory.general,
      steps: [
        'Dial your local emergency number (e.g. 911 or 143).',
        'Clearly state your name and exact location.',
        'Describe the type of emergency and number of people involved.',
        'Follow the dispatcher\'s instructions and stay on the line.',
      ],
    ),

    // ── Fire ─────────────────────────────────────────────────────────────
    SafetyTipModel(
      id: 3,
      title: 'Stop, Drop & Roll',
      description: 'If your clothes catch fire, stop, drop, and roll.',
      icon: Icons.local_fire_department,
      category: SafetyTipCategory.fire,
      steps: [
        'STOP – Do not run. Running fans the flames.',
        'DROP – Lie flat on the ground immediately.',
        'ROLL – Roll back and forth to smother the flames.',
        'Cool burned areas with cool water and seek medical help.',
      ],
    ),
    SafetyTipModel(
      id: 4,
      title: 'Evacuate Early',
      description: 'Do not wait for a fire to worsen. Leave immediately.',
      icon: Icons.exit_to_app,
      category: SafetyTipCategory.fire,
      steps: [
        'Alert everyone in the building by shouting "Fire!".',
        'Use the nearest safe exit – never use elevators.',
        'Stay low to the ground if there is smoke.',
        'Meet at the designated evacuation point and call for help.',
      ],
    ),

    // ── Flood ────────────────────────────────────────────────────────────
    SafetyTipModel(
      id: 5,
      title: 'Move to Higher Ground',
      description: 'Immediately move to higher ground when flooding begins.',
      icon: Icons.terrain,
      category: SafetyTipCategory.flood,
      steps: [
        'Monitor weather alerts and warnings in your area.',
        'Move to the highest floor or elevated ground nearby.',
        'Avoid walking or driving through floodwater.',
        'Wait for official clearance before returning to low areas.',
      ],
    ),
    SafetyTipModel(
      id: 6,
      title: 'Stay Away from Drains',
      description: 'Flood water near drains can be extremely dangerous.',
      icon: Icons.warning_amber,
      category: SafetyTipCategory.flood,
      steps: [
        'Keep a safe distance from storm drains and gutters.',
        'Never attempt to clear a blocked drain during a flood.',
        'Watch for fast-moving water near drainage openings.',
        'Report dangerous flooding conditions to authorities.',
      ],
    ),

    // ── Medical ──────────────────────────────────────────────────────────
    SafetyTipModel(
      id: 7,
      title: 'Apply Pressure to Wounds',
      description: 'For serious bleeding, apply firm pressure.',
      icon: Icons.healing,
      category: SafetyTipCategory.medical,
      steps: [
        'Use a clean cloth or bandage to cover the wound.',
        'Apply firm, steady pressure directly on the wound.',
        'Keep the pressure for at least 10 minutes without lifting.',
        'If blood soaks through, add more cloth on top – do not remove.',
      ],
    ),
    SafetyTipModel(
      id: 8,
      title: 'Recovery Position',
      description: 'Place an unconscious breathing person on their side.',
      icon: Icons.accessibility_new,
      category: SafetyTipCategory.medical,
      steps: [
        'Kneel beside the person and straighten their legs.',
        'Place the arm nearest to you at a right angle to their body.',
        'Bring the far arm across their chest and hold hand against cheek.',
        'Pull the far knee up and roll them gently toward you onto their side.',
      ],
    ),

    // ── Earthquake ───────────────────────────────────────────────────────
    SafetyTipModel(
      id: 9,
      title: 'Drop, Cover & Hold On',
      description: 'During an earthquake: drop, take cover, and hold on.',
      icon: Icons.home,
      category: SafetyTipCategory.earthquake,
      steps: [
        'DROP – Get on your hands and knees to prevent falling.',
        'COVER – Get under a sturdy desk or table.',
        'HOLD ON – Grip the furniture and protect your head/neck.',
        'Stay in position until the shaking completely stops.',
      ],
    ),
    SafetyTipModel(
      id: 10,
      title: 'Stay Indoors',
      description: 'Most injuries occur when people try to move during shaking.',
      icon: Icons.door_front_door,
      category: SafetyTipCategory.earthquake,
      steps: [
        'Stay inside – do not run outside during the quake.',
        'Move away from windows, mirrors, and heavy objects.',
        'If in bed, cover your head with a pillow and stay put.',
        'After shaking stops, check for injuries and structural damage.',
      ],
    ),
  ];
}

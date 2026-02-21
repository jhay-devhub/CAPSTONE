import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../controllers/safety_tips_controller.dart';
import 'widgets/safety_tip_card_widget.dart';
import 'widgets/category_filter_bar.dart';

/// Displays a filterable list of emergency safety tips.
class SafetyTipsScreen extends StatefulWidget {
  const SafetyTipsScreen({super.key});

  @override
  State<SafetyTipsScreen> createState() => _SafetyTipsScreenState();
}

class _SafetyTipsScreenState extends State<SafetyTipsScreen>
    with AutomaticKeepAliveClientMixin {
  final SafetyTipsController _controller = SafetyTipsController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.safetyTipsTitle),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
            return _ErrorState(
              message: _controller.errorMessage!,
              onRetry: _controller.refreshTips,
            );
          }

          final tips = _controller.filteredTips;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              CategoryFilterBar(
                selectedCategory: _controller.selectedCategory,
                onCategorySelected: _controller.filterByCategory,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tips.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _controller.refreshTips,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: tips.length,
                          itemBuilder: (context, index) =>
                              SafetyTipCardWidget(tip: tips[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Small state widgets ───────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No tips available for this category.'),
    );
  }
}

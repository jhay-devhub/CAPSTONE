import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/emergency_controller.dart';
import '../models/emergency_model.dart';

/// Right side panel — shows incident info header and a chat thread
/// between the admin and the emergency reporter / responders.
class EmergencyChatPanel extends StatefulWidget {
  const EmergencyChatPanel({super.key, required this.controller});

  final EmergencyController controller;

  @override
  State<EmergencyChatPanel> createState() => _EmergencyChatPanelState();
}

class _EmergencyChatPanelState extends State<EmergencyChatPanel> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  EmergencyController get _ctrl => widget.controller;

  void _send() {
    final text = _textCtrl.text;
    _ctrl.sendMessage(text);
    _textCtrl.clear();
    // Scroll to bottom after a brief frame delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Obx(() {
          final selected = _ctrl.selectedReport.value;

          // No selection yet
          if (selected == null) {
            return const _EmptyChat();
          }

          return Column(
            children: [
              _IncidentHeader(report: selected),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: _ChatMessageList(
                  messages: _ctrl.chatMessages,
                  scrollCtrl: _scrollCtrl,
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _ChatInput(
                controller: _textCtrl,
                onSend: _send,
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.background,
          child: const Text(
            'Chat with Reporter',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 36, color: AppColors.textHint),
                SizedBox(height: 10),
                Text(
                  'Select an incident',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap a report on the left to open chat',
                  style: TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Incident header ───────────────────────────────────────────────────────────

class _IncidentHeader extends StatelessWidget {
  const _IncidentHeader({required this.report});
  final EmergencyReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.address,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${report.type.label} • ${report.id}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat message list ─────────────────────────────────────────────────────────

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({
    required this.messages,
    required this.scrollCtrl,
  });
  final List<ChatMessage> messages;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
      );
    }
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (_, i) => _ChatBubble(message: messages[i]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isAdmin;
    final time = DateFormat('hh:mm a').format(message.sentAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary
                  : const Color(0xFF2D3748),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isAdmin ? 12 : 2),
                bottomRight: Radius.circular(isAdmin ? 2 : 12),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${message.senderName} • $time',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat input bar ────────────────────────────────────────────────────────────

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
  });
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onSend,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child:
                    Icon(Icons.send_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

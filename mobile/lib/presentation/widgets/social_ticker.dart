import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Social ticker with marquee-style scrolling.
///
/// Displays recent campaign activities in a horizontal scrolling strip.
class SocialTicker extends StatefulWidget {
  final List<String> items;

  const SocialTicker({super.key, required this.items});

  @override
  State<SocialTicker> createState() => _SocialTickerState();
}

class _SocialTickerState extends State<SocialTicker> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted) return;
      _offset += 0.5;
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (_offset >= maxExtent) {
          _offset = 0;
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_offset);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox(height: 28);

    final text = widget.items.join('  •  ');

    return Container(
      height: 28,
      color: AppTheme.surface,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Text(
              '$text  •  $text',
              style: AppTheme.bodySmall.copyWith(fontSize: 12),
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}

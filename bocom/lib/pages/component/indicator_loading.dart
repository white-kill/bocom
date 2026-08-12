import 'package:flutter/material.dart';

class BocomLoading {
  BocomLoading._();

  static const _asset =
      'assets/images/account_transfer/transfer_loading_arc.png';

  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() action, {
    Alignment alignment = Alignment.center,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => _TransferLoadingOverlay(alignment: alignment),
    );
    overlay.insert(entry);
    try {
      return await action();
    } finally {
      entry.remove();
      entry.dispose();
    }
  }

  static Future<void> show(
    BuildContext context, {
    Duration duration = const Duration(seconds: 2),
    Alignment alignment = Alignment.center,
  }) {
    return run(
      context,
      () => Future<void>.delayed(duration),
      alignment: alignment,
    );
  }
}

class _TransferLoadingOverlay extends StatelessWidget {
  const _TransferLoadingOverlay({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(dismissible: false, color: Colors.transparent),
        Align(alignment: alignment, child: const _TransferLoadingIndicator()),
      ],
    );
  }
}

class _TransferLoadingIndicator extends StatefulWidget {
  const _TransferLoadingIndicator();

  @override
  State<_TransferLoadingIndicator> createState() =>
      _TransferLoadingIndicatorState();
}

class _TransferLoadingIndicatorState extends State<_TransferLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '加载中',
      child: RotationTransition(
        key: const Key('transfer-loading-indicator'),
        turns: _controller,
        child: Image.asset(
          BocomLoading._asset,
          width: 34,
          height: 34,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/i18n/base_translation.dart';
import '../../core/i18n/lang.dart';
import '../../core/utils.dart';
import '../../entities/qr_code_data.dart';
import '../controllers/app_controller.dart';
import '../widgets/qr_code_widget.dart';

class QrFullScreenArgs {
  const QrFullScreenArgs({required this.initialIndex, required this.data, this.autoPlay = false});

  final int initialIndex;
  final QrCodeData data;
  final bool autoPlay;
}

class QrFullScreenPage extends StatefulWidget {
  const QrFullScreenPage({super.key, required this.appController, required this.args});

  final AppController appController;
  final QrFullScreenArgs args;

  static const route = '/qr-full-screen';

  static void open(QrFullScreenArgs args) => Utils.open(route, args);

  @override
  State<QrFullScreenPage> createState() => _QrFullScreenPageState();
}

class _QrFullScreenPageState extends State<QrFullScreenPage> {
  late int currentIndex;
  late bool isAutoPlaying;
  Timer? _timer;
  final autoPlayDelayIndex = ValueNotifier<int>(0);

  final delays = const [
    Duration(seconds: 2),
    Duration(seconds: 1),
    Duration(milliseconds: 500),
    Duration(milliseconds: 300),
    Duration(milliseconds: 100),
  ];

  Duration get autoPlayDelay => delays[autoPlayDelayIndex.value % delays.length];
  BaseTranslation get translation => widget.appController.lang.translation;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.args.initialIndex;
    isAutoPlaying = widget.args.autoPlay;

    if (isAutoPlaying) startAutoPlay();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalChunks = widget.args.data.chunks.length;
    final isSingleChunk = totalChunks <= 1;
    final isFirstChuck = currentIndex <= 0;
    final isLastChuck = currentIndex >= totalChunks - 1;

    return Scaffold(
      appBar: AppBar(
        title:
            isSingleChunk
                ? null
                : Text(translation.global.indexRange(currentIndex + 1, totalChunks)),
        centerTitle: true,
        actions:
            isSingleChunk
                ? null
                : [
                  if (currentIndex > 0)
                    IconButton(
                      key: UniqueKey(), // Avoiding (ghost) tap animation on second button
                      onPressed: onBackToInitTap,
                      icon: const Icon(Icons.replay_rounded),
                    ),
                  IconButton(
                    onPressed: () {
                      autoPlayDelayIndex.value++;
                      if (isAutoPlaying) playQrCodes();
                    },
                    icon: Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: autoPlayDelayIndex,
                          builder: (context, value, child) {
                            return Text('${autoPlayDelay.inMilliseconds / 1000}s');
                          },
                        ),
                        SizedBox(width: AppSettings.spacing.small),
                        const Icon(Icons.fast_forward_outlined),
                      ],
                    ),
                  ),
                ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSettings.spacing.small),
          child: QrCodeWidget(
            data: widget.args.data.chunks[currentIndex],
            level: widget.args.data.level,
          ),
        ),
      ),
      bottomNavigationBar:
          isSingleChunk
              ? null
              : BottomAppBar(
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:
                      [
                        _BottomIconButton(
                          onTap: onBackTap,
                          isEnabled: !isFirstChuck,
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        _BottomIconButton(
                          onTap: onPlayTap,
                          isEnabled: !isLastChuck,
                          icon: const Icon(Icons.pause_circle_outline),
                        ),
                        _BottomIconButton(
                          onTap: onForwardTap,
                          isEnabled: !isLastChuck,
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ].map((child) => Expanded(child: child)).toList(),
                ),
              ),
    );
  }

  Future<void> startAutoPlay() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Utils.notify(translation.readBatchQrCodesAlert),
    );
    await Future.delayed(const Duration(seconds: 4));
    playQrCodes();
  }

  void onBackToInitTap() {
    setState(() {
      currentIndex = 0;
      isAutoPlaying = false;
    });
    stopAutoPlayQrCodes();
  }

  void onBackTap() {
    stopAutoPlayQrCodes();
    setState(() => currentIndex--);
  }

  void onForwardTap() {
    stopAutoPlayQrCodes();
    setState(() => currentIndex++);
  }

  Future<void> onPlayTap() async {
    setState(() => isAutoPlaying = !isAutoPlaying);
    if (isAutoPlaying) await Future.delayed(const Duration(seconds: 1));
    isAutoPlaying ? playQrCodes() : stopAutoPlayQrCodes();
  }

  void playQrCodes() {
    setState(() => isAutoPlaying = true);
    _timer?.cancel();

    _timer = Timer.periodic(autoPlayDelay, (timer) {
      if (!mounted || !isAutoPlaying) return;

      final totalLenght = widget.args.data.chunks.length;
      if (currentIndex >= totalLenght - 1) {
        stopAutoPlayQrCodes();
        return;
      }

      setState(() => currentIndex = (currentIndex + 1) % totalLenght);
    });
  }

  void stopAutoPlayQrCodes() {
    if (mounted) setState(() => isAutoPlaying = false);
    cancelTimer();
  }

  void cancelTimer() => _timer?.cancel();
}

class _BottomIconButton extends StatelessWidget {
  const _BottomIconButton({required this.icon, required this.onTap, required this.isEnabled});

  final Widget icon;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Opacity(opacity: isEnabled ? 1 : .2, child: icon),
    );
  }
}

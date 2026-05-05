import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/weight_entry.dart';
import '../../providers/weight_provider.dart';
import '../../services/ocr_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/soft_button.dart';
import '../../widgets/soft_card.dart';
import 'widgets/ocr_confirm_sheet.dart';
import 'widgets/upload_zone.dart';

class OcrPage extends ConsumerStatefulWidget {
  const OcrPage({super.key});

  @override
  ConsumerState<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends ConsumerState<OcrPage> {
  final OcrService _ocrService = OcrService();
  final List<double> _recentReadings = [];

  CameraController? _cameraController;
  Timer? _scanTimer;
  bool _isInitializing = true;
  bool _isProcessing = false;
  bool _permissionDenied = false;
  bool _isBottomSheetOpen = false;
  String _statusText = 'Abrindo câmera e preparando a leitura automática.';
  double? _detectedWeight;
  double _minZoomLevel = 1;
  double _maxZoomLevel = 1;
  double _zoomLevel = 1;
  double _baseZoomLevel = 1;
  int _activePointers = 0;
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraController?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _permissionDenied = false;
      _statusText = 'Solicitando acesso à câmera.';
    });

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
        _permissionDenied = true;
        _statusText = 'Permita o uso da câmera para ler o peso da balança.';
      });
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
        _statusText = 'Nenhuma câmera disponível neste dispositivo.';
      });
      return;
    }

    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    double minZoomLevel = 1;
    double maxZoomLevel = 1;
    try {
      minZoomLevel = await controller.getMinZoomLevel();
      maxZoomLevel = await controller.getMaxZoomLevel();
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFlashMode(FlashMode.off);
      await controller.setZoomLevel(minZoomLevel);
    } catch (_) {
      minZoomLevel = 1;
      maxZoomLevel = 1;
    }

    await _cameraController?.dispose();
    _cameraController = controller;

    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializing = false;
      _statusText = 'Aponte a câmera para o visor da balança até o peso estabilizar.';
      _minZoomLevel = minZoomLevel;
      _maxZoomLevel = maxZoomLevel;
      _zoomLevel = minZoomLevel;
      _baseZoomLevel = minZoomLevel;
      _flashEnabled = false;
    });
    _startScanning();
  }

  Future<void> _setZoomLevel(double zoomLevel) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final nextZoom = zoomLevel.clamp(_minZoomLevel, _maxZoomLevel);
    await controller.setZoomLevel(nextZoom);
    if (!mounted) {
      return;
    }
    setState(() {
      _zoomLevel = nextZoom;
    });
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final nextEnabled = !_flashEnabled;
    try {
      await controller.setFlashMode(nextEnabled ? FlashMode.torch : FlashMode.off);
      if (!mounted) {
        return;
      }
      setState(() {
        _flashEnabled = nextEnabled;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppToast.show(context, 'A lanterna não está disponível nesta câmera.');
    }
  }

  void _handlePointerDown(PointerDownEvent _) {
    _activePointers += 1;
  }

  void _handlePointerUp(PointerUpEvent _) {
    _activePointers = (_activePointers - 1).clamp(0, 10);
  }

  void _handleScaleStart(ScaleStartDetails _) {
    _baseZoomLevel = _zoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_activePointers < 2) {
      return;
    }
    unawaited(_setZoomLevel(_baseZoomLevel * details.scale));
  }

  void _startScanning() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: 1400),
      (_) => unawaited(_scanWeight()),
    );
  }

  Future<void> _scanWeight() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isProcessing ||
        _isBottomSheetOpen) {
      return;
    }

    _isProcessing = true;
    if (mounted) {
      setState(() {
        _statusText = 'Lendo o visor da balança...';
      });
    }

    XFile? capture;
    try {
      capture = await controller.takePicture();
      final detected = await _ocrService.extractWeightFromFile(capture.path);
      if (!mounted) {
        return;
      }

      if (detected == null) {
        setState(() {
          _statusText = 'Nenhum peso valido detectado ainda. Ajuste o enquadramento.';
        });
        return;
      }

      _detectedWeight = detected;
      _recentReadings.add(detected);
      if (_recentReadings.length > 5) {
        _recentReadings.removeAt(0);
      }

      if (_ocrService.isStableReading(_recentReadings)) {
        setState(() {
          _statusText = 'Peso estabilizado. Abrindo confirmacao.';
        });
        _scanTimer?.cancel();
        await _openConfirmationSheet(detected);
        return;
      }

      setState(() {
        _statusText = 'Peso ${detected.toStringAsFixed(1)} kg detectado. Aguardando estabilizar.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusText = 'Falha ao capturar a leitura. Tente manter a câmera firme.';
      });
    } finally {
      _isProcessing = false;
      final path = capture?.path;
      if (path != null) {
        unawaited(() async {
          try {
            await _ocrService.deleteTempCrop(path);
            await File(path).delete();
          } catch (_) {
            // Ignora falhas ao limpar a captura temporaria.
          }
        }());
      }
    }
  }

  Future<void> _openConfirmationSheet(double weight) async {
    _isBottomSheetOpen = true;
    final confirmedWeight = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return OcrConfirmSheet(
          initialWeight: weight,
          onConfirm: (value) => Navigator.of(sheetContext).pop(value),
        );
      },
    );
    _isBottomSheetOpen = false;

    if (!mounted) {
      return;
    }

    if (confirmedWeight != null) {
      ref.read(weightProvider.notifier).saveEntry(
            weight: confirmedWeight,
            recordedAt: DateTime.now(),
            note: 'Leitura automática da balança',
            type: WeightEntryType.ocr,
          );
      AppToast.show(context, 'Peso ${confirmedWeight.toStringAsFixed(1)} kg registrado com sucesso.');
      setState(() {
        _statusText = 'Registro salvo. Voce pode apontar para uma nova leitura.';
      });
    } else {
      setState(() {
        _statusText = 'Leitura cancelada. Continue apontando para a balança.';
      });
    }

    _recentReadings.clear();
    _detectedWeight = null;
    _startScanning();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          'Leitura automática da balança',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          'Abra a câmera, alinhe o visor da balança e use o zoom se estiver longe. O app registra o peso quando a leitura estiver estável.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.x4),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isInitializing)
                const AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_permissionDenied)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Câmera bloqueada',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      _statusText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    SoftButton.primary(
                      label: 'Permitir câmera',
                      icon: Icons.videocam_rounded,
                      onPressed: _initializeCamera,
                    ),
                  ],
                )
              else if (controller != null && controller.value.isInitialized)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UploadZone(
                      controller: controller,
                      detectedWeight: _detectedWeight,
                      statusText: _statusText,
                      isProcessing: _isProcessing,
                      flashEnabled: _flashEnabled,
                      onFlashToggle: _toggleFlash,
                      onPointerDown: _handlePointerDown,
                      onPointerUp: _handlePointerUp,
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                    ),
                    if (_maxZoomLevel > _minZoomLevel + 0.05) ...[
                      const SizedBox(height: AppSpacing.x4),
                      Text(
                        'Zoom da câmera: ${_zoomLevel.toStringAsFixed(1)}x',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _zoomLevel.clamp(_minZoomLevel, _maxZoomLevel),
                        min: _minZoomLevel,
                        max: _maxZoomLevel,
                        onChanged: (value) => unawaited(_setZoomLevel(value)),
                      ),
                    ],
                  ],
                )
              else
                Text(
                  _statusText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: AppSpacing.x4),
              Row(
                children: [
                  Expanded(
                    child: SoftButton.secondary(
                      label: 'Ler novamente',
                      icon: Icons.refresh_rounded,
                      onPressed: _initializeCamera,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

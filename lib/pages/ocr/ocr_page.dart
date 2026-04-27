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
  String _statusText = 'Abrindo camera e preparando a leitura automatica.';
  double? _detectedWeight;

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
      _statusText = 'Solicitando acesso a camera.';
    });

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
        _permissionDenied = true;
        _statusText = 'Permita o uso da camera para ler o peso da balanca.';
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
        _statusText = 'Nenhuma camera disponivel neste dispositivo.';
      });
      return;
    }

    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller.initialize();
    await _cameraController?.dispose();
    _cameraController = controller;

    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializing = false;
      _statusText = 'Aponte a camera para o visor da balanca ate o peso estabilizar.';
    });
    _startScanning();
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
        _statusText = 'Lendo o visor da balanca...';
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
        _statusText = 'Falha ao capturar a leitura. Tente manter a camera firme.';
      });
    } finally {
      _isProcessing = false;
      final path = capture?.path;
      if (path != null) {
        unawaited(() async {
          try {
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
            note: 'Leitura automatica da balanca',
            type: WeightEntryType.ocr,
          );
      AppToast.show(context, 'Peso ${confirmedWeight.toStringAsFixed(1)} kg registrado com sucesso.');
      setState(() {
        _statusText = 'Registro salvo. Voce pode apontar para uma nova leitura.';
      });
    } else {
      setState(() {
        _statusText = 'Leitura cancelada. Continue apontando para a balanca.';
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
          'Leitura automatica da balanca',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          'Abra a camera, alinhe o visor da balanca e deixe o app registrar o peso quando a leitura estiver estavel.',
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
                      'Camera bloqueada',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      _statusText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    SoftButton.primary(
                      label: 'Permitir camera',
                      icon: Icons.videocam_rounded,
                      onPressed: _initializeCamera,
                    ),
                  ],
                )
              else if (controller != null && controller.value.isInitialized)
                UploadZone(
                  controller: controller,
                  detectedWeight: _detectedWeight,
                  statusText: _statusText,
                  isProcessing: _isProcessing,
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

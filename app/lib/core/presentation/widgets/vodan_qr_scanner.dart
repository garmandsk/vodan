import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class VodanQrScannerScreen extends StatefulWidget {
  const VodanQrScannerScreen({super.key});

  @override
  State<VodanQrScannerScreen> createState() => _VodanQrScannerScreenState();
}

class _VodanQrScannerScreenState extends State<VodanQrScannerScreen> with WidgetsBindingObserver {
  
  // 1. Controller diatur dengan autoStart: false (Karena kita yang akan menyalakannya manual)
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
    autoZoom: true,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  
  StreamSubscription<Object?>? _subscription;
  bool _isFlashOn = false;
  bool _isDisposingCamera = false;

  @override
  void initState() {
    super.initState();
    // 2. Daftarkan pemantau Lifecycle saat halaman dibuka
    WidgetsBinding.instance.addObserver(this);
    
    // 3. Mulai dengarkan hasil scan kamera
    _subscription = _controller.barcodes.listen(_handleBarcode);
    
    // 4. Nyalakan kamera dan optimalkan lensa setelahnya
    unawaited(_controller.start().then((_) => _optimizeCameraLens()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = _controller.barcodes.listen(_handleBarcode);
        unawaited(_controller.start());
        break;
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_controller.stop());
        break;
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        unawaited(_subscription?.cancel()); 
        _subscription = null;
        
        unawaited(_safeExit(barcode.rawValue!));
        break; 
      }
    }
  }

  Future<void> _optimizeCameraLens() async {
    try {
      final supportedBackLenses = await _controller.getSupportedLenses(facing: CameraFacing.back);
      if (supportedBackLenses.isNotEmpty) {
        final bestLens = await _controller.getBestCloseRangeScanningLens(facing: CameraFacing.back);
        if (bestLens != null && supportedBackLenses.contains(bestLens)) {
          await _controller.switchCamera(SelectCamera(facingDirection: CameraFacing.back, lensType: bestLens));
        }
      } else {
        final supportedFrontLenses = await _controller.getSupportedLenses(facing: CameraFacing.front);
        if (supportedFrontLenses.isNotEmpty) {
          await _controller.switchCamera(const SelectCamera(facingDirection: CameraFacing.front, lensType: CameraLensType.normal));
        }
      }
    } catch (e) {
      debugPrint('Tidak dapat melakukan optimasi lensa: $e');
    }
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? capture = await _controller.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? qrData = capture.barcodes.first.rawValue;
        if (qrData != null && mounted) {
          unawaited(_safeExit(qrData));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada QR Code yang terdeteksi.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _safeExit([String? result]) async {
    _subscription?.cancel();
    _subscription = null;

    if (!_isDisposingCamera) {
      _isDisposingCamera = true;
      
      try {
        await _controller.stop();
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        await _controller.dispose(); 
        debugPrint('Berhasil mematikan kamera');
      } catch (e) {
        debugPrint('Error saat mematikan kamera: $e');
      }
    }
    
    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    
    if (!_isDisposingCamera) {
      _controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scanBoxSize = 250.0;
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: scanBoxSize,
      height: scanBoxSize,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await _safeExit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text('Scan QR Lapak', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _safeExit();
            }, 
          ),
          actions: [
            if (!kIsWeb)
              IconButton(
                tooltip: 'Buka dari Galeri',
                icon: const Icon(
                  Icons.photo_library_outlined, 
                  color: Colors.white,
                ), 
                onPressed: _scanFromGallery
              ),
            if (!kIsWeb)
              IconButton(
                icon: Icon(
                  _isFlashOn 
                  ? Icons.flash_on_rounded 
                  : Icons.flash_off_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  _controller.toggleTorch();
                  setState(() => _isFlashOn = !_isFlashOn);
                },
              ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white,),
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ),
        extendBodyBehindAppBar: true, 
        body: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: _controller,
              scanWindow: scanWindow,
            ),
            
            Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Colors.orange,
                  borderRadius: 12,
                  borderLength: 30,
                  borderWidth: 8,
                  cutOutSize: scanBoxSize,
                ),
              ),
            ),
            
            const Positioned(
              bottom: 100,
              child: Text(
                'Arahkan kamera ke QR Code',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🎨 WIDGET TAMBAHAN: QrScannerOverlayShape
// Ini untuk membuat efek "kaca film gelap" di seluruh layar KECUALI 
// di dalam kotak tengah.
// ============================================================================
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.65), // Warna gelap transparan
    this.borderRadius = 0,
    this.borderLength = 40,
    required this.cutOutSize,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }
    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength = borderLength > cutOutSize / 2 + borderWidthSize ? borderWidthSize / 2 : borderLength;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        boxPaint,
      )
      ..restore();

    // Menggambar sudut-sudut garis pembatas (Bracket)
    final path = Path()
      // Kiri Atas
      ..moveTo(cutOutRect.left, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
      ..arcToPoint(Offset(cutOutRect.left + borderRadius, cutOutRect.top),
          radius: Radius.circular(borderRadius))
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.top)
      // Kanan Atas
      ..moveTo(cutOutRect.right, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.top + borderRadius)
      ..arcToPoint(Offset(cutOutRect.right - borderRadius, cutOutRect.top),
          radius: Radius.circular(borderRadius), clockwise: false)
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.top)
      // Kanan Bawah
      ..moveTo(cutOutRect.right, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
      ..arcToPoint(Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
          radius: Radius.circular(borderRadius))
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.bottom)
      // Kiri Bawah
      ..moveTo(cutOutRect.left, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
      ..arcToPoint(Offset(cutOutRect.left + borderRadius, cutOutRect.bottom),
          radius: Radius.circular(borderRadius), clockwise: false)
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.bottom);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
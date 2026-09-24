import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phum_kasikors/controller/farmer/profile_controller.dart';
import 'package:phum_kasikors/view/farmer/farmer_design.dart';

class FarmerCameraScreen extends StatefulWidget {
  const FarmerCameraScreen({
    super.key,
  });

  @override
  State<FarmerCameraScreen> createState() =>
      _FarmerCameraScreenState();
}

class _FarmerCameraScreenState
    extends State<FarmerCameraScreen> {
  CameraController? _cameraController;

  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ============================================================
  // INITIALIZE CAMERA
  // ============================================================

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception(
          'No camera was found on this device.',
        );
      }

      CameraDescription selectedCamera = cameras.first;

      // Prefer the front camera.
      for (final camera in cameras) {
        if (camera.lensDirection ==
            CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      debugPrint(
        'CAMERA: ${selectedCamera.name}',
      );

      debugPrint(
        'SENSOR ORIENTATION: '
        '${selectedCamera.sensorOrientation}',
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      debugPrint(
        'PREVIEW SIZE: '
        '${controller.value.previewSize}',
      );

      debugPrint(
        'ASPECT RATIO: '
        '${controller.value.aspectRatio}',
      );

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
        _errorMessage = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _errorMessage =
            '${e.code}: '
            '${e.description ?? 'Unable to initialize camera.'}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> _takePhoto() async {
  final controller = _cameraController;

  if (controller == null ||
      !controller.value.isInitialized ||
      _isCapturing) {
    return;
  }

  if (controller.value.isTakingPicture) {
    return;
  }

  setState(() {
    _isCapturing = true;
  });

  try {
    debugPrint('CAMERA: Taking picture...');

    final XFile photo = await controller.takePicture();

    debugPrint('CAMERA: Picture captured.');
    debugPrint('CAMERA: Path = ${photo.path}');

    if (!mounted) return;

    Get.snackbar(
      'Photo Captured',
      'Uploading profile photo...',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );

    final profileController =
        Get.find<FarmerProfileController>();

    debugPrint('PROFILE: Starting image upload...');

    final success =
        await profileController.uploadProfileImage(
      photo.path,
    );

    debugPrint(
      'PROFILE: Upload result = $success',
    );

    if (!mounted) return;

    if (success) {
      Get.snackbar(
        'Success',
        'Profile photo updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (mounted) {
        Get.back(result: true);
      }
    } else {
      Get.snackbar(
        'Upload Failed',
        profileController.errorMessage.value ??
            'The photo was captured but could not be uploaded.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  } on CameraException catch (e) {
    debugPrint(
      'CAMERA ERROR: ${e.code} - ${e.description}',
    );

    if (!mounted) return;

    Get.snackbar(
      'Camera Error',
      '${e.code}: '
      '${e.description ?? 'Unable to take photo.'}',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  } catch (e) {
    debugPrint(
      'PHOTO ERROR: $e',
    );

    if (!mounted) return;

    Get.snackbar(
      'Photo Error',
      e.toString().replaceFirst(
            'Exception: ',
            '',
          ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isCapturing = false;
      });
    }
  }
}

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Take Profile Photo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(controller),
      bottomNavigationBar: _buildCameraControls(),
    );
  }

  // ============================================================
  // CAMERA PREVIEW
  // ============================================================

  Widget _buildBody(
    CameraController? controller,
  ) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 18),
              const Text(
                'Unable to access camera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _errorMessage = null;
                  });

                  _initializeCamera();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera is not ready.',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }

    // Let CameraPreview handle the camera's
    // native orientation and transformation.
    return Center(
      child: CameraPreview(controller),
    );
  }

  // ============================================================
  // CAMERA CONTROLS
  // ============================================================

  Widget _buildCameraControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        28,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Position your face inside the camera view',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _isCapturing
                  ? null
                  : _takePhoto,
              child: Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing
                        ? Colors.grey
                        : FarmerDesign.primary,
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
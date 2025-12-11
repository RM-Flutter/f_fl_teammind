import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import '../../../../constants/app_colors.dart';

enum LivenessChallenge {
  blinkRightEye,
  blinkLeftEye,
  closeBothEyes,
  tiltHeadRight,
  tiltHeadLeft,
  smile,
  turnHeadRight,
  turnHeadLeft,
  // nodUp and nodDown removed per user request
}

class LivenessChallengeReport {
  final LivenessChallenge challenge;
  final DateTime startTime;
  final DateTime? endTime;
  final bool success;
  final String? failureReason;
  final bool wasRetried;

  LivenessChallengeReport({
    required this.challenge,
    required this.startTime,
    this.endTime,
    required this.success,
    this.failureReason,
    this.wasRetried = false,
  });

  Duration get duration => endTime != null
      ? endTime!.difference(startTime)
      : DateTime.now().difference(startTime);

  String get challengeName {
    switch (challenge) {
      case LivenessChallenge.blinkRightEye:
        return 'Blink Right Eye';
      case LivenessChallenge.blinkLeftEye:
        return 'Blink Left Eye';
      case LivenessChallenge.closeBothEyes:
        return 'Close Both Eyes';
      case LivenessChallenge.tiltHeadRight:
        return 'Tilt Head Right';
      case LivenessChallenge.tiltHeadLeft:
        return 'Tilt Head Left';
      case LivenessChallenge.smile:
        return 'Smile';
      case LivenessChallenge.turnHeadRight:
        return 'Turn Head Right';
      case LivenessChallenge.turnHeadLeft:
        return 'Turn Head Left';
      default:
        return 'Unknown Challenge';
    }
  }

  String get challengeNameAr {
    switch (challenge) {
      case LivenessChallenge.blinkRightEye:
        return 'غمزة العين اليمنى';
      case LivenessChallenge.blinkLeftEye:
        return 'غمزة العين اليسرى';
      case LivenessChallenge.closeBothEyes:
        return 'إغلاق العينين';
      case LivenessChallenge.tiltHeadRight:
        return 'ميل الرأس لليمين';
      case LivenessChallenge.tiltHeadLeft:
        return 'ميل الرأس لليسار';
      case LivenessChallenge.smile:
        return 'ابتسامة';
      case LivenessChallenge.turnHeadRight:
        return 'لف الرأس لليمين';
      case LivenessChallenge.turnHeadLeft:
        return 'لف الرأس لليسار';
      default:
        return 'تحدي غير معروف';
    }
  }

  // Stable ID to be included in reports and sent to API/cache
  String get challengeId {
    switch (challenge) {
      case LivenessChallenge.blinkRightEye:
        return 'blinkRightEye';
      case LivenessChallenge.blinkLeftEye:
        return 'blinkLeftEye';
      case LivenessChallenge.closeBothEyes:
        return 'closeBothEyes';
      case LivenessChallenge.tiltHeadRight:
        return 'tiltHeadRight';
      case LivenessChallenge.tiltHeadLeft:
        return 'tiltHeadLeft';
      case LivenessChallenge.smile:
        return 'smile';
      case LivenessChallenge.turnHeadRight:
        return 'turnHeadRight';
      case LivenessChallenge.turnHeadLeft:
        return 'turnHeadLeft';
      default:
        return 'unknown';
    }
  }
}

class LivenessChallengeCameraScreen extends StatefulWidget {
  final LivenessChallenge challenge;
  final Function(LivenessChallengeReport, Uint8List? imageBytes)? onComplete;
  final Function(List<LivenessChallengeReport>)? onAllReports; // Callback to receive all reports

  const LivenessChallengeCameraScreen({
    super.key,
    required this.challenge,
    this.onComplete,
    this.onAllReports,
  });

  @override
  State<LivenessChallengeCameraScreen> createState() =>
      _LivenessChallengeCameraScreenState();
}

class _LivenessChallengeCameraScreenState
    extends State<LivenessChallengeCameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _challengeCompleted = false;
  bool _isDisposed = false; // Track if widget is disposed
  FaceDetector? _faceDetector;
  Timer? _detectionTimer;
  Timer? _timeoutTimer;
  DateTime _challengeStartTime = DateTime.now();
  LivenessChallengeReport? _report;
  String? _statusMessage;
  bool _wasRetried = false;
  int _timeRemaining = 10; // 10 seconds timeout
  late LivenessChallenge _currentChallenge; // Current challenge (can change on timeout)
  final List<LivenessChallengeReport> _allReports = []; // Store all reports including timeouts

  // Challenge detection state
  double? _previousLeftEyeProb;
  double? _previousRightEyeProb;
  double? _previousYaw;
  double? _previousPitch;
  double? _previousRoll;
  double? _previousSmileProb;
  int _detectionFrames = 0;
  
  // Blink detection state - removed, using simpler logic
  static const int _requiredFrames = 2; // Number of consecutive frames to confirm (reduced for easier detection)
  
  // Track consecutive failures to prevent infinite retries
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 5;

  // Animation for on-screen challenge hint
  late AnimationController _iconController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  
  // For blink challenges, we only need 1 frame since blinks are very fast
  int get _requiredFramesForChallenge {
    if (_currentChallenge == LivenessChallenge.blinkRightEye ||
        _currentChallenge == LivenessChallenge.blinkLeftEye) {
      return 1; // Blinks are fast, only need 1 frame
    }
    return _requiredFrames;
  }

  @override
  void initState() {
    super.initState();
    try {
      _currentChallenge = widget.challenge;
      _challengeStartTime = DateTime.now();
      _iconController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      _fadeAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
        CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
      );
      _scaleAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
      );
      _initializeCamera();
      _initializeFaceDetector();
    } catch (e, stackTrace) {
      debugPrint('Error in initState: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showError('Failed to initialize: ${e.toString()}');
      }
    }
  }
  
  LivenessChallenge _getRandomChallenge() {
    final allChallenges = List<LivenessChallenge>.from(LivenessChallenge.values);
    allChallenges.remove(_currentChallenge); // Don't repeat the same challenge
    if (allChallenges.isEmpty) {
      // If only one challenge exists, return it
      return LivenessChallenge.values.first;
    }
    return allChallenges[DateTime.now().millisecondsSinceEpoch % allChallenges.length];
  }

  Future<void> _initializeCamera() async {
    try {
      // Check camera permission first
      final permission = await permission_handler.Permission.camera.status;
      if (!permission.isGranted) {
        final result = await permission_handler.Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            _showError('Camera permission is required');
          }
          return;
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          _showError('No cameras available');
        }
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted && _controller!.value.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        _startDetection();
      } else {
        if (mounted) {
          _showError('Camera initialized but not ready');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing camera: $e');
      debugPrint('Stack trace: $stackTrace');
      // Dispose controller if initialization failed
      try {
        await _controller?.dispose();
        _controller = null;
      } catch (disposeError) {
        debugPrint('Error disposing controller: $disposeError');
      }
      if (mounted) {
        _showError('Failed to initialize camera: ${e.toString()}');
      }
    }
  }

  void _initializeFaceDetector() {
    try {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableClassification: true,
          enableContours: false,
          enableLandmarks: false,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error initializing face detector: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        _showError('Failed to initialize face detector: ${e.toString()}');
      }
    }
  }

  void _startDetection() {
    // Don't start if disposed or not mounted
    if (_isDisposed || !mounted || _controller == null || !_controller!.value.isInitialized || !_isInitialized) {
      _detectionTimer?.cancel();
      return;
    }
    
    // Reset failure counter when starting detection
    _consecutiveFailures = 0;
    _detectionTimer?.cancel();
    // Process frames at same speed for all challenges to ensure consistent detection
    final interval = const Duration(milliseconds: 100); // Fast processing for all challenges
    _detectionTimer = Timer.periodic(interval, (timer) {
      // Stop timer if widget is disposed or unmounted
      if (_isDisposed || !mounted || _challengeCompleted) {
        timer.cancel();
        return;
      }
      if (_isProcessing) return;
      _processFrame();
    });
    
    // Start timeout timer (10 seconds) - reset if already running
    _timeRemaining = 10;
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _challengeCompleted) {
        timer.cancel();
        return;
      }
      
      _timeRemaining--;
      if (mounted) {
        setState(() {});
      }
      
      if (_timeRemaining <= 0) {
        timer.cancel();
        _onTimeout();
      }
    });
  }
  
  void _onTimeout() {
    if (_challengeCompleted || !mounted) return;
    
    // Save the failed report
    final failedReport = LivenessChallengeReport(
      challenge: _currentChallenge,
      startTime: _challengeStartTime,
      endTime: DateTime.now(),
      success: false,
      failureReason: 'Time limit exceeded (10 seconds)',
      wasRetried: _wasRetried,
    );
    _allReports.add(failedReport);
    
    // Reset state for new challenge
    _detectionTimer?.cancel();
    _timeoutTimer?.cancel();
    _detectionFrames = 0;
    _previousLeftEyeProb = null;
    _previousRightEyeProb = null;
    _previousYaw = null;
    _previousPitch = null;
    _previousRoll = null;
    _previousSmileProb = null;
    _isProcessing = false;
    _challengeCompleted = false;
    _consecutiveFailures = 0; // Reset failure counter
    
    // Get a new random challenge
    _currentChallenge = _getRandomChallenge();
    _challengeStartTime = DateTime.now();
    _timeRemaining = 10;
    
    if (mounted) {
      setState(() {
        _statusMessage = null;
      });
      // Restart detection with new challenge
      _startDetection();
    }
  }

  Future<void> _processFrame() async {
    // Stop processing if widget is disposed, unmounted, or challenge completed
    if (_isDisposed || !mounted || _challengeCompleted) {
      _detectionTimer?.cancel();
      _isProcessing = false;
      return;
    }
    
    if (_controller == null || !_controller!.value.isInitialized || !_isInitialized) {
      _isProcessing = false;
      return;
    }
    if (_isProcessing || _challengeCompleted) {
      return;
    }
    
    // Prevent multiple simultaneous captures to avoid buffer overflow
    _isProcessing = true;

    try {
      // Double check controller is still initialized and not disposed before taking picture
      if (_controller == null || 
          !_controller!.value.isInitialized || 
          !_isInitialized ||
          _challengeCompleted ||
          !mounted) {
        _isProcessing = false;
        return;
      }
      
      XFile? image;
      try {
        // Check again right before taking picture - multiple safety checks
        if (_isDisposed || 
            !mounted || 
            _controller == null || 
            !_controller!.value.isInitialized || 
            _challengeCompleted) {
          _isProcessing = false;
          return;
        }
        
        // Check if camera is ready to take pictures
        if (_controller!.value.isTakingPicture) {
          _isProcessing = false;
          return;
        }
        
        // Add a small delay if we had recent failures to give camera time to recover
        if (_consecutiveFailures > 0) {
          await Future.delayed(Duration(milliseconds: 100 * _consecutiveFailures));
          
          // Check again after delay
          if (_isDisposed || !mounted || _challengeCompleted || 
              _controller == null || !_controller!.value.isInitialized) {
            _isProcessing = false;
            return;
          }
        }
        
        image = await _controller!.takePicture();
        // Reset failure counter on success
        _consecutiveFailures = 0;
      } catch (takePictureError) {
        _consecutiveFailures++;
        
        // Only log error once to avoid spam in console
        if (_consecutiveFailures == 1) {
          debugPrint('Error taking picture: $takePictureError');
        } else if (_consecutiveFailures == _maxConsecutiveFailures) {
          // Log when we're about to stop
          debugPrint('Camera error repeated $_consecutiveFailures times. Stopping detection.');
        }
        
        _isProcessing = false;
        
        // Stop processing if too many consecutive failures
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          _detectionTimer?.cancel();
          if (mounted && !_challengeCompleted) {
            _showError('Camera error: Too many failures. Please try again.');
          }
          return;
        }
        
        // Don't return here if widget is disposed, just stop processing
        if (!mounted || _challengeCompleted) {
          return;
        }
        
        // Add a small delay before retrying to avoid overwhelming the camera
        await Future.delayed(const Duration(milliseconds: 200));
        return;
      }
      
      if (image == null) {
        _isProcessing = false;
        return;
      }
      if (!mounted || _challengeCompleted) {
        await _deleteFile(File(image.path));
        _isProcessing = false;
        _detectionTimer?.cancel();
        return;
      }

      if (_faceDetector == null) {
        await _deleteFile(File(image.path));
        _isProcessing = false;
        return;
      }
      
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector!.processImage(inputImage);

      if (!mounted || _challengeCompleted) {
        await _deleteFile(File(image.path));
        _isProcessing = false;
        _detectionTimer?.cancel();
        return;
      }

      if (faces.isEmpty) {
        if (mounted && !_challengeCompleted) {
          setState(() {
            _statusMessage = _getLocalizedMessage('No face detected');
          });
        }
        await _deleteFile(File(image.path));
        _isProcessing = false;
        return;
      }

      // Check again after face detection
      if (!mounted || _challengeCompleted) {
        await _deleteFile(File(image.path));
        _isProcessing = false;
        _detectionTimer?.cancel();
        return;
      }

      // Clear status message when face is detected
      if (mounted && _statusMessage != null && !_challengeCompleted) {
        setState(() {
          _statusMessage = null;
        });
      }

      final face = faces.first;
      final leftEyeProb = face.leftEyeOpenProbability;
      final rightEyeProb = face.rightEyeOpenProbability;
      final yaw = face.headEulerAngleY ?? 0;
      final pitch = face.headEulerAngleX ?? 0;
      final roll = face.headEulerAngleZ ?? 0;
      final smileProb = face.smilingProbability ?? -1;

      // Debug: log values for different challenges (with null safety)
      try {
        if (_currentChallenge == LivenessChallenge.blinkRightEye || 
            _currentChallenge == LivenessChallenge.blinkLeftEye) {
          debugPrint('Eye probs - Left: ${leftEyeProb?.toString() ?? "null"}, Right: ${rightEyeProb?.toString() ?? "null"}, Previous Left: ${_previousLeftEyeProb?.toString() ?? "null"}, Previous Right: ${_previousRightEyeProb?.toString() ?? "null"}');
        } else if (_currentChallenge == LivenessChallenge.turnHeadRight || 
                   _currentChallenge == LivenessChallenge.turnHeadLeft) {
          debugPrint('Head turn - yaw=$yaw, challenge=${_currentChallenge.toString()}');
        } else if (_currentChallenge == LivenessChallenge.tiltHeadRight || 
                   _currentChallenge == LivenessChallenge.tiltHeadLeft) {
          debugPrint('Head tilt - roll=$roll, challenge=${_currentChallenge.toString()}');
        }
      } catch (e) {
        // Ignore debug print errors
      }

      final bool challengeMet = _checkChallenge(
        leftEyeProb ?? 0.5,
        rightEyeProb ?? 0.5,
        yaw,
        pitch,
        roll,
        smileProb,
      );
      
      if (!mounted || _challengeCompleted) {
        await _deleteFile(File(image.path));
        _isProcessing = false;
        _detectionTimer?.cancel();
        return;
      }

      if (challengeMet) {
        _detectionFrames++;
        if (mounted && !_challengeCompleted) {
          setState(() {
            _statusMessage = _getLocalizedMessage('Detecting...');
          });
        }
        if (_detectionFrames >= _requiredFramesForChallenge && !_challengeCompleted) {
          _isProcessing = false;
          // Don't delete the image, we need it for _completeChallenge
          await _completeChallenge(image.path);
          return;
        }
      } else {
        if (_detectionFrames > 0) {
          _detectionFrames = 0;
          if (mounted && !_challengeCompleted) {
            setState(() {
              _statusMessage = null;
            });
          }
        }
      }

      _previousLeftEyeProb = leftEyeProb;
      _previousRightEyeProb = rightEyeProb;
      _previousYaw = yaw;
      _previousPitch = pitch;
      _previousRoll = roll;
      _previousSmileProb = smileProb;

      await _deleteFile(File(image.path));
      _isProcessing = false;
    } catch (e, stackTrace) {
      debugPrint('Error processing frame: $e');
      debugPrint('Stack trace: $stackTrace');
      _isProcessing = false;
      // Don't crash, just continue processing
    }
  }

  bool _checkChallenge(
    double leftEyeProb,
    double rightEyeProb,
    double yaw,
    double pitch,
    double roll,
    double smileProb,
  ) {
    // Note: Front camera is mirrored, so we need to swap left/right
    switch (_currentChallenge) {
      case LivenessChallenge.blinkRightEye:
        // Front camera is mirrored: right eye in UI = left eye in detection
        // Super lenient: any drop of 0.1 or more counts as a blink
        if (_previousLeftEyeProb == null) return false;
        
        // Very lenient: any drop of 0.1 or more counts as a blink
        final drop = _previousLeftEyeProb! - leftEyeProb;
        final significantDrop = drop > 0.1;
        
        // Also check if eye is currently relatively closed (more lenient)
        final eyeCurrentlyLow = leftEyeProb < 0.85;
        
        try {
          debugPrint('BlinkRightEye check: prev=${_previousLeftEyeProb?.toString() ?? "null"}, curr=${leftEyeProb.toString()}, drop=$drop, significant=$significantDrop, low=$eyeCurrentlyLow');
        } catch (e) {
          // Ignore debug print errors
        }
        
        if (significantDrop && eyeCurrentlyLow) {
          try {
            debugPrint('✅ Blink detected: leftEyeProb dropped from ${_previousLeftEyeProb?.toString() ?? "null"} to ${leftEyeProb.toString()}');
          } catch (e) {
            // Ignore debug print errors
          }
          return true;
        }
        
        return false;

      case LivenessChallenge.blinkLeftEye:
        // Front camera is mirrored: left eye in UI = right eye in detection
        // Super lenient: any drop of 0.1 or more counts as a blink
        if (_previousRightEyeProb == null) return false;
        
        // Very lenient: any drop of 0.1 or more counts as a blink
        final drop = _previousRightEyeProb! - rightEyeProb;
        final significantDrop = drop > 0.1;
        
        // Also check if eye is currently relatively closed (more lenient)
        final eyeCurrentlyLow = rightEyeProb < 0.85;
        
        try {
          debugPrint('BlinkLeftEye check: prev=${_previousRightEyeProb?.toString() ?? "null"}, curr=${rightEyeProb.toString()}, drop=$drop, significant=$significantDrop, low=$eyeCurrentlyLow');
        } catch (e) {
          // Ignore debug print errors
        }
        
        if (significantDrop && eyeCurrentlyLow) {
          try {
            debugPrint('✅ Blink detected: rightEyeProb dropped from ${_previousRightEyeProb?.toString() ?? "null"} to ${rightEyeProb.toString()}');
          } catch (e) {
            // Ignore debug print errors
          }
          return true;
        }
        
        return false;

      case LivenessChallenge.closeBothEyes:
        // Super lenient: both eyes closed (< 0.6)
        return leftEyeProb < 0.6 && rightEyeProb < 0.6;

      case LivenessChallenge.tiltHeadRight:
        // User tilts right = camera sees right (roll > 5)
        // Super lenient: accept roll between 5 and 60
        final isValid = roll > 5 && roll < 60;
        if (isValid) {
          debugPrint('✅ TiltHeadRight detected: roll=$roll');
        } else {
          debugPrint('TiltHeadRight check: roll=$roll (need: 5 to 60)');
        }
        return isValid;

      case LivenessChallenge.tiltHeadLeft:
        // User tilts left = camera sees left (roll < -5)
        // Super lenient: accept roll between -5 and -60
        final isValid = roll < -5 && roll > -60;
        if (isValid) {
          debugPrint('✅ TiltHeadLeft detected: roll=$roll');
        } else {
          debugPrint('TiltHeadLeft check: roll=$roll (need: -5 to -60)');
        }
        return isValid;

      case LivenessChallenge.smile:
        // Super lenient: smile probability > 0.3
        return smileProb > 0.3;

      case LivenessChallenge.turnHeadRight:
        // Front camera is mirrored: turn right in UI = turn left in detection (yaw < 0)
        // Super lenient: accept any negative yaw (turned left from camera's perspective)
        final isValid = yaw < -3; // Very lenient: just needs to be turned left slightly
        if (isValid) {
          try {
            debugPrint('✅ TurnHeadRight detected: yaw=$yaw');
          } catch (e) {}
        } else {
          try {
            debugPrint('TurnHeadRight check: yaw=$yaw (need: < -3)');
          } catch (e) {}
        }
        return isValid;

      case LivenessChallenge.turnHeadLeft:
        // Front camera is mirrored: turn left in UI = turn right in detection (yaw > 0)
        // Super lenient: accept any positive yaw (turned right from camera's perspective)
        final isValid = yaw > 3; // Very lenient: just needs to be turned right slightly
        if (isValid) {
          try {
            debugPrint('✅ TurnHeadLeft detected: yaw=$yaw');
          } catch (e) {}
        } else {
          try {
            debugPrint('TurnHeadLeft check: yaw=$yaw (need: > 3)');
          } catch (e) {}
        }
        return isValid;
      default:
        return false;
    }
  }

  Future<void> _completeChallenge(String imagePath) async {
    if (_isProcessing || _challengeCompleted) return;
    
    // Stop detection immediately
    _detectionTimer?.cancel();
    _timeoutTimer?.cancel();
    _challengeCompleted = true;

    if (!mounted) return;

    try {
      setState(() {
        _isProcessing = true;
        _statusMessage = _getLocalizedMessage('Challenge completed!');
      });
    } catch (e) {
      debugPrint('Error setting state in _completeChallenge: $e');
    }

    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        _report = LivenessChallengeReport(
          challenge: _currentChallenge,
          startTime: _challengeStartTime,
          endTime: DateTime.now(),
          success: false,
          failureReason: 'Image file not found',
          wasRetried: _wasRetried,
        );
        // Add to all reports before returning
        _allReports.add(_report!);
        // Send all reports via callback if available
        if (widget.onAllReports != null) {
          widget.onAllReports!(_allReports);
        }
        if (mounted) {
          Navigator.of(context).pop(_report);
        }
        return;
      }
      
      final imageBytes = await imageFile.readAsBytes();
      
      if (imageBytes.isEmpty) {
        debugPrint('Image file is empty: $imagePath');
        _report = LivenessChallengeReport(
          challenge: _currentChallenge,
          startTime: _challengeStartTime,
          endTime: DateTime.now(),
          success: false,
          failureReason: 'Image file is empty',
          wasRetried: _wasRetried,
        );
        // Add to all reports before returning
        _allReports.add(_report!);
        // Send all reports via callback if available
        if (widget.onAllReports != null) {
          widget.onAllReports!(_allReports);
        }
        if (mounted) {
          Navigator.of(context).pop(_report);
        }
        return;
      }

      _report = LivenessChallengeReport(
        challenge: _currentChallenge,
        startTime: _challengeStartTime,
        endTime: DateTime.now(),
        success: true,
        wasRetried: _wasRetried,
      );
      
      // Add successful report to all reports
      final allReports = List<LivenessChallengeReport>.from(_allReports);
      allReports.add(_report!);

      if (widget.onComplete != null) {
        widget.onComplete!(_report!, imageBytes);
      }
      
      // Send all reports via callback if available
      if (widget.onAllReports != null) {
        widget.onAllReports!(allReports);
      }

      if (mounted) {
        Navigator.of(context).pop(_report);
      }
    } catch (e) {
      debugPrint('Error completing challenge: $e');
      _report = LivenessChallengeReport(
        challenge: _currentChallenge,
        startTime: _challengeStartTime,
        endTime: DateTime.now(),
        success: false,
        failureReason: 'Error processing image: $e',
        wasRetried: _wasRetried,
      );
      // Add to all reports before returning
      _allReports.add(_report!);
      // Send all reports via callback if available
      if (widget.onAllReports != null) {
        widget.onAllReports!(_allReports);
      }
      if (mounted) {
        Navigator.of(context).pop(_report);
      }
    }
  }

  String _getLocalizedMessage(String en) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    switch (en) {
      case 'No face detected':
        return isArabic ? 'لم يتم اكتشاف وجه' : en;
      case 'Challenge completed!':
        return isArabic ? 'تم إكمال التحدي!' : en;
      default:
        return en;
    }
  }

  String _getChallengeInstruction() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    switch (_currentChallenge) {
      case LivenessChallenge.blinkRightEye:
        return isArabic ? 'قم بغمزة العين اليمنى' : 'Blink your right eye';
      case LivenessChallenge.blinkLeftEye:
        return isArabic ? 'قم بغمزة العين اليسرى' : 'Blink your left eye';
      case LivenessChallenge.closeBothEyes:
        return isArabic ? 'أغلق عينيك' : 'Close both eyes';
      case LivenessChallenge.tiltHeadRight:
        return isArabic ? 'أمِل رأسك لليمين' : 'Tilt your head to the right';
      case LivenessChallenge.tiltHeadLeft:
        return isArabic ? 'أمِل رأسك لليسار' : 'Tilt your head to the left';
      case LivenessChallenge.smile:
        return isArabic ? 'ابتسم' : 'Smile';
      case LivenessChallenge.turnHeadRight:
        return isArabic ? 'لف رأسك لليمين' : 'Turn your head to the right';
      case LivenessChallenge.turnHeadLeft:
        return isArabic ? 'لف رأسك لليسار' : 'Turn your head to the left';
      default:
        return isArabic ? 'تحدي غير معروف' : 'Unknown challenge';
    }
  }

  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      final errorReport = LivenessChallengeReport(
        challenge: _currentChallenge,
        startTime: _challengeStartTime,
        endTime: DateTime.now(),
        success: false,
        failureReason: message,
        wasRetried: _wasRetried,
      );
      // Add to all reports before returning
      _allReports.add(errorReport);
      // Send all reports via callback if available
      if (widget.onAllReports != null) {
        widget.onAllReports!(_allReports);
      }
      Navigator.of(context).pop(errorReport);
    }
  }

  @override
  void dispose() {
    // Mark as disposed first to stop all processing
    _isDisposed = true;
    _challengeCompleted = true;
    _isProcessing = false;
    
    // Cancel all timers immediately
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    
    // Stop animation controller
    try {
      _iconController.stop();
      _iconController.dispose();
    } catch (_) {}
    
    // Dispose camera controller
    try {
      _controller?.dispose();
    } catch (_) {}
    _controller = null;
    
    // Close face detector
    try {
      _faceDetector?.close();
    } catch (_) {}
    _faceDetector = null;
    
    super.dispose();
  }

  Widget _buildChallengeAnimation() {
    const double fontSize = 56;

    Widget rotating(String emoji, {required double from, required double to}) {
      return AnimatedBuilder(
        animation: _iconController,
        builder: (_, __) {
          final angle = from + (_iconController.value * (to - from));
          return Transform.rotate(
            angle: angle,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: fontSize, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }

    switch (_currentChallenge) {
      case LivenessChallenge.blinkRightEye:
      case LivenessChallenge.blinkLeftEye:
      case LivenessChallenge.closeBothEyes:
        // Blink hint: fade in/out eye icon
        return FadeTransition(
          opacity: _fadeAnim,
          child: const Text(
            '😉',
            style: TextStyle(fontSize: fontSize, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      case LivenessChallenge.tiltHeadRight:
        // Tilt (roll) hint: rotate slightly clockwise
        return rotating('🙂', from: 0.1, to: 0.35);
      case LivenessChallenge.tiltHeadLeft:
        // Tilt (roll) hint: rotate slightly counter-clockwise
        return rotating('🙂', from: -0.35, to: -0.1);
      case LivenessChallenge.turnHeadRight:
        // Turn (yaw) right hint: oscillate small rotation to the right
        return rotating('🙂', from: -0.25, to: -0.05);
      case LivenessChallenge.turnHeadLeft:
        // Turn (yaw) left hint: oscillate small rotation to the left
        return rotating('🙂', from: 0.05, to: 0.25);
      case LivenessChallenge.smile:
        // Smile hint: pulse scale on a face icon
        return ScaleTransition(
          scale: _scaleAnim,
          child: const Text(
            '😁',
            style: TextStyle(fontSize: fontSize, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return PopScope(
      canPop: _challengeCompleted,
      onPopInvoked: (didPop) {
        if (!didPop && !_challengeCompleted) {
          _report = LivenessChallengeReport(
            challenge: _currentChallenge,
            startTime: _challengeStartTime,
            endTime: DateTime.now(),
            success: false,
            failureReason: 'User cancelled',
            wasRetried: _wasRetried,
          );
          // Add to all reports before returning
          _allReports.add(_report!);
          // Send all reports via callback if available
          if (widget.onAllReports != null) {
            widget.onAllReports!(_allReports);
          }
          Navigator.of(context).pop(_report);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              if (_challengeCompleted) {
                Navigator.of(context).pop(_report);
              } else {
                _report = LivenessChallengeReport(
                  challenge: _currentChallenge,
                  startTime: _challengeStartTime,
                  endTime: DateTime.now(),
                  success: false,
                  failureReason: 'User cancelled',
                  wasRetried: _wasRetried,
                );
                // Add to all reports before returning
                _allReports.add(_report!);
                // Send all reports via callback if available
                if (widget.onAllReports != null) {
                  widget.onAllReports!(_allReports);
                }
                Navigator.of(context).pop(_report);
              }
            },
          ),
          title: Text(
            isArabic ? 'تحقق من الحياة' : 'Liveness Verification',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: _isInitialized && _controller != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: CameraPreview(_controller!),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _challengeCompleted
                              ? Colors.green
                              : Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.all(40),
                    ),
                  ),
                  // Time remaining indicator
                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _timeRemaining <= 3
                            ? Colors.red.withOpacity(0.9)
                            : Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_timeRemaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getChallengeInstruction(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          // Animated hint icon for current challenge
                          _buildChallengeAnimation(),
                          if (_statusMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _statusMessage!,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}


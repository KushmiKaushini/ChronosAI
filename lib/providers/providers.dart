// Author: K K K Ekanayake
// ChronosAI — Riverpod providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';
import '../services/secure_storage_service.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

final audioServiceProvider = ChangeNotifierProvider((ref) => AudioService());

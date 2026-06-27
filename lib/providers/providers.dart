// Author: K K K Ekanayake
// ChronosAI — Riverpod providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

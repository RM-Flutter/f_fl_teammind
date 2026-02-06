import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// Local data source for offline feature
/// Handles all local storage operations using SharedPreferences and CacheHelper
abstract class OfflineLocalDataSource {}

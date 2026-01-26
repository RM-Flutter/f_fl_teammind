import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class TelegramErrorService {
  static const String _botToken = '8447259251:AAG4xbqjOeGPjHe59OLeH8Z1t1UN9kSZSio';
  static const String _chatId = '@rmdevschannel';
  static const String _baseUrl = 'https://api.telegram.org/bot$_botToken';

  static String? _currentScreenName;
  static BuildContext? _currentContext;

  /// Set current screen name (call this when navigating to a new screen)
  static void setCurrentScreen(String screenName, {BuildContext? context}) {
    _currentScreenName = screenName;
    _currentContext = context;
    print('📍 Screen tracked: $screenName');
  }

  /// Get current screen name from GoRouter
  static String? getCurrentScreenName(BuildContext? context) {
    if (context != null) {
      try {
        final router = GoRouter.of(context);
        final route = router.routerDelegate.currentConfiguration.uri.path;
        if (route.isNotEmpty) {
          // Extract screen name from route
          final parts = route.split('/');
          if (parts.length >= 3) {
            // Format: /lang/screen-name
            return parts[2];
          }
          return route;
        }
      } catch (e) {
        print('Error getting screen name from router: $e');
      }
    }
    return _currentScreenName ?? 'unknown';
  }

  /// Send error message to Telegram
  static Future<void> _sendMessage(String message) async {
    try {
      final url = Uri.parse('$_baseUrl/sendMessage');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ Error sent to Telegram successfully');
      } else {
        print('⚠️ Failed to send error to Telegram: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error sending message to Telegram: $e');
    }
  }

  /// Format exception message for Telegram
  static String _formatErrorMessage({
    required dynamic exception,
    dynamic stackTrace,
    String? screenName,
    Map<String, dynamic>? extra,
    String? hint,
  }) {
    final screen = screenName ?? _currentScreenName ?? getCurrentScreenName(_currentContext) ?? 'unknown';
    final timestamp = DateTime.now().toIso8601String();
    
    final buffer = StringBuffer();
    buffer.writeln('🚨 <b>Error Report</b>');
    buffer.writeln('');
    buffer.writeln('📱 <b>Screen:</b> $screen');
    buffer.writeln('⏰ <b>Time:</b> $timestamp');
    buffer.writeln('');
    buffer.writeln('❌ <b>Exception:</b>');
    buffer.writeln('<code>${exception.toString().replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</code>');
    
    if (hint != null) {
      buffer.writeln('');
      buffer.writeln('💡 <b>Hint:</b> $hint');
    }
    
    if (stackTrace != null) {
      buffer.writeln('');
      buffer.writeln('📚 <b>Stack Trace:</b>');
      final stackStr = stackTrace.toString();
      // Limit stack trace to first 2000 characters to avoid message too long
      final limitedStack = stackStr.length > 2000 
          ? '${stackStr.substring(0, 2000)}...\n[Truncated]' 
          : stackStr;
      buffer.writeln('<pre>${limitedStack.replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</pre>');
    }
    
    if (extra != null && extra.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📋 <b>Extra Info:</b>');
      extra.forEach((key, value) {
        buffer.writeln('• <b>$key:</b> $value');
      });
    }
    
    return buffer.toString();
  }

  /// Capture exception and send to Telegram
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? screenName,
    Map<String, dynamic>? extra,
    String? hint,
  }) async {
    final screen = screenName ?? _currentScreenName ?? getCurrentScreenName(_currentContext) ?? 'unknown';
    
    print('🚨 Telegram Error [Screen: $screen]: ${exception.toString()}');
    if (stackTrace != null) {
      print('   StackTrace: ${stackTrace.toString()}');
    }
    if (extra != null) {
      print('   Extra: $extra');
    }
    
    try {
      final message = _formatErrorMessage(
        exception: exception,
        stackTrace: stackTrace,
        screenName: screen,
        extra: extra,
        hint: hint,
      );
      
      await _sendMessage(message);
    } catch (e) {
      print('⚠️ Error sending exception to Telegram: $e');
    }
  }

  /// Capture message and send to Telegram
  static Future<void> captureMessage(
    String message, {
    String level = 'INFO',
    String? screenName,
    Map<String, dynamic>? extra,
  }) async {
    final screen = screenName ?? _currentScreenName ?? getCurrentScreenName(_currentContext) ?? 'unknown';
    
    print('📝 Telegram Message [Screen: $screen] [$level]: $message');
    if (extra != null) {
      print('   Extra: $extra');
    }
    
    try {
      final timestamp = DateTime.now().toIso8601String();
      final formattedMessage = StringBuffer();
      formattedMessage.writeln('📝 <b>Message Report</b>');
      formattedMessage.writeln('');
      formattedMessage.writeln('📱 <b>Screen:</b> $screen');
      formattedMessage.writeln('⏰ <b>Time:</b> $timestamp');
      formattedMessage.writeln('📊 <b>Level:</b> $level');
      formattedMessage.writeln('');
      formattedMessage.writeln('💬 <b>Message:</b>');
      formattedMessage.writeln(message.replaceAll('<', '&lt;').replaceAll('>', '&gt;'));
      
      if (extra != null && extra.isNotEmpty) {
        formattedMessage.writeln('');
        formattedMessage.writeln('📋 <b>Extra Info:</b>');
        extra.forEach((key, value) {
          formattedMessage.writeln('• <b>$key:</b> $value');
        });
      }
      
      await _sendMessage(formattedMessage.toString());
    } catch (e) {
      print('⚠️ Error sending message to Telegram: $e');
    }
  }

  /// Helper method to wrap a function with error tracking
  static Future<T> captureErrors<T>({
    required Future<T> Function() action,
    String? screenName,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await action();
    } catch (e, stackTrace) {
      await captureException(
        e,
        stackTrace: stackTrace,
        screenName: screenName,
        extra: extra,
      );
      rethrow;
    }
  }
}


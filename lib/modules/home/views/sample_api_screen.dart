import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../constants/app_sizes.dart';

/// Screen that fetches data from a free public API and displays it.
/// Uses catfact.ninja (reliable, minimal JSON) — fallback if needed: httpbin.org/get
class SampleApiScreen extends StatefulWidget {
  const SampleApiScreen({super.key});

  @override
  State<SampleApiScreen> createState() => _SampleApiScreenState();
}

class _SampleApiScreenState extends State<SampleApiScreen> {
  static const String _apiUrl = 'https://catfact.ninja/fact';

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _data = decoded;
          _loading = false;
        });
      } else {
        final body = response.body.isNotEmpty ? '\n${response.body}' : '';
        setState(() {
          _error = 'HTTP ${response.statusCode}: Failed to load$body';
          _loading = false;
        });
      }
    } catch (e, _) {
      setState(() {
        final type = e.runtimeType.toString();
        final msg = e.toString();
        _error = 'نوع الخطأ: $type\n\nالرسالة: ${msg.isNotEmpty ? msg : "Unknown error"}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Data', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_loading && _data != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white,),
              onPressed: _fetchData,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSizes.s16),
            Text('Loading from API...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.s24),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: AppSizes.s12),
            const Text(
              'Error loading data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.s12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.s8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: SelectableText(
                    _error!,
                    style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            FilledButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_data == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._data!.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.s12),
                child: _dataTile(
                  e.key.toString(),
                  _valueToString(e.value),
                ),
              )),
          const SizedBox(height: AppSizes.s24),
          const Text(
            'Raw JSON:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.s8),
          Container(
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppSizes.s8),
            ),
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(_data),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _valueToString(dynamic value) {
    if (value == null) return '-';
    if (value is Map || value is List) return const JsonEncoder.withIndent('  ').convert(value);
    return value.toString();
  }

  Widget _dataTile(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSizes.s4),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

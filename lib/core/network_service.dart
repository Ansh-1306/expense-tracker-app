import 'dart:async';
import 'dart:io' as io;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final NetworkService instance = NetworkService._internal();
  factory NetworkService() => instance;
  NetworkService._internal();

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier<bool>(true);

  Future<bool> checkNow() => _checkInternet();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  Timer? _debounce;
  bool _initialized = false;
  int _seq = 0;
  io.HttpClient? _httpClient;

  static const _debounceDuration = Duration(milliseconds: 350);
  static const _overallTimeout = Duration(seconds: 4);
  static const _httpTimeout = Duration(seconds: 3);
  static const _dnsTimeout = Duration(seconds: 2);

  static final List<Uri> _probeUrls = <Uri>[
    Uri.parse('https://www.google.com/generate_204'),
    Uri.parse('https://captive.apple.com/'),
  ];

  Future<void> initialize({List<Uri>? extraHealthUrls}) async {
    if (_initialized) return;
    _initialized = true;

    isConnectedNotifier.value = await _checkInternet();

    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(_debounceDuration, () async {
        final ok = await _checkInternet(additionalUrls: extraHealthUrls);
        if (ok != isConnectedNotifier.value) {
          isConnectedNotifier.value = ok;
        }
      });
    });
  }

  void dispose() {
    _debounce?.cancel();
    _connectivitySub?.cancel();
    _httpClient?.close(force: true);
    isConnectedNotifier.dispose();
    _initialized = false;
  }

  Future<bool> _checkInternet({List<Uri>? additionalUrls}) async {
    final int mySeq = ++_seq;

    final List<Future<bool>> probes = [];

    final urls = <Uri>[
      ..._probeUrls,
      if (additionalUrls != null) ...additionalUrls,
    ];

    for (final uri in urls) {
      probes.add(_probeHttp(uri));
    }

    probes.add(_probeDns('one.one.one.one'));

    final bool result = await _firstTrue(
      probes,
      overallTimeout: _overallTimeout,
    );

    if (mySeq != _seq) return isConnectedNotifier.value;
    return result;
  }

  Future<bool> _probeHttp(Uri url) async {
    if (kIsWeb) return false;

    io.HttpClient? client = _httpClient ?? io.HttpClient()
      ..connectionTimeout = _httpTimeout;
    io.HttpClientRequest req;

    try {
      final useGet = url.path.contains('generate_204');
      req = useGet
          ? await client.getUrl(url).timeout(_httpTimeout)
          : await client.openUrl('HEAD', url).timeout(_httpTimeout);

      final res = await req.close().timeout(_httpTimeout);
      return res.statusCode == 204 ||
          (res.statusCode >= 200 && res.statusCode < 300);
    } catch (_) {
      return false;
    } finally {
      if (!identical(client, _httpClient)) {
        client.close(force: true);
      }
    }
  }

  Future<bool> _probeDns(String host) async {
    if (kIsWeb) return false;
    try {
      final address = await io.InternetAddress.lookup(
        host,
      ).timeout(_dnsTimeout);
      return address.isNotEmpty && address.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _firstTrue(
    List<Future<bool>> futures, {
    required Duration overallTimeout,
  }) {
    final completer = Completer<bool>();
    var remaining = futures.length;

    final timer = Timer(overallTimeout, () {
      if (!completer.isCompleted) completer.complete(false);
    });

    for (final f in futures) {
      f
          .then((ok) {
            if (ok && !completer.isCompleted) {
              completer.complete(true);
            } else if (--remaining == 0 && !completer.isCompleted) {
              completer.complete(false);
            }
          })
          .catchError((_) {
            if (--remaining == 0 && !completer.isCompleted) {
              completer.complete(false);
            }
          });
    }

    return completer.future.whenComplete(timer.cancel);
  }
}

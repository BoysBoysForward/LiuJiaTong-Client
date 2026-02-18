import 'dart:async';
import 'dart:io';

import 'package:liujiatong/data/logger.dart';
import 'package:liujiatong/data/network/protocol.dart';

/// 是否开启 socket_client_io 的调试日志输出
const bool _kEnableSocketClientLogging = false;

void _socketLogDebug(String action, String detail) {
  if (!_kEnableSocketClientLogging) return;
  AppLogger.instance.debug(
    'network/socket_client_io',
    action,
    detail,
  );
}

/// 4 字节长度头（小端序 int32）+ JSON body 的 TCP 收发（仅 dart:io 平台）
class ProtocolSocket {
  ProtocolSocket(this._socket) {
    _socketLogDebug(
      'construct',
      'local=${_socket.address.address}:${_socket.port} remote=${_socket.remoteAddress.address}:${_socket.remotePort}',
    );
    _buffer = [];
    _socket.listen(
      (chunk) {
        _socketLogDebug(
          'onData',
          'len=${chunk.length} buffered=${_buffer.length + chunk.length}',
        );
        _buffer.addAll(chunk);
        _maybeCompleteRecv();
      },
      onError: (e, [st]) {
        AppLogger.instance.error(
          'network/socket_client_io.onError - $e',
        );
        _recvCompleter?.completeError(e, st);
      },
      onDone: () {
        if (!(_recvCompleter?.isCompleted ?? true)) {
          _recvCompleter?.completeError(
            SocketException('Connection closed'),
          );
        }
        _socketLogDebug(
          'onDone',
          'remote closed local=${_socket.address.address}:${_socket.port}',
        );
      },
      cancelOnError: false,
    );
  }

  final Socket _socket;
  late List<int> _buffer;
  Completer<List<int>>? _recvCompleter;
  int? _recvTarget;

  void _maybeCompleteRecv() {
    if (_recvTarget != null &&
        _recvCompleter != null &&
        !_recvCompleter!.isCompleted &&
        _buffer.length >= _recvTarget!) {
      final n = _recvTarget!;
      final result = List<int>.from(_buffer.take(n));
      _buffer = _buffer.sublist(n);
      _recvTarget = null;
      _socketLogDebug(
        'recv_chunk_ready',
        'n=$n remaining=${_buffer.length}',
      );
      _recvCompleter!.complete(result);
    }
  }

  Future<void> send(dynamic value) async {
    final body = encodeMessage(value);
    final header = _intToLittleEndianBytes(body.length);
    _socketLogDebug(
      'send',
      'headerLen=${header.length} bodyLen=${body.length} valueType=${value.runtimeType}',
    );
    _socket.add([...header, ...body]);
    await _socket.flush();
  }

  Future<dynamic> recv() async {
    final headerBytes = await _readExactly(4);
    final length = _littleEndianBytesToInt(headerBytes);
    if (length < 0 || length > 10 * 1024 * 1024) {
      throw FormatException('Invalid message length: $length');
    }
    _socketLogDebug(
      'recv_header',
      'len=$length',
    );
    final bodyBytes = await _readExactly(length);
    _socketLogDebug(
      'recv_body',
      'bodyLen=${bodyBytes.length}',
    );
    return decodeMessage(bodyBytes);
  }

  Future<List<int>> _readExactly(int n) async {
    if (_buffer.length >= n) {
      final result = List<int>.from(_buffer.take(n));
      _buffer = _buffer.sublist(n);
      return result;
    }
    _recvTarget = n;
    _recvCompleter = Completer<List<int>>();
    _socketLogDebug(
      'recv_wait',
      'need=$n current=${_buffer.length}',
    );
    return _recvCompleter!.future;
  }

  bool _closed = false;

  void close() {
    if (!_closed) {
      _closed = true;
      String addr = '(unknown)';
      try {
        addr = '${_socket.address.address}:${_socket.port}';
      } catch (_) {
        // socket 已关闭或不可用时，访问 address 可能抛异常，忽略即可
      }
      _socket.destroy();
      _socketLogDebug(
        'close',
        'local=$addr',
      );
    }
  }

  bool get isClosed => _closed;

  static List<int> _intToLittleEndianBytes(int value) {
    return [
      value & 0xff,
      (value >> 8) & 0xff,
      (value >> 16) & 0xff,
      (value >> 24) & 0xff,
    ];
  }

  static int _littleEndianBytesToInt(List<int> bytes) {
    assert(bytes.length >= 4);
    return bytes[0] |
        (bytes[1] << 8) |
        (bytes[2] << 16) |
        (bytes[3] << 24);
  }
}

Future<ProtocolSocket> connect(String host, int port) async {
  _socketLogDebug(
    'connect_start',
    'host=$host port=$port',
  );
  final socket = await Socket.connect(host, port);
  _socketLogDebug(
    'connect_success',
    'remote=${socket.remoteAddress.address}:${socket.remotePort} local=${socket.address.address}:${socket.port}',
  );
  return ProtocolSocket(socket);
}

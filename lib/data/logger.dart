import 'dart:io';

/// 简易文件日志（与 Python core/logger 类似）
///
/// 实现上改为每次写入时使用追加写（append），不再长期持有 IOSink，
/// 以避免在高频异步场景下触发 “StreamSink is bound to a stream” 异常。
class AppLogger {
  AppLogger._();

  static AppLogger? _instance;

  static AppLogger get instance {
    _instance ??= AppLogger._();
    return _instance!;
  }

  File? _file;
  String? _logPath;
  Future<void> _writeQueue = Future<void>.value();

  /// 初始化日志：写入 {name}_{时间戳}.log
  ///
  /// 日志目录位于程序运行根目录下的 ./log，而不是系统 AppData 目录，
  /// 方便直接在项目根目录或可执行文件所在目录查看。
  Future<void> init(String name) async {
    await close();
    // 使用当前工作目录作为根目录
    final rootDir = Directory.current.path;
    final logDir = '$rootDir/log';
    final logDirFile = Directory(logDir);
    if (!await logDirFile.exists()) await logDirFile.create(recursive: true);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    _logPath = '$logDir/${name}_$timestamp.log';
    _file = File(_logPath!);
    // 覆盖旧文件，保证每次启动都是新的日志内容
    if (await _file!.exists()) {
      await _file!.writeAsString('', mode: FileMode.write, flush: true);
    }
  }

  /// 调试日志：时间 - DEBUG - 模块 - 操作 - 详细信息
  void debug(String module, String action, String detail) {
    final ts = DateTime.now().toIso8601String();
    final line = '$ts - DEBUG - $module - $action - $detail\n';
    _safeAppend(line);
  }

  void info(String message) {
    final line = '${DateTime.now().toIso8601String()} - INFO - $message\n';
    _safeAppend(line);
  }

  void error(String message) {
    final line = '${DateTime.now().toIso8601String()} - ERROR - $message\n';
    _safeAppend(line);
  }

  void _safeAppend(String line) {
    final f = _file;
    if (f == null) return;
    // 将写入排队到一个串行的异步队列中，避免阻塞 UI 线程
    _writeQueue = _writeQueue.then((_) async {
      try {
        await f.writeAsString(line, mode: FileMode.append, flush: false);
      } catch (_) {
        // 日志失败不应影响主流程，这里忽略异常
      }
    });
  }

  String? get logPath => _logPath;

  Future<void> close() async {
    // 采用同步追加写后，这里只需要清理引用即可。
    _file = null;
    _logPath = null;
  }
}

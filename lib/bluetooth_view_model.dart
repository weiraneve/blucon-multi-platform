import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum BluConState { disconnected, connecting, connected }

class BluetoothViewModel extends ChangeNotifier {
  BluConState _connectionState = BluConState.disconnected;

  BluConState get connectionState => _connectionState;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  final _batteryLevel = 0;

  int get batteryLevel => _batteryLevel;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<void> startScan() async {
    if (_connectionState == BluConState.disconnected) {
      try {
        _connectionState = BluConState.connecting;
        notifyListeners();
        print('开始扫描设备...');

        // 添加超时处理
        Future.delayed(const Duration(seconds: 30), () {
          if (_connectionState == BluConState.connecting) {
            print('扫描超时，自动停止');
            stopScan();
          }
        });

        // 监听扫描结果
        _scanSubscription = FlutterBluePlus.scanResults.listen(
          (results) {
            print('发现 ${results.length} 个设备');
            for (ScanResult result in results) {
              print(
                  '设备名称: ${result.device.name}, MAC: ${result.device.remoteId}');
              if (result.device.name.isNotEmpty &&
                  (result.device.name.contains('Ao') ||
                      result.device.name.contains('ao'))) {
                print('找到目标设备: ${result.device.name}');
                _device = result.device;
                stopScan();
                _connectToDevice();
                break;
              }
            }
          },
          onError: (error) {
            print('扫描错误: $error');
            _connectionState = BluConState.disconnected;
            notifyListeners();
          },
          onDone: () {
            print('扫描完成');
          },
        );

        // 开始扫描
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 30),
          androidUsesFineLocation: true,
        );
      } catch (e) {
        print('启动扫描错误: $e');
        _connectionState = BluConState.disconnected;
        notifyListeners();
      }
    }
  }

  Future<void> _connectToDevice() async {
    if (_device == null) return;

    try {
      print('正在连接设备...');
      await _device?.connect(timeout: const Duration(seconds: 15));
      print('设备连接成功，开始发现服务...');

      List<BluetoothService> services = await _device!.discoverServices();
      print('发现 ${services.length} 个服务');

      for (var service in services) {
        print('检查服务 UUID: ${service.uuid}');
        if (service.uuid.toString().toLowerCase().contains('ffe5')) {
          print('找到目标服务');
          for (var characteristic in service.characteristics) {
            print('检查特征 UUID: ${characteristic.uuid}');
            if (characteristic.uuid.toString().toLowerCase().contains('ffe9')) {
              print('找到写入特征');
              _writeCharacteristic = characteristic;
              break;
            }
          }
        }
      }

      if (_writeCharacteristic != null) {
        print('连接完成，可以开始通信');
        _connectionState = BluConState.connected;
        notifyListeners();
      } else {
        print('未找到必要的特征，断开连接');
        await _device?.disconnect();
        _connectionState = BluConState.disconnected;
        notifyListeners();
      }
    } catch (e) {
      print('连接过程错误: $e');
      _connectionState = BluConState.disconnected;
      notifyListeners();
    }
  }

  Future<bool> sendCommand(int key) async {
    if (_writeCharacteristic == null) return false;

    try {
      List<int> data = [(key >> 8) & 0xFF, key & 0xFF];
      await _writeCharacteristic!.write(data);
      return true;
    } catch (e) {
      print('发送命令错误: $e');
      return false;
    }
  }

  Future<void> stopScan() async {
    if (_connectionState == BluConState.connecting) {
      try {
        _scanSubscription?.cancel();
        await FlutterBluePlus.stopScan();
        if (_device == null) {
          _connectionState = BluConState.disconnected;
          notifyListeners();
        }
        print('停止扫描设备');
      } catch (e) {
        print('停止扫描错误: $e');
      }
    }
  }

  Future<bool> checkAndRequestPermissions() async {
    if (await _checkPermissions()) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> _checkPermissions() async {
    bool bluetoothStatus = await Permission.bluetooth.isGranted;
    bool bluetoothScanStatus = await Permission.bluetoothScan.isGranted;
    bool bluetoothConnectStatus = await Permission.bluetoothConnect.isGranted;
    bool locationStatus = await Permission.location.isGranted;

    return bluetoothStatus &&
        bluetoothScanStatus &&
        bluetoothConnectStatus &&
        locationStatus;
  }

  Future<bool> isBluetoothEnabled() async {
    return await FlutterBluePlus.isOn;
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _device?.disconnect();
    super.dispose();
  }
}

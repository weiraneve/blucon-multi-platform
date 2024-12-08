import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BluetoothViewModel _bluetoothViewModel = BluetoothViewModel();

  Future<void> _handleConnect() async {
    // 检查蓝牙是否开启
    if (!await _bluetoothViewModel.isBluetoothEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先开启蓝牙')),
      );
      return;
    }

    // 检查权限
    if (await _bluetoothViewModel.checkAndRequestPermissions()) {
      await _bluetoothViewModel.startScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要蓝牙权限才能继续')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    
    // 应用启动时进行初始化
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        // 检查蓝牙状态
        final isOn = await FlutterBluePlus.isOn;
        print('蓝牙状态: $isOn');
        
        // 尝试初始化扫描
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 1));
        await FlutterBluePlus.stopScan();
        
        // 检查权限
        await _bluetoothViewModel.checkAndRequestPermissions();
      } catch (e) {
        print('初始化错误: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: const Color(0xFFE7B8B8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 连接状态显示
            ListenableBuilder(
              listenable: _bluetoothViewModel,
              builder: (context, child) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    // 连接按钮
                    ElevatedButton(
                      onPressed: _bluetoothViewModel.connectionState ==
                              BluConState.connecting
                          ? null
                          : _handleConnect,
                      child: Text(_bluetoothViewModel.connectionState ==
                              BluConState.connected
                          ? '已连接'
                          : _bluetoothViewModel.connectionState ==
                                  BluConState.connecting
                              ? '连接中...'
                              : '连接蓝牙'),
                    ),
                    if (_bluetoothViewModel.connectionState ==
                        BluConState.connecting)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _bluetoothViewModel.stopScan(),
                          child: const Text('停止扫描'),
                        ),
                      ),
                    // 发送命令按钮
                    if (_bluetoothViewModel.connectionState ==
                        BluConState.connected)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_one_heart.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(2),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_two_hearts.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(3),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_three_hearts.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture0.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture1.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture2.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(7),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture3.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture4.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(9),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture5.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: () =>
                                      _bluetoothViewModel.sendCommand(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/mode_posture5.png',
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(40),
                              onTap: () => _bluetoothViewModel.sendCommand(255),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/images/mode_stop.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bluetoothViewModel.dispose();
    super.dispose();
  }
}

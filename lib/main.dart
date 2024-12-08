import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
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
                    // 停止扫描按钮
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
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _bluetoothViewModel.sendCommand(1),
                              child: const Text('启动'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              onPressed: () =>
                                  _bluetoothViewModel.sendCommand(255),
                              child: const Text('停止'),
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

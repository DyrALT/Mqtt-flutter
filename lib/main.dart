import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController t1 = TextEditingController();

  String broker = 'e6f13a7abaa74533b67b76e959c7ec12.s2.eu.hivemq.cloud';
  int port = 8883;
  String username = 'satech';
  String passwd = '<password>';
  String clientIdentifier = 'android';
  late MqttServerClient client;
  late StreamSubscription subscription;
  MqttClientConnectionStatus connectionStatus = MqttClientConnectionStatus()
    ..state = MqttConnectionState.disconnected;
  void _connect() async {
    client = MqttServerClient(
      broker,
      clientIdentifier,
    );
    client.port = port;
    client.logging(on: false);
    client.setProtocolV311();
    client.secure = true;
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean(); // Non persistent session for testing
    client.connectionMessage = connMess;

    try {
      await client.connect(username, passwd).then((value) {
        setState(() {
          connectionStatus.state = value!.state;
        });
      });
    } catch (e) {
      print('===============error== $e');
    }
  }

  void _subscribeToTopic(String topic, String message) {
    client.subscribe(topic, MqttQos.exactlyOnce);
    print('=================');
    client.publishMessage(topic, MqttQos.atLeastOnce,
        MqttClientPayloadBuilder().addString(message).payload!);
  }

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextField(
            controller: t1,
          ),
          ElevatedButton(
              onPressed: connectionStatus.state == MqttConnectionState.connected
                  ? () {
                      _subscribeToTopic("topic", t1.text);
                      t1.clear();
                    }
                  : null,
              child: const Text('hoom'))
        ],
      ),
    );
  }
}

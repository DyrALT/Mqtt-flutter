import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'mqtt_state.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit() : super(MqttDisconnectedState());

  final String _broker = 'e6f13a7abaa74533b67b76e959c7ec12.s2.eu.hivemq.cloud';
  final int _port = 8883;
  final String _topic = 'topic';
  final String _username = 'satech';
  final String _passwd = '<password>';
  final String _clientIdentifier = 'android';
  late MqttServerClient _client;
  // late StreamSubscription subscription;

  bool ledValue = false;

  connectClient() async {
    _client = MqttServerClient(
      _broker,
      _clientIdentifier,
    );
    _client.port = _port;
    _client.logging(on: false);
    _client.setProtocolV311();
    _client.secure = true;
    _client.keepAlivePeriod = 20;
    _client.connectTimeoutPeriod = 2000;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_clientIdentifier)
        .startClean(); // Non persistent session for testing
    _client.connectionMessage = connMess;

    try {
      await _client.connect(_username, _passwd).then((value) {
        if (value!.state == MqttConnectionState.connected) {
          emit(MqttConnectedState(ledValue: ledValue));
        } else {
          emit(MqttDisconnectedState());
        }
      });
    } catch (e) {
      print('===============error== $e');
      emit(MqttDisconnectedState());
    }
  }

  sendMessage(String message) {
    // _client.subscribe(_topic, MqttQos.exactlyOnce);
    print('=================');
    _client.publishMessage(_topic, MqttQos.atLeastOnce,
        MqttClientPayloadBuilder().addString(message).payload!);
  }

  ledOnChange(bool value) {
    ledValue = !ledValue;
    _client.publishMessage(_topic, MqttQos.atLeastOnce,
        MqttClientPayloadBuilder().addString(ledValue ? 'open' : 'close').payload!);
    emit(MqttConnectedState(ledValue: ledValue));
  }
}

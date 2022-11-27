part of 'mqtt_cubit.dart';

@immutable
abstract class MqttState {}

class MqttInitial extends MqttState {}

class MqttConnectedState extends MqttState {
  final bool ledValue;
  MqttConnectedState({required this.ledValue});
}

class MqttDisconnectedState extends MqttState {}

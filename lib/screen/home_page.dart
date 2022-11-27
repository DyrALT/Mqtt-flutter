import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/cubit/mqtt_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController t1 = TextEditingController();
  late MqttCubit cubit;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cubit = MqttCubit();
    cubit.connectClient();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('MQTT App'),
        elevation: 0.0,
      ),
      body: body(cubit),
    );
  }

  Column body(MqttCubit cubit) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
            controller: t1,
            decoration: const InputDecoration(
              hintText: 'Enter Message',
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            ),
          ),
        ),
        BlocBuilder(
          bloc: cubit,
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state.runtimeType == MqttConnectedState) {
              return ElevatedButton(
                onPressed: () {
                  cubit.sendMessage(t1.text);
                  t1.clear();
                },
                child: const Text('Send Message'),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Led Durumu'),
            BlocBuilder(
              bloc: cubit,
              builder: (context, state) {
                if (state.runtimeType == MqttConnectedState) {
                  return Switch(
                    value: (state as MqttConnectedState).ledValue,
                    onChanged: cubit.ledOnChange,
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        )
      ],
    );
  }
}

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class VideoStream extends StatefulWidget {
  final CameraDescription camera;

  const VideoStream({super.key, required this.camera});

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late MqttServerClient _mqttClient;
  final RxList<String> printedValues = <String>[].obs;

  final String brokerAddress = "192.168.240.180";
  final int port = 1883;
  final String topic = "video/stream";

  @override
  void initState() {
    super.initState();

    // Initialize the camera
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();

    // Initialize the MQTT client
    _mqttClient = MqttServerClient(brokerAddress, '');
    _mqttClient.port = port;
    _mqttClient.logging(on: true);
    _mqttClient.onConnected = onConnected;
    _mqttClient.onDisconnected = onDisconnected;

    connectMqtt();
  }

  Future<void> connectMqtt() async {
    try {
      await _mqttClient.connect();
    } catch (e) {
      print('MQTT connection failed: $e');
      printedValues.add('MQTT connection failed: $e');
      _mqttClient.disconnect();
    }
  }

  void onConnected() {
    print('MQTT Connected');
    printedValues.add('MQTT Connected');
  }

  void onDisconnected() {
    print('MQTT Disconnected');
    printedValues.add('MQTT Disconnected');
  }

  void publishFrame(Uint8List frameData) {
    if (_mqttClient.connectionStatus?.state == MqttConnectionState.connected) {
      final base64Data = base64Encode(frameData);
      final message = MqttClientPayloadBuilder();
      message.addString(base64Data);

      var result = _mqttClient.publishMessage(
          topic, MqttQos.atLeastOnce, message.payload!);
      printedValues.add('publishMessage:  $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Streaming')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Start streaming frames
            _controller.startImageStream((CameraImage image) {
              // Convert YUV to JPEG
              final frameData = _yuvToJpeg(image);
              publishFrame(frameData);
            });

            return Column(
              children: [
                CameraPreview(_controller),
                Expanded(
                  child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: printedValues.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(
                        printedValues[index],
                        style: const TextStyle(color: Colors.red),
                      );
                    },
                  )),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.stopImageStream();
          _mqttClient.disconnect();
          Navigator.pop(context);
        },
        child: const Icon(Icons.stop),
      ),
    );
  }

  Uint8List _yuvToJpeg(CameraImage image) {
    // Convert CameraImage to JPEG (you may use external libraries like 'image' for this)
    // This is a placeholder for actual conversion logic.
    return Uint8List.fromList([]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _mqttClient.disconnect();
    super.dispose();
  }
}

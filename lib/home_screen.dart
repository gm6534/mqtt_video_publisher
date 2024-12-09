import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mqtt_video_publisher/video_stream.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController bAddressController = TextEditingController(text: '192.168.240.180');
  final TextEditingController portController = TextEditingController(text: '1883');
  final TextEditingController topicController = TextEditingController(text: 'video/stream');

  HomeScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home Screen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: bAddressController,
              decoration: const InputDecoration(
                labelText: 'Broker Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final cameras = await availableCameras();
                  final firstCamera = cameras.first;
                  Get.to(() => VideoStream(camera: firstCamera));
                },
                child: const Text('Go to Stream'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

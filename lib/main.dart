import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;


void main() {
  runApp(const MyApp());
}

// stful,stless
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compass',
      home: Scaffold(
        // backgroundColor: Color.fromARGB(255, 172, 172, 249),
        backgroundColor: Color.fromARGB(255, 255, 34, 34),

        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  //compass widget
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context,snapshot){
        if(snapshot.hasError){
          return Text('Error reading heading: ${snapshot.error}');
        }

        if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(
            child:CircularProgressIndicator(),
          );
        }

        double?direction=snapshot.data!.heading;

        if(direction==null){
          return const Center(child: Text('Device doesnt have sensors'),);
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Transform.rotate(
              angle: direction*(math.pi/180)*-1,
              child: Image.asset('lib/images/white.png',color: Color.fromARGB(255, 0, 0, 0)
              // color: Color.fromARGB(255, 255, 34, 34),
                        ),
            ),
        ),
      );
      },
    );
  }

  //permission sheet widget

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: Text('Required Permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }
}

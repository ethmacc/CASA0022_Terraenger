import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:smarthiking_app/models/db_manager.dart';
import 'package:geolocator/geolocator.dart';

class ConnManager extends ChangeNotifier {
  final _ble = FlutterReactiveBle();

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connectSub;
  StreamSubscription<List<int>>? _notifySub;

  bool connected = false;
  bool get isConnected => connected;

  bool scanning = false;
  bool get isScanning => scanning;

  int activeHikeId = -1;
  int get getActiveHikeId => activeHikeId;

  List<int> decoded = List.empty(growable: true); 

  void activateHike(int id) {
    activeHikeId = id;
    notifyListeners();
  }

  void deactivateHike() {
    activeHikeId = -1;
    notifyListeners();
  }

  bool isHikeActive(int id) {
    if (activeHikeId == id) {
      return true;
    }
    else {
      return false;
    }
  }

  void connect() {
    scanning = true;
    _scanSub = _ble.scanForDevices(withServices: []).listen(
                  _onScanUpdate,
                  onError: (e) {
                    debugPrint('${e.name}');
                  },
                );
    notifyListeners();
  }

  void disconnect() {
    _notifySub?.cancel();
    _connectSub?.cancel();
    _scanSub?.cancel();
    connected = false;
    scanning = false;
    notifyListeners();
  }

  void _onScanUpdate(DiscoveredDevice d) {
      if (d.name == 'SH_v1' && !connected) {
        debugPrint("Found device");
        _scanSub?.cancel();
        _connectSub = _ble.connectToDevice(id: d.id).listen((update) {
          if (update.connectionState == DeviceConnectionState.connected) {
            _onConnected(d.id);
            connected = true;
            scanning = false;
          } 
        });
      }
    }

  void _onConnected(String deviceId) {
    _ble.requestMtu(deviceId: deviceId, mtu: 512);

    final characteristic = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: Uuid.parse('185B'),
        characteristicId: Uuid.parse('2C0A'));

    _notifySub = _ble.subscribeToCharacteristic(characteristic).listen((bytes) async {
        decoded.clear();
        ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
        for (var i= 0; i < bytes.length;i += 2) {
          int decodedInt = byteData.getUint16(i, Endian.little);
          decoded.add(decodedInt);
        }
        debugPrint('Decoded: $decoded');
        if (activeHikeId != -1) {
          int newSampleId = await getLatestID('samples');
          Position? currentPosition = await Geolocator.getLastKnownPosition();
          debugPrint('$currentPosition');
          if (currentPosition != null) {
            insertSample(
              Sample(
                id: newSampleId, 
                hikeId: activeHikeId, 
                tofData: '$decoded', 
                lat: currentPosition.latitude, 
                long: currentPosition.longitude,
                elevation: currentPosition.altitude,
                )
            );
            notifyListeners();
          }
        } else {
          debugPrint('No hike is active, data not captured');
        }
    });
  }
}
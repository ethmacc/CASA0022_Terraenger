import 'package:flutter/material.dart';
import 'package:smarthiking_app/widgets/bottom_navbar.dart';
import 'package:smarthiking_app/screens/enter_hike.dart';
import 'package:smarthiking_app/models/db_manager.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EnterHike())
            );
        },
        child: Icon(Icons.add)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Backups'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: () {
                exportBackup();
              }, 
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
                foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
              ),
              icon: Icon(Icons.ios_share),
            ),
            Text('Export backup'),
            Padding(padding: EdgeInsets.all(20)),
              IconButton(
              onPressed: () {
                importBackup();
              }, 
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.red),
                foregroundColor: WidgetStatePropertyAll<Color>(Colors.white),
              ),
              icon: Icon(Icons.download),
            ),
            Text('Import backup'),
          ],
        )
      )
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ser_stat/screens/manage_servers.dart';
import 'package:ser_stat/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
      routes: {'/settings': (context) => SettingsPage()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ServerInfo> servers = [];

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? serverStrings = prefs.getStringList('servers');
    if (serverStrings != null) {
      setState(() {
        servers =
            serverStrings
                .map((s) => ServerInfo.fromJson(jsonDecode(s)))
                .toList();
        _fetchServerTimes();
      });
    }
  }

  Future<void> _fetchServerTimes() async {
    for (var server in servers) {
      if (server.url.isNotEmpty) {
        try {
          var stopwatch = Stopwatch()..start();
          final response = await http.get(Uri.parse(server.url));
          stopwatch.stop();
          setState(() {
            server.responseTime = stopwatch.elapsedMilliseconds;
            server.statusCode = response.statusCode;
          });
          /*log(
            "\nServer: ${server.name}:\nResponse Time: ${server.responseTime}ms\nStatus Code: ${server.statusCode}\nResponse: ${response.body}",
          );*/
        } catch (e) {
          setState(() {
            server.responseTime = -1; // Indicate error
            server.statusCode = -1;
          });
        }
      }
    }
  }

  Future<void> _saveServers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> serverStrings =
        servers.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('servers', serverStrings);
  }

  void _openManageServersPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageServersPage(servers: servers),
      ),
    );
    if (result != null) {
      setState(() {
        servers = result;
      });
      _saveServers();
      _fetchServerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: servers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(servers[index].name),
            subtitle: Text(servers[index].url),
            trailing: Text(
              servers[index].responseTime == -1
                  ? '[${servers[index].statusCode}]Error'
                  : '[${servers[index].statusCode}]${servers[index].responseTime}ms',
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openManageServersPage,
        child: Icon(Icons.add),
      ),
    );
  }
}

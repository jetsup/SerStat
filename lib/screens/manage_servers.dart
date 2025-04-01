import 'package:flutter/material.dart';

class ManageServersPage extends StatefulWidget {
  final List<ServerInfo> servers;

  const ManageServersPage({super.key, required this.servers});

  @override
  _ManageServersPageState createState() => _ManageServersPageState();
}

class _ManageServersPageState extends State<ManageServersPage> {
  List<ServerInfo> _servers = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _servers = List.from(widget.servers);
  }

  void _editServer(int index) {
    TextEditingController nameController = TextEditingController(
      text: _servers[index].name,
    );
    TextEditingController urlController = TextEditingController(
      text: _servers[index].url,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Server'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Server Name'),
              ),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'Server URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _servers[index].name = nameController.text;
                  _servers[index].url = urlController.text;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Servers')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Server Name'),
            ),
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: 'Server URL'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _servers.add(
                    ServerInfo(
                      name: nameController.text,
                      url: urlController.text,
                      responseTime: 0,
                      statusCode: 0,
                    ),
                  );
                  nameController.clear();
                  urlController.clear();
                });
              },
              child: Text('Add Server'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _servers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_servers[index].name),
                    subtitle: Text(_servers[index].url),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editServer(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _servers.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _servers); // Important change!
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerInfo {
  String name;
  String url;
  int responseTime;
  int statusCode;

  ServerInfo({
    required this.name,
    required this.url,
    required this.responseTime,
    required this.statusCode,
  });

  ServerInfo.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      url = json['url'],
      responseTime = json['responseTime'],
      statusCode = json['statusCode'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'responseTime': responseTime,
    'statusCode': statusCode,
  };
}

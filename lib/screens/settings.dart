import 'dart:developer';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late encrypt.Key encryptionKey; // = encrypt.Key.fromUtf8("mysup3s3cur3key");
  late encrypt.IV iv; // = encrypt.IV.fromLength(16);

  late encrypt.Encrypter
  encrypter; // = encrypt.Encrypter(encrypt.AES(encryptionKey));

  @override
  void initState() {
    super.initState();

    encryptionKey = encrypt.Key.fromUtf8("mysup3s3cur3key01234567890sersta");
    encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey));

    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encryptedUsername = prefs.getString('username');
    String? encryptedPassword = prefs.getString('password');
    String? storedIv = prefs.getString('iv');

    if (encryptedUsername != null &&
        encryptedPassword != null &&
        storedIv != null) {
      final encUsername = encrypt.Encrypted.fromBase64(encryptedUsername);
      final encPassword = encrypt.Encrypted.fromBase64(encryptedPassword);
      iv = encrypt.IV.fromBase64(storedIv);

      try {
        String username = encrypter.decrypt(encUsername, iv: iv);
        String password = encrypter.decrypt(encPassword, iv: iv);

        usernameController.text = username;
        passwordController.text = password;
      } catch (e) {
        log("Decryption Error: $e");
      }
    } else {
      if (storedIv == null) {
        iv = encrypt.IV.fromLength(16);
      }
    }
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    iv = encrypt.IV.fromLength(16);

    final encryptedUsername = encrypter.encrypt(
      usernameController.text,
      iv: iv,
    );
    final encryptedPassword = encrypter.encrypt(
      passwordController.text,
      iv: iv,
    );

    await prefs.setString('username', encryptedUsername.base64);
    await prefs.setString('password', encryptedPassword.base64);
    await prefs.setString('iv', iv.base64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveCredentials();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Credentials Saved')));
              },
              child: Text('Save Credentials'),
            ),
          ],
        ),
      ),
    );
  }
}

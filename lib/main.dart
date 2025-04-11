import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carros Eléctricos',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String error = '';

  void _login() {
    if (_userCtrl.text == 'admin' && _passCtrl.text == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        error = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _userCtrl, decoration: InputDecoration(labelText: 'Usuario')),
            TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _login, child: Text('Ingresar')),
            if (error.isNotEmpty) Text(error, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List carros = [];
  TextEditingController qrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCarros();
  }

  Future<void> fetchCarros() async {
    final url = 'https://67f7d1812466325443eadd17.mockapi.io/carros';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        carros = json.decode(response.body);
      });
    }
  }

  void buscarPorQR() {
    final qr = qrController.text.trim();
    if (qr.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CarDetailPage(codigoQR: qr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Carros Eléctricos')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qrController,
                    decoration: InputDecoration(labelText: 'Código QR'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: buscarPorQR,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: carros.length,
              itemBuilder: (context, index) {
                final carro = carros[index];
                return ListTile(
                  title: Text(carro['modelo']),
                  subtitle: Text('ID: ${carro['id']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CarDetailPage extends StatelessWidget {
  final String codigoQR;
  CarDetailPage({required this.codigoQR});

  Future<Map<String, dynamic>?> fetchCarro() async {
    final url = 'https://67f7d1812466325443eadd17.mockapi.io/carros/$codigoQR';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del Carro')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchCarro(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasData) {
            final carro = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modelo: ${carro['modelo']}', style: TextStyle(fontSize: 20)),
                  Text('Color: ${carro['color']}'),
                  Text('ID: ${carro['id']}'),
                ],
              ),
            );
          } else {
            return Center(child: Text('Carro no encontrado'));
          }
        },
      ),
    );
  }
}

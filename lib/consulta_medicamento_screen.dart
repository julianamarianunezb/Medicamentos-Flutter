import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultaMedicamentoScreen extends StatefulWidget {
  const ConsultaMedicamentoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConsultaMedicamentoScreenState createState() => _ConsultaMedicamentoScreenState();
}

class _ConsultaMedicamentoScreenState extends State<ConsultaMedicamentoScreen> {
  final TextEditingController _nombreController = TextEditingController();

  Future<void> _consultarDisponibilidad() async {
    String nombre = _nombreController.text.trim();
    if (nombre.isNotEmpty) {
      String url = 'https://datos.gov.co/resource/sdmr-tfmf.json?nombre_comercial_=${Uri.encodeQueryComponent(nombre)}';

      try {
        http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          List<dynamic> resultadosJson = jsonDecode(response.body);
          if (resultadosJson.isEmpty) {
            _mostrarError('Se encuentra escaso el medicamento $nombre.');
          } else {
            bool encontrado = false;
            for (var resultadoJson in resultadosJson) {
              if (resultadoJson['nombre_comercial_'] == nombre) {
                encontrado = true;
                break;
              }
            }
            if (!encontrado) {
              _mostrarResultado('El medicamento $nombre no está disponible.');
            } else {
              _mostrarResultado('El medicamento $nombre está disponible.');
            }
          }
        } else {
          _mostrarError(
              'Error al consultar el medicamento - Código de estado: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarError('Error al consultar el medicamento: $e');
      }
    } else {
      _mostrarError('Por favor ingrese el nombre del medicamento.');
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarResultado(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resultado'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(), // Configura el tema oscuro
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Consulta de Disponibilidad de Medicamento'),
          backgroundColor: Colors.black, // Cambia el color de la barra de aplicación
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Comercial del Medicamento'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _consultarDisponibilidad,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Cambia el color del botón
                ),
                child: const Text('Consultar Disponibilidad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

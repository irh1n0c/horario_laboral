import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart'; //formato hora minuto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exportar a Excel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TablaAsistenciasPage(),
    );
  }
}

class TablaAsistenciasPage extends StatelessWidget {
  const TablaAsistenciasPage({super.key});

  Future<List<Map<String, dynamic>>> obtenerAsistencias() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    CollectionReference asistenciaRef = FirebaseFirestore.instance
        .collection('registros_tiempo')
        .doc(user.uid)
        .collection('dias');

    QuerySnapshot snapshot = await asistenciaRef.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> exportarAsistencias() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> asistencias = await obtenerAsistencias();
    var excel = Excel.createExcel();
    Sheet sheet = excel['Asistencias'];

    // Añadir encabezados (cambiando "Alias" por "Usuario")
    sheet.appendRow([
      TextCellValue('Usuario'),
      TextCellValue('Entrada'),
      TextCellValue('Salida'),
      TextCellValue('Dirección'),
      TextCellValue('Dispositivo'),
    ]);

    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    // Añadir datos (cambiando "Alias" por "Usuario")
    for (var asistencia in asistencias) {
      String entrada = asistencia['entrada'] != null
          ? formatter.format(asistencia['entrada'].toDate())
          : '';
      String salida = asistencia['salida'] != null
          ? formatter.format(asistencia['salida'].toDate())
          : 'No registrado';
      sheet.appendRow([
        TextCellValue(asistencia['alias'] ?? ''),
        TextCellValue(entrada),
        // TextCellValue(asistencia['entrada']?.toDate().toString() ?? ''),
        TextCellValue(salida),
        // TextCellValue(
        //     asistencia['salida']?.toDate().toString() ?? 'No registrado'),
        TextCellValue(asistencia['direccion'] ?? 'No disponible'),
        TextCellValue(asistencia['dispositivo'] ?? 'No disponible'),
      ]);
    }

    // Guardar el archivo en el dispositivo
    final Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/asistencias.xlsx';
    var fileBytes = excel.save();

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    print('Archivo guardado en: $filePath');

    // Abrir el archivo
    await OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tabla de Asistencias'),
        ),
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }

    CollectionReference asistenciaRef = FirebaseFirestore.instance
        .collection('registros_tiempo')
        .doc(user.uid)
        .collection('dias');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Asistencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await exportarAsistencias();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Asistencias exportadas a Excel')),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: asistenciaRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          List<Map<String, dynamic>> asistencias = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // Permitir desplazamiento horizontal
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Usuario')), // Cambiado a "Usuario"
                  DataColumn(label: Text('Entrada')),
                  DataColumn(label: Text('Salida')),
                  DataColumn(label: Text('Dirección')),
                  DataColumn(label: Text('Dispositivo')),
                ],
                rows: asistencias.map((asistencia) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(asistencia['alias'] ?? '')),
                      DataCell(Text(
                          asistencia['entrada']?.toDate().toString() ?? '')),
                      DataCell(Text(asistencia['salida'] != null
                          ? asistencia['salida'].toDate().toString()
                          : 'No registrado')),
                      DataCell(
                          Text(asistencia['direccion'] ?? 'No disponible')),
                      DataCell(
                          Text(asistencia['dispositivo'] ?? 'No disponible')),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exportar a Excel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TablaAsistenciasPage(),
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

    // Añadir encabezados con las nuevas columnas
    sheet.appendRow([
      TextCellValue('Usuario'),
      TextCellValue('Fecha'),
      TextCellValue('Hora Entrada'),
      TextCellValue('Hora Salida'),
      TextCellValue('Dirección'),
      TextCellValue('Dispositivo'),
    ]);

    // Función auxiliar para formatear la hora con AM/PM
    String formatearHora(DateTime? fecha) {
      if (fecha == null) return '';

      int hora = fecha.hour;
      String periodo = hora >= 12 ? 'PM' : 'AM';

      // Convertir a formato 12 horas
      if (hora > 12) {
        hora -= 12;
      } else if (hora == 0) {
        hora = 12;
      }

      return '${hora.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')} $periodo';
    }

    // Función auxiliar para formatear la fecha (dd/MM/yyyy)
    String formatearFecha(DateTime? fecha) {
      if (fecha == null) return '';
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    }

    // Añadir datos con el nuevo formato
    for (var asistencia in asistencias) {
      DateTime? fechaEntrada = asistencia['entrada']?.toDate();
      DateTime? fechaSalida = asistencia['salida']?.toDate();

      sheet.appendRow([
        TextCellValue(asistencia['alias'] ?? ''),
        TextCellValue(formatearFecha(fechaEntrada)), // Fecha solo de la entrada
        TextCellValue(formatearHora(fechaEntrada)), // Hora de entrada con AM/PM
        TextCellValue(fechaSalida != null
            ? formatearHora(fechaSalida)
            : 'No registrado'), // Hora de salida con AM/PM
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
                const SnackBar(content: Text('Asistencias exportadas a Excel')),
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
              scrollDirection: Axis.vertical, // Scroll vertical externo
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
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class TablaAsistenciasPageAll extends StatefulWidget {
  const TablaAsistenciasPageAll({super.key});

  @override
  _TablaAsistenciasPageAllState createState() =>
      _TablaAsistenciasPageAllState();
}

class _TablaAsistenciasPageAllState extends State<TablaAsistenciasPageAll> {
  List<String> uids = [];

  @override
  void initState() {
    super.initState();
    _fetchUserUids();
  }

  Future<void> _fetchUserUids() async {
    try {
      // Obtener la colección de usuarios
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('usuarios') // Asume que tienes una colección de usuarios
          .get();

      // Extraer los UIDs de los documentos de usuarios
      setState(() {
        uids = usersSnapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      debugPrint("Error al obtener UIDs de usuarios: $e");
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      obtenerAsistenciasDeUsuariosEspecificos() async {
    Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario = {};

    try {
      for (var uid in uids) {
        CollectionReference diasRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(uid)
            .collection('dias');

        QuerySnapshot diasSnapshot = await diasRef.get();

        for (var diaDoc in diasSnapshot.docs) {
          Map<String, dynamic> data = diaDoc.data() as Map<String, dynamic>;
          String alias = data['alias'] ?? 'Sin alias';

          asistenciasPorUsuario.putIfAbsent(alias, () => []).add(data);
        }
      }
    } catch (e) {
      debugPrint("Error al obtener asistencias: $e");
    }

    return asistenciasPorUsuario;
  }

  Future<void> exportarAsistenciasDeUsuariosEspecificos() async {
    var excel = Excel.createExcel();
    excel.delete('Sheet1'); // Elimina la hoja predeterminada

    Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario =
        await obtenerAsistenciasDeUsuariosEspecificos();

    asistenciasPorUsuario.forEach((alias, asistencias) {
      Sheet sheet = excel[alias];

      sheet.appendRow([
        TextCellValue('Usuario'),
        TextCellValue('Entrada'),
        TextCellValue('Salida'),
        TextCellValue('Dirección'),
        TextCellValue('Dispositivo'),
      ]);

      for (var asistencia in asistencias) {
        sheet.appendRow([
          TextCellValue(asistencia['alias'] ?? ''),
          TextCellValue(asistencia['entrada']?.toDate().toString() ?? ''),
          TextCellValue(
              asistencia['salida']?.toDate().toString() ?? 'No registrado'),
          TextCellValue(asistencia['direccion'] ?? 'No disponible'),
          TextCellValue(asistencia['dispositivo'] ?? 'No disponible'),
        ]);
      }
    });

    final Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/asistencias_usuarios_especificos.xlsx';
    var fileBytes = excel.save();

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    debugPrint('Archivo guardado en: $filePath');
    await OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Asistencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await exportarAsistenciasDeUsuariosEspecificos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Asistencias exportadas a Excel')),
              );
            },
          ),
        ],
      ),
      body: uids.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
              future: obtenerAsistenciasDeUsuariosEspecificos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar datos'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay datos disponibles'));
                }

                Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario =
                    snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: asistenciasPorUsuario.entries.map((entry) {
                      String usuario = entry.key;
                      List<Map<String, dynamic>> asistencias = entry.value;

                      return ExpansionTile(
                        title: Text(usuario),
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const <DataColumn>[
                                DataColumn(label: Text('Usuario')),
                                DataColumn(label: Text('Entrada')),
                                DataColumn(label: Text('Salida')),
                                DataColumn(label: Text('Dirección')),
                                DataColumn(label: Text('Dispositivo')),
                              ],
                              rows: asistencias.map((asistencia) {
                                return DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(asistencia['alias'] ?? '')),
                                    DataCell(Text(asistencia['entrada'] != null
                                        ? asistencia['entrada']
                                            .toDate()
                                            .toString()
                                        : 'No registrado')),
                                    DataCell(Text(asistencia['salida'] != null
                                        ? asistencia['salida']
                                            .toDate()
                                            .toString()
                                        : 'No registrado')),
                                    DataCell(Text(asistencia['direccion'] ??
                                        'No disponible')),
                                    DataCell(Text(asistencia['dispositivo'] ??
                                        'No disponible')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}

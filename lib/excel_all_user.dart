import 'package:cloud_firestore/cloud_firestore.dart';
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
      home: TablaAsistenciasPageAll(),
    );
  }
}

class TablaAsistenciasPageAll extends StatelessWidget {
  TablaAsistenciasPageAll({super.key});

  final List<String> uids = [
    'Qoml3dDyV3hU4edHCad7ezVXIe23',
    'CgXSYZK9i4Vik8joyyLTII6wxcx2',
    'OQl7UyLgI6OjKPuCrEgRNovpXQ52',
    'OPF1EByld1XKBshoLmQko5BCQlc2',
    'SkywV6I79Ebp0Ey9iYx8Z1T9s152',
    'jMPFZIaP0yWHbgrZPwug4u8UPYA2',
    'EiEVo1WACXRM7eX0WPl2Np7pSpZ2',
    'JEtd2gpNfQWUQrM4T4ElYAd24km1',
    's3Tfiv1kp1czoj9Yqp6hBuDPxPS2',
    'J1YDKxaRW6VgSes2mA1W3nF3SG13',
    'sLCygj3eZFZr0ruGYHFswvzSqm63',
    'ZWJ936qs7cUiJnid3XyMo1CCICn1',
  ];

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

  // Nuevo método para obtener los viajes de usuarios específicos
  Future<Map<String, List<Map<String, dynamic>>>>
      obtenerViajesDeUsuariosEspecificos() async {
    Map<String, List<Map<String, dynamic>>> viajesPorUsuario = {};

    try {
      for (var uid in uids) {
        CollectionReference viajesRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(uid)
            .collection('viajes');

        QuerySnapshot viajesSnapshot = await viajesRef.get();

        for (var viajeDoc in viajesSnapshot.docs) {
          Map<String, dynamic> data = viajeDoc.data() as Map<String, dynamic>;
          String alias = data['alias'] ?? 'Sin alias';

          viajesPorUsuario.putIfAbsent(alias, () => []).add(data);
        }
      }
    } catch (e) {
      debugPrint("Error al obtener viajes: $e");
    }

    return viajesPorUsuario;
  }

  Future<void> exportarAsistenciasDeUsuariosEspecificos() async {
    var excel = Excel.createExcel();
    excel.delete('Sheet1'); // Elimina la hoja predeterminada

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

    // Obtener las asistencias y viajes
    Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario =
        await obtenerAsistenciasDeUsuariosEspecificos();
    Map<String, List<Map<String, dynamic>>> viajesPorUsuario =
        await obtenerViajesDeUsuariosEspecificos();

    // Primero, exportar asistencias (como antes)
    asistenciasPorUsuario.forEach((alias, asistencias) {
      Sheet sheet = excel[alias];

      sheet.appendRow([
        TextCellValue('Usuario'),
        TextCellValue('Fecha'),
        TextCellValue('Hora Entrada'),
        TextCellValue('Hora Salida'),
        TextCellValue('Dirección'),
        TextCellValue('Dispositivo'),
      ]);

      for (var asistencia in asistencias) {
        DateTime? fechaEntrada = asistencia['entrada']?.toDate();
        DateTime? fechaSalida = asistencia['salida']?.toDate();

        sheet.appendRow([
          TextCellValue(asistencia['alias'] ?? ''),
          TextCellValue(formatearFecha(fechaEntrada)), // Fecha formateada
          TextCellValue(
              formatearHora(fechaEntrada)), // Hora de entrada formateada
          TextCellValue(fechaSalida != null
              ? formatearHora(fechaSalida)
              : 'No registrado'), // Hora de salida formateada
          TextCellValue(asistencia['direccion'] ?? 'No disponible'),
          TextCellValue(asistencia['dispositivo'] ?? 'No disponible'),
        ]);
      }
    });

    // Luego, exportar viajes en una hoja adicional para cada usuario
    viajesPorUsuario.forEach((alias, viajes) {
      // Crear una hoja específica para viajes si no existe
      String nombreHoja = '$alias - Viajes';
      Sheet sheetViajes = excel[nombreHoja];

      sheetViajes.appendRow([
        TextCellValue('Usuario'),
        TextCellValue('Lugar de Destino'),
        TextCellValue('Fecha de Viaje'),
        TextCellValue('Lugar de Retorno'),
        TextCellValue('Fecha de Retorno'),
        TextCellValue('Fecha de Creación'),
      ]);

      for (var viaje in viajes) {
        DateTime? fechaCreacion = viaje['fechaCreacion']?.toDate();

        sheetViajes.appendRow([
          TextCellValue(viaje['alias'] ?? ''),
          TextCellValue(viaje['Lugar de Destino'] ?? 'No disponible'),
          TextCellValue(viaje['fechaIda'] ?? 'No disponible'),
          TextCellValue(viaje['retorno'] ?? 'No disponible'),
          TextCellValue(viaje['fechaRegreso'] ?? 'No disponible'),
          TextCellValue(fechaCreacion != null
              ? formatearFecha(fechaCreacion)
              : 'No disponible'),
        ]);
      }
    });

    // Crear una hoja de resumen de viajes para todos los usuarios
    Sheet sheetResumenViajes = excel['Resumen de Viajes'];
    sheetResumenViajes.appendRow([
      TextCellValue('Usuario'),
      TextCellValue('Total de Viajes'),
      TextCellValue('Destinos'),
    ]);

    viajesPorUsuario.forEach((alias, viajes) {
      // Obtener destinos únicos
      Set<String> destinos = viajes
          .map((viaje) => viaje['destino'] as String?)
          .where((destino) => destino != null && destino.isNotEmpty)
          .cast<String>()
          .toSet();

      sheetResumenViajes.appendRow([
        TextCellValue(alias),
        TextCellValue(viajes.length.toString()),
        TextCellValue(destinos.join(', ')),
      ]);
    });

    final Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/asistencias_y_viajes_usuarios.xlsx';
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
        title: const Text('Tabla de Asistencias y Viajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await exportarAsistenciasDeUsuariosEspecificos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos exportados a Excel')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
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
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
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
                                    ? asistencia['entrada'].toDate().toString()
                                    : 'No registrado')),
                                DataCell(Text(asistencia['salida'] != null
                                    ? asistencia['salida'].toDate().toString()
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
                    ),
                    FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                      future: obtenerViajesDeUsuariosEspecificos(),
                      builder: (context, viajesSnapshot) {
                        if (!viajesSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        Map<String, List<Map<String, dynamic>>>
                            viajesPorUsuario = viajesSnapshot.data!;
                        List<Map<String, dynamic>> viajesUsuario =
                            viajesPorUsuario[usuario] ?? [];

                        if (viajesUsuario.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No hay viajes registrados'),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Viajes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Lugar de Destino')),
                                  DataColumn(label: Text('Fecha de Viaje')),
                                  DataColumn(label: Text('Lugar de Retorno')),
                                  DataColumn(label: Text('Fecha de Regreso')),
                                ],
                                rows: viajesUsuario.map((viaje) {
                                  return DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(
                                          viaje['destino'] ?? 'No disponible')),
                                      DataCell(Text(viaje['fechaIda'] ??
                                          'No disponible')),
                                      DataCell(Text(
                                          viaje['retorno'] ?? 'No disponible')),
                                      DataCell(Text(viaje['fechaRegreso'] ??
                                          'No disponible')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
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

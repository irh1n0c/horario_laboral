import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';

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

  Future<Map<String, dynamic>> obtenerAsistenciasYViajesDeUsuarios() async {
    Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario = {};
    Map<String, List<Map<String, dynamic>>> viajesPorUsuario = {};

    try {
      for (var uid in uids) {
        // Obtener información del documento principal del usuario para el alias
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(uid)
            .get();
        
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        String alias = userData?['alias'] ?? uid.substring(0, 5);

        // Obtener asistencias
        CollectionReference diasRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(uid)
            .collection('dias');

        QuerySnapshot diasSnapshot = await diasRef.get();

        List<Map<String, dynamic>> asistenciasUsuario = [];
        for (var diaDoc in diasSnapshot.docs) {
          Map<String, dynamic> data = diaDoc.data() as Map<String, dynamic>;
          data['alias'] = data['alias'] ?? alias;
          data['tipo'] = 'asistencia';
          asistenciasUsuario.add(data);
        }

        if (asistenciasUsuario.isNotEmpty) {
          asistenciasPorUsuario[alias] = asistenciasUsuario;
        }

        // Obtener viajes
        CollectionReference viajesRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(uid)
            .collection('viajes');

        QuerySnapshot viajesSnapshot = await viajesRef.get();

        List<Map<String, dynamic>> viajesUsuario = [];
        for (var viajeDoc in viajesSnapshot.docs) {
          Map<String, dynamic> data = viajeDoc.data() as Map<String, dynamic>;
          data['alias'] = data['alias'] ?? alias;
          data['id'] = viajeDoc.id;
          data['tipo'] = 'viaje';
          viajesUsuario.add(data);
        }

        if (viajesUsuario.isNotEmpty) {
          viajesPorUsuario[alias] = viajesUsuario;
        }
      }
    } catch (e) {
      debugPrint("Error al obtener datos: $e");
    }

    return {
      'asistencias': asistenciasPorUsuario,
      'viajes': viajesPorUsuario,
    };
  }

  Future<void> exportarDatosAExcel(Map<String, dynamic> datos) async {
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

    Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario = datos['asistencias'];
    Map<String, List<Map<String, dynamic>>> viajesPorUsuario = datos['viajes'];

    // Obtener lista combinada de todos los usuarios
    Set<String> todosLosUsuarios = {...asistenciasPorUsuario.keys, ...viajesPorUsuario.keys};

    for (String alias in todosLosUsuarios) {
      Sheet sheet = excel[alias];

      // Encabezados para la sección de asistencias
      sheet.appendRow([
        TextCellValue('REGISTRO DE ASISTENCIAS Y VIAJES'),
      ]);
      
      sheet.appendRow([
        TextCellValue('Tipo'),
        TextCellValue('Fecha'),
        TextCellValue('Hora Entrada'),
        TextCellValue('Hora Salida'),
        TextCellValue('Dirección'),
        TextCellValue('Dispositivo'),
        TextCellValue('Destino'),
        TextCellValue('Retorno'),
        TextCellValue('Fecha Regreso'),
      ]);

      // Agregar datos de asistencias
      List<Map<String, dynamic>> asistencias = asistenciasPorUsuario[alias] ?? [];
      for (var asistencia in asistencias) {
        DateTime? fechaEntrada = asistencia['entrada']?.toDate();
        DateTime? fechaSalida = asistencia['salida']?.toDate();

        sheet.appendRow([
          TextCellValue('Asistencia'),
          TextCellValue(formatearFecha(fechaEntrada)),
          TextCellValue(formatearHora(fechaEntrada)),
          TextCellValue(fechaSalida != null ? formatearHora(fechaSalida) : 'No registrado'),
          TextCellValue(asistencia['direccion'] ?? 'No disponible'),
          TextCellValue(asistencia['dispositivo'] ?? 'No disponible'),
          TextCellValue(''),  // Destino (vacío para asistencias)
          TextCellValue(''),  // Retorno (vacío para asistencias)
          TextCellValue(''),  // Fecha regreso (vacío para asistencias)
        ]);
      }

      // Agregar datos de viajes
      List<Map<String, dynamic>> viajes = viajesPorUsuario[alias] ?? [];
      for (var viaje in viajes) {
        // Convertir fechas de string a DateTime para viajes
        DateTime? fechaIda;
        DateTime? fechaRegreso;
        
        try {
          if (viaje['fechaIda'] != null) {
            List<String> partesFechaIda = viaje['fechaIda'].split('/');
            if (partesFechaIda.length == 3) {
              fechaIda = DateTime(
                int.parse(partesFechaIda[2]), 
                int.parse(partesFechaIda[1]), 
                int.parse(partesFechaIda[0])
              );
            }
          }
          
          if (viaje['fechaRegreso'] != null) {
            List<String> partesFechaRegreso = viaje['fechaRegreso'].split('/');
            if (partesFechaRegreso.length == 3) {
              fechaRegreso = DateTime(
                int.parse(partesFechaRegreso[2]), 
                int.parse(partesFechaRegreso[1]), 
                int.parse(partesFechaRegreso[0])
              );
            }
          }
        } catch (e) {
          debugPrint("Error al procesar fechas de viaje: $e");
        }

        sheet.appendRow([
          TextCellValue('Viaje'),
          TextCellValue(viaje['fechaIda'] ?? ''),  // Ya está formateada
          TextCellValue(''),  // Hora entrada (no aplica para viajes)
          TextCellValue(''),  // Hora salida (no aplica para viajes)
          TextCellValue(''),  // Dirección (no aplica para viajes)
          TextCellValue(''),  // Dispositivo (no aplica para viajes)
          TextCellValue(viaje['destino'] ?? ''),
          TextCellValue(viaje['retorno'] ?? ''),
          TextCellValue(viaje['fechaRegreso'] ?? ''),
        ]);
      }
    }

    final Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/asistencias_y_viajes.xlsx';
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
        title: const Text('Registro de Asistencias y Viajes'),
        backgroundColor: const Color(0xff021b79),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar a Excel',
            onPressed: () async {
              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generando Excel...')),
              );
              
              final datos = await obtenerAsistenciasYViajesDeUsuarios();
              await exportarDatosAExcel(datos);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos exportados exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: obtenerAsistenciasYViajesDeUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos de asistencias y viajes...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error al cargar datos: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Forzar recarga
                      (context as StatefulElement).markNeedsBuild();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || 
              (snapshot.data!['asistencias'].isEmpty && snapshot.data!['viajes'].isEmpty)) {
            return const Center(
              child: Text('No hay datos de asistencias ni viajes disponibles'),
            );
          }

          Map<String, List<Map<String, dynamic>>> asistenciasPorUsuario = 
              snapshot.data!['asistencias'];
          Map<String, List<Map<String, dynamic>>> viajesPorUsuario = 
              snapshot.data!['viajes'];
          
          // Combinar las listas de usuarios
          Set<String> todosLosUsuarios = {...asistenciasPorUsuario.keys, ...viajesPorUsuario.keys};
          List<String> usuariosOrdenados = todosLosUsuarios.toList()..sort();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: usuariosOrdenados.map((usuario) {
                List<Map<String, dynamic>> asistencias = asistenciasPorUsuario[usuario] ?? [];
                List<Map<String, dynamic>> viajes = viajesPorUsuario[usuario] ?? [];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  child: ExpansionTile(
                    title: Text(
                      usuario,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Asistencias: ${asistencias.length} | Viajes: ${viajes.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    children: [
                      // Mostrar asistencias
                      if (asistencias.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Asistencias',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  const Color(0xffeef2ff),
                                ),
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Fecha')),
                                  DataColumn(label: Text('Entrada')),
                                  DataColumn(label: Text('Salida')),
                                  DataColumn(label: Text('Dirección')),
                                  DataColumn(label: Text('Dispositivo')),
                                ],
                                rows: asistencias.map((asistencia) {
                                  DateTime? fechaEntrada = asistencia['entrada']?.toDate();
                                  DateTime? fechaSalida = asistencia['salida']?.toDate();
                                  
                                  String fechaFormateada = fechaEntrada != null
                                      ? DateFormat('dd/MM/yyyy').format(fechaEntrada)
                                      : 'No registrado';
                                  
                                  String horaEntrada = fechaEntrada != null
                                      ? DateFormat('hh:mm a').format(fechaEntrada)
                                      : 'No registrado';
                                  
                                  String horaSalida = fechaSalida != null
                                      ? DateFormat('hh:mm a').format(fechaSalida)
                                      : 'No registrado';
                                  
                                  return DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(fechaFormateada)),
                                      DataCell(Text(horaEntrada)),
                                      DataCell(Text(horaSalida)),
                                      DataCell(Text(asistencia['direccion'] ?? 'No disponible')),
                                      DataCell(Text(asistencia['dispositivo'] ?? 'No disponible')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      
                      // Mostrar viajes
                      if (viajes.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Viajes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  const Color(0xffe8fcff),
                                ),
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Destino')),
                                  DataColumn(label: Text('Fecha Ida')),
                                  DataColumn(label: Text('Retorno')),
                                  DataColumn(label: Text('Fecha Regreso')),
                                ],
                                rows: viajes.map((viaje) {
                                  return DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(viaje['destino'] ?? 'No disponible')),
                                      DataCell(Text(viaje['fechaIda'] ?? 'No disponible')),
                                      DataCell(Text(viaje['retorno'] ?? 'No disponible')),
                                      DataCell(Text(viaje['fechaRegreso'] ?? 'No disponible')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
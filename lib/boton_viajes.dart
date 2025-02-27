import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormularioViaje extends StatefulWidget {
  const FormularioViaje({super.key});

  @override
  _FormularioViajeState createState() => _FormularioViajeState();
}

class _FormularioViajeState extends State<FormularioViaje> {
  final TextEditingController destinoController = TextEditingController();
  final TextEditingController retornoController = TextEditingController();
  DateTime? fechaIda;
  DateTime? fechaRegreso;

  List<Map<String, dynamic>> viajes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarViajes();
  }

  // Cargar viajes desde Firestore
  Future<void> _cargarViajes() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(user.uid)
            .collection('viajes')
            .orderBy('fechaCreacion', descending: true)
            .get();

        List<Map<String, dynamic>> viajesCargados = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          viajesCargados.add({
            'id': doc.id,
            'Destino': data['destino'],
            'Fecha de Ida': data['fechaIda'],
            'Retorno': data['retorno'],
            'Fecha de Regreso': data['fechaRegreso'],
          });
        }

        setState(() {
          viajes = viajesCargados;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar viajes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esIda) async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esIda) {
          fechaIda = fechaSeleccionada;
        } else {
          fechaRegreso = fechaSeleccionada;
        }
      });
    }
  }

  Future<void> _guardarViaje() async {
    if (destinoController.text.isNotEmpty &&
        retornoController.text.isNotEmpty &&
        fechaIda != null &&
        fechaRegreso != null) {
      setState(() {
        isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String fechaIdaFormateada =
              DateFormat('dd/MM/yyyy').format(fechaIda!);
          String fechaRegresoFormateada =
              DateFormat('dd/MM/yyyy').format(fechaRegreso!);

          // Crear documento en la colección de viajes
          DocumentReference viajeRef = await FirebaseFirestore.instance
              .collection('registros_tiempo')
              .doc(user.uid)
              .collection('viajes')
              .add({
            'destino': destinoController.text,
            'fechaIda': fechaIdaFormateada,
            'retorno': retornoController.text,
            'fechaRegreso': fechaRegresoFormateada,
            'fechaCreacion': FieldValue.serverTimestamp(),
            'alias': user.email?.split('@')[0] ?? 'usuario',
          });

          // También actualizar el estado del usuario para indicar que está de viaje
          // Esto afectará cómo se muestran las asistencias
          await FirebaseFirestore.instance
              .collection('registros_tiempo')
              .doc(user.uid)
              .set({
            'estadoActual': 'viaje',
            'viajeActual': viajeRef.id,
            'fechaInicioViaje': Timestamp.fromDate(fechaIda!),
            'fechaFinViaje': Timestamp.fromDate(fechaRegreso!),
            'destinoViaje': destinoController.text,
            'retornoViaje': retornoController.text,
          }, SetOptions(merge: true));

          // Actualizar la lista local
          setState(() {
            viajes.add({
              'id': viajeRef.id,
              'Destino': destinoController.text,
              'Fecha de Ida': fechaIdaFormateada,
              'Retorno': retornoController.text,
              'Fecha de Regreso': fechaRegresoFormateada,
            });

            // Limpiar campos después de guardar
            destinoController.clear();
            retornoController.clear();
            fechaIda = null;
            fechaRegreso = null;
            isLoading = false;
          });

          // Mostrar mensaje de éxito
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Viaje registrado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error al guardar viaje: $e');
        setState(() {
          isLoading = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar viaje: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Mostrar mensaje de error si faltan campos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Viaje'),
        backgroundColor: const Color(0xff021b79),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Campos de formulario
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: destinoController,
                        decoration: const InputDecoration(
                          labelText: '¿A dónde viaja?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _seleccionarFecha(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            fechaIda == null
                                ? 'Fecha de viaje'
                                : DateFormat('dd/MM/yyyy').format(fechaIda!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: retornoController,
                        decoration: const InputDecoration(
                          labelText: '¿A dónde retorna?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _seleccionarFecha(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            fechaRegreso == null
                                ? 'Fecha de regreso'
                                : DateFormat('dd/MM/yyyy')
                                    .format(fechaRegreso!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : _guardarViaje,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff021b79),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar viaje'),
                ),
                const SizedBox(height: 20),

                // Título de la tabla
                const Text(
                  'Historial de viajes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),

                // Tabla de viajes
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viajes.isEmpty
                          ? const Center(
                              child: Text('No hay viajes registrados'))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    border: TableBorder.all(color: Colors.grey),
                                    columns: const [
                                      DataColumn(label: Text('Destino')),
                                      DataColumn(label: Text('Fecha de Ida')),
                                      DataColumn(label: Text('Retorno')),
                                      DataColumn(
                                          label: Text('Fecha de Regreso')),
                                    ],
                                    rows: viajes
                                        .map((viaje) => DataRow(cells: [
                                              DataCell(
                                                  Text(viaje['Destino'] ?? '')),
                                              DataCell(Text(
                                                  viaje['Fecha de Ida'] ?? '')),
                                              DataCell(
                                                  Text(viaje['Retorno'] ?? '')),
                                              DataCell(Text(
                                                  viaje['Fecha de Regreso'] ??
                                                      '')),
                                            ]))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),

          // Overlay de carga
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

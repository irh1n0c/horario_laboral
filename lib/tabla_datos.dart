import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TablaAsistenciasPage1 extends StatelessWidget {
  const TablaAsistenciasPage1({super.key});

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
            child: TablaAsistencias1(asistencias: asistencias),
          );
        },
      ),
    );
  }
}

class TablaAsistencias1 extends StatelessWidget {
  final List<Map<String, dynamic>> asistencias;

  const TablaAsistencias1({required this.asistencias, super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('Fecha')),
        DataColumn(label: Text('Alias')),
        DataColumn(label: Text('Entrada')),
        DataColumn(label: Text('Salida')),
      ],
      rows: asistencias.map((asistencia) {
        print(asistencia);
        return DataRow(
          cells: <DataCell>[
            DataCell(Text(asistencia['fecha'] ?? '')),
            DataCell(Text(asistencia['alias'] ?? '')),
            DataCell(Text(asistencia['entrada']?.toDate().toString() ?? '')),
            DataCell(Text(asistencia['salida'] != null
                ? asistencia['salida'].toDate().toString()
                : 'No registrado')),
          ],
        );
      }).toList(),
    );
  }
}

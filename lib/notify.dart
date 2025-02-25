import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:isolate';
import 'dart:ui';

// Constantes
const String NOTIFICATION_PORT_NAME = 'notification_send_port';
const String PREFS_NOTIFICATION_HOUR = 'notification_hour';
const String PREFS_NOTIFICATION_MINUTE = 'notification_minute';
const String PREFS_CUSTOM_SOUND = 'custom_sound';

// Callback para el AlarmManager
@pragma('vm:entry-point')
void notificationCallback() async {
  final SendPort? sendPort = IsolateNameServer.lookupPortByName(NOTIFICATION_PORT_NAME);
  if (sendPort != null) {
    sendPort.send('SHOW_NOTIFICATION');
  } else {
    _showNotificationDirectly();
  }
}

// Mostrar la notificación directamente desde un isolate
Future<void> _showNotificationDirectly() async {
  final prefs = await SharedPreferences.getInstance();
  final customSoundName = prefs.getString(PREFS_CUSTOM_SOUND) ?? 'notification_sound';
  
  print('📢 Usando sonido en isolate: $customSoundName');

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Recrear el canal cada vez antes de mostrar la notificación
  final androidImplementation = 
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidImplementation != null) {
    await androidImplementation.deleteNotificationChannel('daily_channel_v1a');
    
    await androidImplementation.createNotificationChannel(AndroidNotificationChannel(
      'daily_channel_v1a',
      'Notificaciones Diarias',
      description: 'Canal para notificaciones diarias',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound(customSoundName),
      playSound: true,
    ));
  }

  final androidDetails = AndroidNotificationDetails(
    'daily_channel_v1a',
    'Notificaciones Diarias',
    channelDescription: 'Canal para notificaciones diarias',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(customSoundName),
    icon: '@mipmap/ic_launcher',
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
  );

  final platformDetails = NotificationDetails(android: androidDetails);
  
  await flutterLocalNotificationsPlugin.show(
    0,
    "Recordatorio Diario",
    "A marcar tu asistencia joder.",
    platformDetails,
  );

  // Reprogramar la alarma
  final hourPref = prefs.getInt(PREFS_NOTIFICATION_HOUR) ?? 12;
  final minutePref = prefs.getInt(PREFS_NOTIFICATION_MINUTE) ?? 55;
  await NotificationService().scheduleDailyAlarm(hourPref, minutePref);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  final ReceivePort port = ReceivePort();

  Future<void> init() async {
    try {
      const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid);
      
      await notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('Notificación seleccionada: ${details.payload}');
        },
      );

      await _requestPermissions();
      
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Lima'));
      
      await AndroidAlarmManager.initialize();
      IsolateNameServer.registerPortWithName(port.sendPort, NOTIFICATION_PORT_NAME);

      port.listen((message) async {
        if (message == 'SHOW_NOTIFICATION') {
          await showNotification(title: "Recordatorio Diario", body: "A marcar tu asistencia joder.");
          final prefs = await SharedPreferences.getInstance();
          final hour = prefs.getInt(PREFS_NOTIFICATION_HOUR) ?? 12;
          final minute = prefs.getInt(PREFS_NOTIFICATION_MINUTE) ?? 55;
          await scheduleDailyAlarm(hour, minute);
        }
      });

      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt(PREFS_NOTIFICATION_HOUR);
      final minute = prefs.getInt(PREFS_NOTIFICATION_MINUTE);
      if (hour != null && minute != null) {
        await scheduleDailyAlarm(hour, minute);
      }

      print('✅ Servicio de notificaciones inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar notificaciones: $e');
    }
  }
  
  Future<void> _requestPermissions() async {
    final androidImplementation =
        notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }
  
  Future<bool> setCustomSound(String soundName) async {
    try {
      if (soundName.isEmpty) {
        print('❌ Nombre de sonido vacío');
        return false;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PREFS_CUSTOM_SOUND, soundName);
      
      // Recrear el canal de notificaciones
      final androidImplementation = 
          notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.deleteNotificationChannel('daily_channel_v1a');
        
        await androidImplementation.createNotificationChannel(AndroidNotificationChannel(
          'daily_channel_v1a',
          'Notificaciones Diarias',
          description: 'Canal para notificaciones diarias',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(soundName),
          playSound: true,
        ));
      }
      
      print('✅ Sonido personalizado configurado: $soundName');
      return true;
    } catch (e) {
      print('❌ Error al configurar sonido personalizado: $e');
      return false;
    }
  }
  
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Siempre leer de SharedPreferences para asegurar el valor más actualizado
      final prefs = await SharedPreferences.getInstance();
      final soundName = prefs.getString(PREFS_CUSTOM_SOUND) ?? 'notification_sound';
      
      print('📢 Usando sonido en showNotification: $soundName');
      
      // CORRECCIÓN: Recrear el canal antes de mostrar la notificación
      final androidImplementation = 
          notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.deleteNotificationChannel('daily_channel_v1a');
        
        await androidImplementation.createNotificationChannel(AndroidNotificationChannel(
          'daily_channel_v1a',
          'Notificaciones Diarias',
          description: 'Canal para notificaciones diarias',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(soundName),
          playSound: true,
        ));
      }
      
      final androidDetails = AndroidNotificationDetails(
        'daily_channel_v1a',
        'Notificaciones Diarias',
        channelDescription: 'Canal para notificaciones diarias',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundName),
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      );

      final platformDetails = NotificationDetails(android: androidDetails);

      await notificationsPlugin.show(0, title, body, platformDetails, payload: payload);
      print('✅ Notificación mostrada correctamente');
    } catch (e) {
      print('❌ Error al mostrar notificación: $e');
    }
  }

  Future<bool> scheduleDailyAlarm(int hour, int minute) async {
    try {
      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      print('⏰ Programando alarma para: ${scheduledTime.toString()}');

      await AndroidAlarmManager.cancel(1);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(PREFS_NOTIFICATION_HOUR, hour);
      await prefs.setInt(PREFS_NOTIFICATION_MINUTE, minute);

      final success = await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        1,
        notificationCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
        alarmClock: true,
      );

      if (success) {
        await showNotification(
          title: "Alarma Configurada",
          body: "Recibirás notificaciones diarias a las $hour:$minute",
        );
      } else {
        print('❌ Error al programar la alarma');
      }

      return success;
    } catch (e) {
      print('❌ Error en scheduleDailyAlarm: $e');
      return false;
    }
  }
}
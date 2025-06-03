// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:laris_jaya_gas/models/notifikasi.dart';
// import 'package:laris_jaya_gas/models/notifikasi_model.dart';

// // Service to manage local notifications
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     const initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initializationSettingsIOS = DarwinInitializationSettings();
//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     await _notificationsPlugin.initialize(initializationSettings);
//   }

//   static Future<void> scheduleNotification(Notifikasi notifikasi) async {
//     await _notificationsPlugin.zonedSchedule(
//       notifikasi.idNotifikasi.hashCode,
//       notifikasi.template?.judul ?? 'Pengingat Pembayaran',
//       notifikasi.template?.isi ?? 'Tagihan Anda akan jatuh tempo.',
//       notifikasi.tanggalTerjadwal,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'payment_channel',
//           'Payment Reminders',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }

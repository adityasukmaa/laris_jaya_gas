import 'package:intl/intl.dart';

String formatRupiah(double amount) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  return formatter.format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

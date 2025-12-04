import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {

  // Format tanggal ke bentuk tanggal
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format waktu ke bentuk waktu
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Ubah timestamp yang di firebase ke datetime
  static DateTime fromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  // Ubah datetime yang di firebase ke timestamp
  static Timestamp toTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  /// Gabungkan tanggal & waktu menjadi 1 DateTime
  static DateTime combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/models/url_pdf.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/view/ticket_storage_page.dart';
import 'package:surf_flutter_study_jam_2023/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TicketAdapter());
  await Hive.openBox<Ticket>('ticket');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: const TicketStoragePage(),
    );
  }
}

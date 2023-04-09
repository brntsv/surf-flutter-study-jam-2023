import 'package:hive/hive.dart';

part 'url_pdf.g.dart';

@HiveType(typeId: 0)
class Ticket extends HiveObject {
  Ticket({
    required this.url,
  });
  
  @HiveField(0)
  final String url;
}

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/models/url_pdf.dart';

import 'package:surf_flutter_study_jam_2023/themes/theme.dart';

/// Экран “Хранения билетов”.
class TicketStoragePage extends StatefulWidget {
  const TicketStoragePage({Key? key}) : super(key: key);

  @override
  State<TicketStoragePage> createState() => _TicketStoragePageState();
}

class _TicketStoragePageState extends State<TicketStoragePage> {
  double progress = 0;
  final StreamController<double> streamController =
      StreamController<double>.broadcast();
  final TextEditingController controllerUrl = TextEditingController();

  List<StreamController<double>> streams = [];

  void updateProgress(int done, int total) {
    progress = done / total;

    debugPrint('${(progress * 100).toStringAsFixed(0)} %');
    streamController.sink.add(progress);
  }

  Future openFile({required String url}) async {
    final name = url.split('/').last;
    final file = await downloadFile(url, name);
    if (file == null) return;
    OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url, String fileName) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File('${appStorage.path}/$fileName');
    try {
      final response = await Dio().get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return file;
    } catch (e) {
      return null;
    }
  }

  bool hasValidUrl(String value) {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?(\.pdf)';
    RegExp regExp = RegExp(pattern);
    if (regExp.hasMatch(value)) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    controllerUrl.dispose();
    streamController.close();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<Ticket>('ticket');

    return Scaffold(
      appBar: AppBar(title: const Text('Хранение билетов')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Ticket>('ticket').listenable(),
        builder: (context, Box<Ticket> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('Здесь пока ничего нет'),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, builder) => const SizedBox(height: 15),
            itemCount: box.values.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, i) {
              double percent = 0;
              return ListTile(
                title: Text(box.getAt(i)!.url.split('/').last),
                subtitle: StreamBuilder(
                    initialData: percent,
                    stream: streamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        percent = snapshot.data!.toDouble();
                      }
                      return LinearProgressIndicator(value: percent);
                    }),
                leading: const Icon(Icons.airplane_ticket_outlined),
                trailing: IconButton(
                    onPressed: () {
                      openFile(url: box.getAt(i)!.url);
                    },
                    icon: const Icon(Icons.cloud_download_outlined, color: AppColors.primary)),
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 70,
        child: FloatingActionButton.extended(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          label: const Text('Добавить', style: AppTextStyle.floatingButton),
          onPressed: () => showModalBottomSheet(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) {
                final formKey = GlobalKey<FormState>();
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: formKey,
                          child: TextFormField(
                            controller: controllerUrl,
                            style: AppTextStyle.titleAppBar,
                            autofocus: true,
                            validator: (value) {
                              if (value != null && !hasValidUrl(value)) {
                                return 'Введите ссылку в верном формате';
                              } else if (value == null) {
                                return 'Введите ссылку';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              if (formKey.currentState!.validate()) {
                                box.add(Ticket(url: controllerUrl.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Билет добавлен')),
                                );
                                return Navigator.pop(context);
                              }
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                    width: 2,
                                  )),
                              labelText: 'Введите Url',
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                box.add(Ticket(url: controllerUrl.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Билет добавлен')),
                                );
                                return Navigator.pop(context);
                              }
                            },
                            child: const Text('Добавить'))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

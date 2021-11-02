import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/mp/chat_mp.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class IRDetail extends StatefulWidget {
  final Map data;

  IRDetail({required this.data});

  @override
  _IRDetailState createState() => _IRDetailState();
}

class _IRDetailState extends State<IRDetail>  with SingleTickerProviderStateMixin{
  ReceivePort receivePort = ReceivePort();
  int progress = 0;
  void setUnreadToRead()async{
    final _pro = Provider.of<GeneralData>(context, listen: false);
    http.Response response = await http.post(Uri.parse(base_url + "mp-operations/read-incident-report/${widget.data['id']}/"));
    if(response.statusCode < 206){
      _pro.getrequestNotification();
    }else{

    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUnreadToRead();
    downFunc();
  }

  downFunc() {
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'downloadingfile');
    receivePort.listen((message) {
      setState(() {
        progress = message;
      });
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static downloadCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName('downloadingfile');
    sendPort!.send(progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Incident Report",
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatMP(
                conId: widget.data['sender']['system_id_for_user'],
                con: widget.data['sender'],
              ),
            ),
          );
        },
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Sent from:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "${widget.data['sender']['full_name']}",
              style: bigFont
            ),
            Text(
              "${widget.data['sender']['email']}",
              style: bigFont,
            ),
            Text(
              "${widget.data['sender']['contact']}",
              style: bigFont,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Message:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(
              height: 5,
            ),
            HtmlWidget(
              "${widget.data['message']}",
              textStyle: mediumFont,
            ),
            const SizedBox(
              height: 20,
            ),
            if (widget.data['attached_file'] != null)
              const Text(
                "Attachment:",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            if (widget.data['attached_file'] != null)
              const SizedBox(
                height: 5,
              ),
            if (widget.data['attached_file'] != null)
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(appColor)),
                  onPressed: () async {
                    final status = await Permission.storage.request();
                    if (status.isGranted) {
                      final baseStorage = await getExternalStorageDirectory();

                      final id = await FlutterDownloader.enqueue(
                          url: '$base_url2${widget.data['attached_file']}',
                          savedDir: baseStorage!.path,
                          fileName: widget.data['attached_file']
                              .toString()
                              .split('/')
                              .last);
                    }
                  },
                  child: Container(
                    width: 90,
                    child: Row(
                      children: const [
                        Text(
                          "Download",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.download,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/auth/signup_const.dart';
import 'package:omanbapa/screens/mp/ic_detail.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;

class IncidenReportMP extends StatefulWidget {
  const IncidenReportMP({Key? key}) : super(key: key);

  @override
  _IncidenReportMPState createState() => _IncidenReportMPState();
}

class _IncidenReportMPState extends State<IncidenReportMP> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void setInitData() {
    final _pro = Provider.of<GeneralData>(context, listen: false);
    setState(() {
      _pro.getrequestNotification();
    });
  }

  void _onRefresh() async {
    setState(() {
      setInitData();
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);

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
        body: _pro.requestnotifications == null
            ? const Center(
                child: MyProgressIndicator(),
              )
            : SmartRefresher(
                enablePullDown: true,
                header: const WaterDropMaterialHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: _pro.requestnotifications!['request_form'].length > 0
                    ? ListView.builder(
                        itemCount: _pro
                            .requestnotifications!['incident_reports'].length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => IRDetail(
                                        data: _pro.requestnotifications![
                                            'incident_reports'][index]))),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(base_url2 +
                                  _pro.requestnotifications!['incident_reports']
                                      [index]['sender']['profile_picture']),
                            ),
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -2),
                            title: Text(
                              "${_pro.requestnotifications!['incident_reports'][index]['sender']['full_name']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              timeago.format(
                                      DateTime.parse(_pro.requestnotifications![
                                          'incident_reports'][index]['date']),
                                      locale: 'en_short') +
                                  (timeago.format(
                                              DateTime.parse(
                                                  _pro.requestnotifications![
                                                          'incident_reports']
                                                      [index]['date']),
                                              locale: 'en_short') ==
                                          'now'
                                      ? ""
                                      : " ago"),
                              style: TextStyle(fontSize: 10),
                            ),
                            trailing:
                                _pro.requestnotifications!['incident_reports']
                                        [index]['read']
                                    ? const Icon(
                                        Icons.done_all,
                                        color: Colors.green,
                                      )
                                    : const Card(
                                        elevation: 5,
                                        color: Colors.grey,
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            "unread",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                          );
                        })
                    : const Center(
                        child: Text("No request form"),
                      ),
              ));
  }
}

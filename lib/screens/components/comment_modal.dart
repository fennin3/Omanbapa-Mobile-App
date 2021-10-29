import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/utils.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class Commentmodal extends StatefulWidget {
  final List comments;
  final id;

  Commentmodal({required this.comments, required this.id});

  @override
  _CommentmodalState createState() => _CommentmodalState();
}

class _CommentmodalState extends State<Commentmodal> {
  List _comments = [];
  final TextEditingController _text = TextEditingController();

  setData() {
    setState(() {
      _comments = [];
      _comments = widget.comments;
    });
  }

  void comment(text) async {
    final userId = await UserLocalData.userID();
    final _data = {
      "user_id": userId,
      "project_id": widget.id.toString(),
      "comment_body": text
    };
    http.Response response = await http.put(
        Uri.parse(base_url + "constituent-operations/comment-on-post/"),
        body: _data);
    if (response.statusCode < 206) {
    } else {
      MyUtils.snack(context, "No Internet", 1);
    }
  }

  addComment(String text, DateTime _date, name, String profilePic) {
    setState(() {
      _comments.add({
        "text": text,
        "comment_from": {"profile_picture": profilePic, "full_name": name},
        "date_posted": _date.toString()
      });
    });
    comment(text);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _text.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context);
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
          "Comments",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          padding: const EdgeInsets.only(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_comments.isEmpty)
                        Center(
                            child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.28,
                            ),
                            Image.asset(
                              "assets/images/nc.png",
                              height: 150,
                              width: 150,
                            ),
                            const Text(
                              "No Comments",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ))
                      else
                        for (var comment in _comments)
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 15.0, left: 15.0, top: 6, bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundImage: NetworkImage(base_url2 +
                                      comment['comment_from']
                                          ['profile_picture']),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${comment['comment_from']['full_name']}",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "${comment['text']}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  timeago.format(
                                      DateTime.parse(comment['date_posted']),
                                      locale: 'en_short'),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              )),
              Container(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _text,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        //Normal textInputField will be displayed
                        maxLines: 5,
                        style: const TextStyle(fontSize: 13),
                        cursorColor: Colors.black38,
                        decoration: const InputDecoration(
                          labelText: "Type your comment here...",
                          labelStyle: TextStyle(color: Colors.black38),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    InkWell(
                        onTap: () {
                          if (_text.text.isNotEmpty) {
                            addComment(
                              _text.text,
                              DateTime.now(),
                              _pro.userData!['full_name'],
                              _pro.userData!['profile_picture'],
                            );
                          }
                          _text.clear();
                        },
                        child: Icon(Icons.send))
                  ],
                ),
                color: Colors.black12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

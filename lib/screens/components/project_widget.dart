import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:http/http.dart' as http;
import 'package:omanbapa/local_data/user_info.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/components/comment_modal.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

class ProjectWidget extends StatefulWidget {
  const ProjectWidget({
    Key? key,
    required this.project,
    required this.id,
  }) : super(key: key);

  final project;
  final id;

  @override
  State<ProjectWidget> createState() => _ProjectWidgetState();
}

class _ProjectWidgetState extends State<ProjectWidget> {
  int likes = 0;
  int comments = 0;
  bool liked = false;

  void likeUnlikeProject() async {
    final userId = await UserLocalData.userID();
    http.Response response = await http.put(Uri.parse(base_url +
        "constituent-operations/like-project/$userId/${widget.project['id']}/"));

    if (response.statusCode < 206) {
    } else {
      const snackBar = SnackBar(
        content: Text(
          "No Internet",
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void setData() {
    setState(() {
      likes = widget.project['likes'].length;
      comments = widget.project['comments'].length;
      if (widget.project['likes'].contains(widget.id)) {
        liked = true;
      }
    });
  }

  void toggleLike(val) {
    likeUnlikeProject();
    if (val) {
      likes--;
    } else {
      likes++;
    }
    setState(() {
      liked = !liked;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context,listen: true);
    comments = widget.project['comments'].length;
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundImage: NetworkImage(
                      base_url2 + widget.project!['mp']['profile_picture']),
                ),
                const SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.project['name']}",
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "${widget.project['place']}",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                Text(
                  timeago.format(DateTime.parse(widget.project['date_posted']),
                      locale: 'en_short') + " ago",
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 6),
            child: Text(
              "${widget.project['description']}",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 12),
            ),
          ),
          if (widget.project['media'] != null)
            const SizedBox(
              height: 7,
            ),
          if (widget.project['media'] != null)
            Container(
              height: 240,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.2),
              child: Image.network(
                base_url2 + widget.project['media'],
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$likes \tLikes \t\t $comments \tComments",
                  style: TextStyle(fontSize: 11),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15.0, left: 15.0, top: 6),
            child: Divider(
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => toggleLike(liked),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: !liked ? Colors.black38 : appColor,
                        size: liked ? 25 : 20,
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        "Like",
                        style: TextStyle(
                            color: !liked ? Colors.black54 : appColor,
                            fontSize: liked ? 13 : 12),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Commentmodal(
                                comments: widget.project['comments'],
                            id: widget.project['id'],
                              ))).then((value) => _pro.getProjects()),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.insert_comment_outlined,
                        color: Colors.black38,
                        size: 20,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        "Comment",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}

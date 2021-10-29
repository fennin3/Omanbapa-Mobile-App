import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:omanbapa/screens/components/post_widget.dart';
import 'package:omanbapa/screens/components/project_widget.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
    required GeneralData pro,
  }) : _pro = pro, super(key: key);

  final GeneralData _pro;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          child: Column(
            children: [
              if(_pro.projects!.isEmpty)
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3,),
                    Image.asset("assets/images/post.png", height: 50,),
                    const Text("No post", style: TextStyle(fontWeight: FontWeight.w600),)
                  ],
                )
              else
                for (var project in _pro.projects!)
                  if (!project['is_post'])
                    ProjectWidget(
                      project: project,
                      id: _pro.userData!['id'],
                    )
                  else
                    PostWidget(project: project, id: _pro.userData!['id'])
            ],
          ),
        );


  }
}



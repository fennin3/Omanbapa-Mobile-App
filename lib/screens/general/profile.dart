import 'package:flutter/material.dart';
import 'package:omanbapa/constant.dart';
import 'package:omanbapa/provider/provider_class.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final _pro = Provider.of<GeneralData>(context, listen: true);
    final size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        base_url2 + _pro.userData!['profile_picture']),
                  ),
                  const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Card(
                        color: appColor,
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ))
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

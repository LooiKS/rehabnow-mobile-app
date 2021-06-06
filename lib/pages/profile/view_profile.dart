import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/rehabnow_scaffold.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/main.dart';
import 'package:rehabnow_app/models/user.model.dart';
import 'package:rehabnow_app/pages/profile/edit_profile.dart';
import 'package:rehabnow_app/services/generic_http.dart';
import 'package:rehabnow_app/services/profile.http.service.dart';
import 'package:intl/intl.dart' show DateFormat;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late User user;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    getProfile().then((value) => setState(() => user = value));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(profile.length);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getProfile(),
          builder: (context, AsyncSnapshot<User> snapshot) {
            print("p = ${snapshot.data?.photo}");
            // if (snapshot.connectionState == ConnectionState.waiting)
            //   Future.delayed(Duration.zero, () => showLoadingDialog(context));
            return Skeleton(
              lines: 10,
              isLoading: snapshot.connectionState != ConnectionState.done,
              child: snapshot.hasData
                  ? Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Card(
                                margin: EdgeInsets.only(
                                    top: 70, left: 10, right: 10),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 50, left: 20, right: 20, bottom: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "${snapshot.data?.firstName ?? ''} ${snapshot.data?.lastName ?? ''}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 48.0),
                                            child: Text("Email"),
                                          ),
                                          Text(
                                            snapshot.data?.email ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text("Phone Num"),
                                          ),
                                          Text(
                                            "${snapshot.data?.phoneNum ?? ''}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey,
                                    child: Image(
                                      loadingBuilder:
                                          (context, child, progress) =>
                                              progress == null
                                                  ? child
                                                  : CircularProgressIndicator(
                                                      value: progress
                                                                  .expectedTotalBytes ==
                                                              null
                                                          ? null
                                                          : progress
                                                                  .cumulativeBytesLoaded /
                                                              progress
                                                                  .expectedTotalBytes!,
                                                    ),
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 20,
                                          ),
                                          child: Text(
                                            'Image not found, please set one.',
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      },
                                      image: NetworkImage(
                                          "$MEDIA_URL/${snapshot.data?.photo}"),
                                      width: 100,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                              child: Column(
                                  children: profile(snapshot.data!)
                                      .map<Widget>(
                                        (e) => ListTile(
                                          title: Text(e["name"]!),
                                          trailing: Container(
                                              width: 200,
                                              child: Text(
                                                e["value"]!,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ),
                                      )
                                      .toList())),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton.icon(
                              onPressed: () => {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) =>
                                            ProfileEdit(user: snapshot.data!)))
                              },
                              icon: Icon(Icons.edit),
                              label: Text("Edit Profile"),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, String>> profile(User user) => [
        {"name": "IC Num", "value": "${user.icPassport ?? ''}"},
        {"name": "Gender", "value": "${user.gender ?? ''}"},
        {
          "name": "DOB", // Map<String, String>
          "value":
              "${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(user.dob!))}" // Map<String, String>
        },
        {"name": "Nationality", "value": "${user.fullNationality ?? ''}"},
        {
          "name": "Address",
          "value":
              "${user.address ?? ''}, \r\n${user.city ?? ''},\r\n${user.fullState ?? ''}, ${user.fullCountry ?? ''}"
        },
      ];
}

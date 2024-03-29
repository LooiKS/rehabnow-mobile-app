import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/skeleton.dart';
import 'package:rehabnow_app/constants/routes.constant.dart';
import 'package:rehabnow_app/models/user.model.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Profile"),
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(20, 10))),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: getProfile(),
          builder: (context, AsyncSnapshot<User> snapshot) {
            return Skeleton(
              lines: 10,
              isLoading: snapshot.connectionState != ConnectionState.done,
              child: snapshot.hasData
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Card(
                              margin:
                                  EdgeInsets.only(top: 70, left: 10, right: 10),
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
                                        Container(
                                          width: 100,
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
                                        Container(
                                          width: 100,
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
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(children: [
                            ...profile(snapshot.data!)
                                .map<Widget>(
                                  (e) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e["name"]!,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Container(
                                          width: 200,
                                          child: Text(
                                            e["value"]!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList()
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: ElevatedButton.icon(
                            onPressed: () => {
                              Navigator.of(context).pushNamed(
                                  RoutesConstant.EDIT_PROFILE,
                                  arguments: {"user": snapshot.data!})
                            },
                            icon: Icon(Icons.edit),
                            label: Text("Edit Profile"),
                          ),
                        )
                      ],
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
          "name": "DOB",
          "value":
              "${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(user.dob!))}"
        },
        {"name": "Nationality", "value": "${user.fullNationality ?? ''}"},
        {
          "name": "Address",
          "value":
              "${user.address ?? ''}, \r\n${user.city ?? ''},\r\n${user.fullState ?? ''}, ${user.fullCountry ?? ''}"
        },
      ];
}

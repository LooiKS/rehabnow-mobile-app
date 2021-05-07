import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rehabnow_app/components/rehabnow_scaffold.dart';
import 'package:rehabnow_app/pages/profile/edit_profile.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(profile.length);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: RehabnowAppBar(
        title: "Profile",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Image.network(
            //   "http://10.0.2.2:8000/media/profile-images/R0000051-1618845638435.png",
            //   height: 200,
            // ),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Card(
                  margin: EdgeInsets.only(top: 70),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 50, left: 20, right: 20, bottom: 20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "John Doe 001",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 48.0),
                              child: Text("Email"),
                            ),
                            Text(
                              "R0000001@rehabnow.com",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text("Phone Num"),
                            ),
                            Text(
                              "01111111111",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: Image(
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : Image.asset('assets/images/loading.gif'),
                      image: NetworkImage(
                          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                      width: 100,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
                child: Column(
                    children: profile
                        .map<Widget>(
                          (e) => ListTile(
                            title: Text(e["name"]),
                            trailing: Container(
                                width: 200,
                                child: Text(
                                  e["value"],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                          ),
                        )
                        .toList())),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                onPressed: () => {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) => ProfileEdit()))
                },
                icon: Icon(Icons.edit),
                label: Text("Edit Profile"),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> profile = [
    {"name": "IC Num", "value": "00000000000"},
    {"name": "Gender", "value": "Gender"},
    {
      "name": "DOB", // Map<String, String>
      "value": "01-01-1990" // Map<String, String>
    },
    {"name": "Nationality", "value": "Malaysian"},
    {
      "name": "Address",
      "value":
          "20, Lorong Cempeda 1, \nTaman Universiti,81310 Skudai, Johor,Malaysia."
    },
  ];
}

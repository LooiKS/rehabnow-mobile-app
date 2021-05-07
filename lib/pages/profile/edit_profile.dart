import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:rehabnow_app/components/rehabnow_scaffold.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  File image;

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
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: RehabnowAppBar(
          title: "Edit Profile",
          actions: <Widget>[
            TextButton(
                onPressed: () => {},
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Card(
                        margin: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10, top: 50),
                        child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Personal Info",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 25)),
                                  EditProfileTextInputContainer(
                                    labelText: "First Name",
                                  ),
                                  EditProfileTextInputContainer(
                                    labelText: "Last Name",
                                  ),
                                  EditProfileTextInputContainer(
                                    labelText: "Phone Number",
                                    keyboardType: TextInputType.number,
                                  ),
                                  EditProfileTextInputContainer(
                                    labelText: "IC Number",
                                  ),
                                  EditProfileDropdownButtonFormFieldContainer(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("Male"),
                                        value: "Male",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Female"),
                                        value: "Female",
                                      )
                                    ],
                                    labelText: "Gender",
                                  ),
                                  Container(
                                      margin:
                                          EdgeInsets.only(top: 8, bottom: 8),
                                      child: DateTimeField(
                                        decoration: InputDecoration(
                                            labelText: "Date of Birth",
                                            suffixIcon:
                                                Icon(Icons.calendar_today),
                                            contentPadding: EdgeInsets.only(
                                                left: 8, right: 8),
                                            border: OutlineInputBorder()),
                                        format: DateFormat("dd/MM/yyyy"),
                                        onShowPicker: (e, w) => showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.utc(1900),
                                          lastDate: DateTime.now(),
                                        ),
                                      )),
                                  EditProfileDropdownButtonFormFieldContainer(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("MY"),
                                        value: "MY",
                                      )
                                    ],
                                    labelText: "Nationality",
                                  )
                                ]))),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Stack(
                        children: [
                          Image(
                            image: image == null
                                ? NetworkImage(
                                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg')
                                : FileImage(image),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          TextButton(
                            clipBehavior: Clip.hardEdge,
                            onPressed: () async {
                              ImagePicker _picker = ImagePicker();
                              PickedFile file = await _picker.getImage(
                                  source: ImageSource.gallery);
                              if (file != null) {
                                setState(() => image = File(file.path));
                              }
                            },
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.all(0))),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.3)),
                              child: Text(
                                "Change Photo",
                                style: TextStyle(color: Colors.white),
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Card(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Residential",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              child: TextFormField(
                                minLines: 2,
                                maxLines: 3,
                                decoration: InputDecoration(
                                    labelText: "Address",
                                    border: OutlineInputBorder()),
                              )),
                          EditProfileTextInputContainer(
                            labelText: "Postal Code",
                          ),
                          EditProfileDropdownButtonFormFieldContainer(
                            items: [
                              DropdownMenuItem(
                                value: "MY",
                                child: Text("My"),
                              )
                            ],
                            labelText: "Country",
                          ),
                          EditProfileDropdownButtonFormFieldContainer(
                            labelText: "State",
                          ),
                          EditProfileDropdownButtonFormFieldContainer(
                            labelText: "City",
                          )
                        ],
                      ),
                    )),
                Card(
                  margin:
                      EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  child: Padding(
                    padding: EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Security",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        EditProfilePasswordTypeInput(
                            labelText: "Current Password"),
                        EditProfilePasswordTypeInput(
                          labelText: "New Password",
                        ),
                        EditProfilePasswordTypeInput(
                          labelText: "Confirm New Password",
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class EditProfilePasswordTypeInput extends StatefulWidget {
  final String labelText;

  EditProfilePasswordTypeInput({Key key, this.labelText}) : super(key: key);
  @override
  _EditProfilePasswordTypeInputState createState() =>
      _EditProfilePasswordTypeInputState();
}

class _EditProfilePasswordTypeInputState
    extends State<EditProfilePasswordTypeInput> {
  bool _visible = false;

  set visible(bool v) {
    setState(() => _visible = v);
  }

  bool get visible => _visible;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8, bottom: 8),
        child: Stack(
          children: [
            TextFormField(
              obscureText: !visible,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 8, right: 50),
                  labelText: widget.labelText,
                  border: OutlineInputBorder()),
            ),
            Positioned(
              right: 5,
              child: IconButton(
                  icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    visible = !visible;
                  }),
            )
          ],
        ));
  }
}

class EditProfileDropdownButtonFormFieldContainer extends StatelessWidget {
  final List<DropdownMenuItem> items;

  final String labelText;
  const EditProfileDropdownButtonFormFieldContainer(
      {Key key, this.items, this.labelText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: DropdownButtonFormField(
            items: items,
            onChanged: (e) => {},
            value: null,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(left: 8, right: 8),
            )));
  }
}

class EditProfileTextInputContainer extends StatelessWidget {
  final String labelText;

  final String errorText;
  final TextInputType keyboardType;

  const EditProfileTextInputContainer({
    Key key,
    this.labelText,
    this.errorText,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: TextFormField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(fontSize: 15),
              errorText: errorText,
              contentPadding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              border: OutlineInputBorder()),
        ));
  }
}

class PasswordInput extends EditProfileTextInputContainer {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

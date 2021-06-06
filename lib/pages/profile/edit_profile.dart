import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:rehabnow_app/components/rehabnow_scaffold.dart';
import 'package:rehabnow_app/main.dart';
import 'package:rehabnow_app/models/city.model.dart';
import 'package:rehabnow_app/models/country.model.dart';
import 'package:rehabnow_app/models/state.model.dart';
import 'package:rehabnow_app/models/user.model.dart';
import 'package:rehabnow_app/models/user_form.error.model.dart';
import 'package:rehabnow_app/services/generic_http.dart';
import 'package:rehabnow_app/services/profile.http.service.dart';
import 'package:rehabnow_app/utils/loading.dart';

class ProfileEdit extends StatefulWidget {
  final User user;

  const ProfileEdit({Key? key, required this.user}) : super(key: key);
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  File? image;

  var _form = GlobalKey<FormState>();
  late TextEditingController _postalCodeController;
  late TextEditingController _icNumberController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _addressController;
  late TextEditingController _confirmNewPwController;
  late TextEditingController _newPwController;
  late TextEditingController _currentPwController;
  late String _gender;
  late DateTime dateTime;
  late List<Country> _countries = [];
  List<ResidentialState> _states = [];
  late String _country;
  late int _state;
  late String _city;
  List<City> _cities = [];
  late String _nationality;
  UserFormError _userFormError = UserFormError.blank();
  bool loadingNationality = true;
  bool loadingCountries = true;
  bool loadingStates = true;
  bool loadingCities = true;

  @override
  void initState() {
    super.initState();
    getCountries().then((value) => setState(() {
          loadingCountries = loadingNationality = false;
          _countries = value;
        }));
    getStatesByIso2(widget.user.country!).then((value) => setState(() {
          loadingStates = false;
          _states = value;
        }));
    getCitiesByStateId(widget.user.state!).then((value) => setState(() {
          loadingCities = false;
          _cities = value;
        }));
    _postalCodeController = TextEditingController(text: widget.user.postcode);
    _icNumberController = TextEditingController(text: widget.user.icPassport);
    _phoneNumberController = TextEditingController(text: widget.user.phoneNum);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _addressController = TextEditingController(text: widget.user.address);
    dateTime = DateTime.fromMillisecondsSinceEpoch(widget.user.dob!);
    _confirmNewPwController = TextEditingController();
    _newPwController = TextEditingController();
    _currentPwController = TextEditingController();
    _gender = widget.user.gender!;
    _country = widget.user.country!;
    _state = widget.user.state!;
    _city = widget.user.city!;
    _nationality = widget.user.nationality!;

    print(DateFormat("dd/MM/yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(widget.user.dob!)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Edit Profile"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
          actions: <Widget>[
            TextButton(
                onPressed: _onsaved,
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Form(
          key: _form,
          child: Container(
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
                                      textEditingController:
                                          _firstNameController,
                                      validator: (value) => _validateNotEmpty(
                                          value, "First name"),
                                      errorText: _userFormError
                                          .first_name?.first.message,
                                    ),
                                    EditProfileTextInputContainer(
                                      labelText: "Last Name",
                                      textEditingController:
                                          _lastNameController,
                                      validator: (value) =>
                                          _validateNotEmpty(value, "Last name"),
                                      errorText: _userFormError
                                          .last_name?.first.message,
                                    ),
                                    EditProfileTextInputContainer(
                                      labelText: "Phone Number",
                                      keyboardType: TextInputType.number,
                                      textEditingController:
                                          _phoneNumberController,
                                      validator: (value) => _validateNotEmpty(
                                          value, "Phone number"),
                                      errorText: _userFormError
                                          .phone_num?.first.message,
                                    ),
                                    EditProfileTextInputContainer(
                                      labelText: "IC Number",
                                      textEditingController:
                                          _icNumberController,
                                      validator: (value) => _validateNotEmpty(
                                          value, "Ic number or passport"),
                                      errorText: _userFormError
                                          .ic_passport?.first.message,
                                    ),
                                    EditProfileDropdownButtonFormFieldContainer(
                                      onChanged: (e) {
                                        _gender = e;
                                      },
                                      value: _gender,
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
                                      errorText:
                                          _userFormError.gender?.first.message,
                                    ),
                                    Container(
                                        margin:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        child: DateTimeField(
                                          onChanged: (value) =>
                                              dateTime = value ?? dateTime,
                                          initialValue: dateTime,
                                          decoration: InputDecoration(
                                              labelText: "Date of Birth",
                                              errorText: _userFormError
                                                  .dob?.first.message,
                                              suffixIcon:
                                                  Icon(Icons.calendar_today),
                                              contentPadding: EdgeInsets.only(
                                                  left: 8, right: 8),
                                              border: OutlineInputBorder()),
                                          format: DateFormat("dd/MM/yyyy"),
                                          onShowPicker: (e, w) =>
                                              showDatePicker(
                                            context: context,
                                            initialDate: dateTime,
                                            firstDate: DateTime.utc(1900),
                                            lastDate: DateTime.now(),
                                          ),
                                        )),
                                    EditProfileDropdownButtonFormFieldContainer(
                                      isLoadingData: loadingNationality,
                                      onChanged: (e) {
                                        _nationality = e;
                                      },
                                      value: _nationality,
                                      items: _countries
                                          .map((e) => DropdownMenuItem(
                                                child: Text(e.nationality),
                                                value: e.iso2,
                                              ))
                                          .toList(),
                                      labelText: "Nationality",
                                      errorText: _userFormError
                                          .nationality?.first.message,
                                    )
                                  ]))),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image(
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : CircularProgressIndicator(
                                          value: progress.expectedTotalBytes ==
                                                  null
                                              ? null
                                              : (progress
                                                      .cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!),
                                        ),
                              image: image == null
                                  ? NetworkImage(
                                      '$MEDIA_URL/${widget.user.photo}')
                                  : FileImage(image!) as ImageProvider,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            TextButton(
                              clipBehavior: Clip.hardEdge,
                              onPressed: () async {
                                ImagePicker _picker = ImagePicker();
                                PickedFile? file = await _picker.getImage(
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
                                  controller: _addressController,
                                  validator: (value) =>
                                      _validateNotEmpty(value, "Address"),
                                  decoration: InputDecoration(
                                      labelText: "Address",
                                      errorText:
                                          _userFormError.address?.first.message,
                                      border: OutlineInputBorder()),
                                )),
                            EditProfileTextInputContainer(
                                labelText: "Postal Code",
                                textEditingController: _postalCodeController,
                                errorText:
                                    _userFormError.postcode?.first.message,
                                validator: (value) =>
                                    _validateNotEmpty(value, "Postal code")),
                            EditProfileDropdownButtonFormFieldContainer(
                              isLoadingData: loadingCountries,
                              onChanged: (e) {
                                _country = e;
                                setState(() {
                                  loadingStates = loadingCities = true;
                                });
                                getStatesByIso2(e).then((states) =>
                                    getCitiesByStateId(states.first.id)
                                        .then((cities) => setState(() {
                                              _states = states;
                                              _state = states.first.id;
                                              _cities = cities;
                                              _city = cities.first.city;
                                              loadingStates =
                                                  loadingCities = false;
                                            })));
                              },
                              value: _country,
                              items: _countries
                                  .map((e) => DropdownMenuItem(
                                      value: e.iso2, child: Text(e.country)))
                                  .toList(),
                              labelText: "Country",
                              errorText: _userFormError.country?.first.message,
                            ),
                            EditProfileDropdownButtonFormFieldContainer(
                              isLoadingData: loadingStates,
                              onChanged: (e) {
                                _state = e;
                                getCitiesByStateId(e)
                                    .then((value) => setState(() {
                                          _cities = value;
                                          _city = value.first.city;
                                        }));
                              },
                              value: _state,
                              items: _states
                                  .map((e) => DropdownMenuItem(
                                      value: e.id, child: Text(e.state)))
                                  .toList(),
                              labelText: "State",
                              errorText: _userFormError.state?.first.message,
                            ),
                            EditProfileDropdownButtonFormFieldContainer(
                              isLoadingData: loadingCities,
                              onChanged: (e) {
                                _city = e;
                              },
                              value: _city,
                              items: _cities
                                  .map((e) => DropdownMenuItem(
                                      value: e.city, child: Text(e.city)))
                                  .toList(),
                              labelText: "City",
                              errorText: _userFormError.city?.first.message,
                            )
                          ],
                        ),
                      )),
                  Card(
                    margin: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 10),
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
                            labelText: "Current Password",
                            errorText:
                                _userFormError.current_password?.first.message,
                            controller: _currentPwController,
                          ),
                          EditProfilePasswordTypeInput(
                            labelText: "New Password",
                            errorText:
                                _userFormError.new_password?.first.message,
                            controller: _newPwController,
                          ),
                          EditProfilePasswordTypeInput(
                            labelText: "Confirm New Password",
                            controller: _confirmNewPwController,
                            validator: (value) {
                              if (value != null &&
                                  _newPwController.text.compareTo(value) != 0) {
                                return "Confirm new password does not match new password.";
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  String? _validateNotEmpty(String? value, String field) =>
      value == null || value.trim().isEmpty // value!.length > 0
          ? null //"$field is required"
          : null;

  User createUser() {
    User user = widget.user;
    return User(
        user.id,
        user.lastLogin,
        user.email,
        user.createdDt, //dateTime.
        dateTime.millisecondsSinceEpoch,
        _firstNameController.text,
        _gender,
        _icNumberController.text,
        _lastNameController.text,
        _nationality,
        _phoneNumberController.text,
        user.status,
        image?.path,
        user.isAdmin,
        _city,
        _country,
        _state,
        _postalCodeController.text,
        _addressController.text);
  }

  void _onsaved() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_form.currentState!.validate()) {
      showLoadingDialog(context);
      User _newUser = createUser();
      saveProfile(_newUser, _currentPwController.text, _newPwController.text)
          .then((res) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _userFormError = res.data;
        });
        if (res.status != "success") {
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Profile Saved.")));
        }
      });
    }
  }

  void _onBack() {
    if (createUser() == widget.user) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Confirmation"),
                content: Text("Changes unsaved. Confirm to leave?"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("OK"))
                ],
              ));
    }
  }
}

class EditProfilePasswordTypeInput extends StatefulWidget {
  final String labelText;
  final String? errorText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  EditProfilePasswordTypeInput(
      {Key? key,
      required this.labelText,
      required this.controller,
      this.errorText,
      this.validator})
      : super(key: key);
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
              controller: widget.controller,
              validator: widget.validator,
              obscureText: !visible,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 8, right: 50),
                  labelText: widget.labelText,
                  errorText: widget.errorText,
                  errorMaxLines: 10,
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

class EditProfileDropdownButtonFormFieldContainer<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final String labelText;
  final value;
  final String? errorText;
  final Function(dynamic) onChanged;
  final bool? isLoadingData;

  const EditProfileDropdownButtonFormFieldContainer(
      {Key? key,
      this.items,
      required this.labelText,
      required this.value,
      required this.onChanged,
      this.errorText,
      this.isLoadingData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: DropdownButtonFormField<T>(
            items: items,
            onChanged: onChanged,
            value: value,
            icon: isLoadingData ?? false
                ? SizedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                    height: 20,
                    width: 20,
                  )
                : null,
            decoration: InputDecoration(
              labelText: labelText,
              errorText: errorText,
              errorMaxLines: 10,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(left: 8, right: 8),
            )));
  }
}

class EditProfileTextInputContainer extends StatelessWidget {
  final String labelText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;

  const EditProfileTextInputContainer({
    Key? key,
    required this.labelText,
    this.errorText,
    this.keyboardType,
    required this.textEditingController,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: TextFormField(
          keyboardType: keyboardType,
          controller: textEditingController,
          validator: validator,
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

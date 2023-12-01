import 'package:get/get.dart';
import 'package:inventory/Service/validate.dart';
import 'package:flutter/material.dart';
import 'package:inventory/Service/Api Service.dart';
import 'package:inventory/Service/Bloc.dart';
import 'qr_scanner.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiProvider = Apirepository();
  late String _email;
  late String _password;
  late String _phoneNumber;
  late String _smsCode;
  late String _errorMessage;

  late bool _isLoading;
  late bool _isPhone;
  late bool _codeSent = false;

  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _codeSent = false;
    _isPhone = true;
    super.initState();
  }

  void toggleEmailAndPhone() {
    setState(() {
      _isPhone = !_isPhone;
    });
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    try {
      if (_codeSent) {
        userBloc.phonesigninUser(_phoneNumber, _smsCode).then((data){
          Get.to(QRCodeScanner());
        });
      }
      else {
        userBloc.emailsigninUser(_email, _password).then((data){
          Get.to(QRCodeScanner());
        });
      }
    }catch(e){
      setState(() {
        _isLoading = false;
        _errorMessage = 'the credentials are incorrect, please try again';
      });
    }

  }



  Future<void> verifyPhone(phoneNo) async {
    String Id = await apiProvider.sendotp(phoneNo);
    setState(() {
      _smsCode = Id;
      _codeSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              !_isPhone ? showEmailInput() : Container(),
              !_isPhone ? showPasswordInput() : Container(),
              _isPhone ? showPhoneInput() : Container(),
              SizedBox(
                height: 10.0,
              ),
              showErrorMessage(),
              showPrimaryButton(),
              SizedBox(
                height: 15.0,
              ),
              _codeSent ? Container() : showSecondaryButton(),
              SizedBox(height: 10,),
            ],
          ),
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }


  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child:  TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
        onChanged: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Password can\'t be empty' : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPhoneInput() {
    return _codeSent
        ? showSmsCodeInput()
        : Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: false,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: "Phone Number",
          icon: Icon(
            Icons.phone,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value!.isEmpty
            ? 'Number can\'t be empty'
            : new Validate().verfiyMobile(value),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) => _phoneNumber = value.trim(),
      ),
    );
  }

  Widget showSmsCodeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        controller: _textController,
        maxLines: 1,
        obscureText: false,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "Enter OTP",
          icon: Icon(
            Icons.keyboard,
            color: Colors.grey,
          ),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value!.isEmpty
            ? 'Number can\'t be empty'
            : new Validate().verifyOTP(value),
        onChanged: (value) => _smsCode = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)
              )),
          // elevation: 5.0,
          // shape: new RoundedRectangleBorder(
          //     borderRadius: new BorderRadius.circular(30.0)),
          // color: Colors.blue,
          child: new Text(
            _isPhone ? (_codeSent ? 'Login' : 'Verify Phone') : 'Login',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          onPressed: () => {
            _isPhone
                ? (_codeSent ? validateAndSubmit() : verifyPhone(_phoneNumber))
                : validateAndSubmit()
          },
        ),
      ),
    );
  }

  Widget showSecondaryButton() {
    return InkWell(
      onTap: toggleEmailAndPhone,
      child: Center(
        child: _isPhone
            ? Text(
          "Sign in with Email",
          textScaleFactor: 1.1,
        )
            : Text(
          "Sign in with Phone Number",
          textScaleFactor: 1.1,
        ),
      ),
    );
  }
}
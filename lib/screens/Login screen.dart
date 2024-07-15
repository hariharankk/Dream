import 'package:get/get.dart';
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
  late String _errorMessage;

  late bool _isLoading;


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }


  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    try {

        userBloc.emailsigninUser(_email, _password).then((data){
          Get.to(QRCodeScanner());
        });

    }catch(e){
      setState(() {
        _isLoading = false;
        _errorMessage = 'the credentials are incorrect, please try again';
      });
    }

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
    return  Container(
        padding: const EdgeInsets.all(16.0),
        child:  Form(
          child:  ListView(
            shrinkWrap: true,
            children: <Widget>[
              showEmailInput() ,
              showPasswordInput() ,
              const SizedBox(
                height: 10.0,
              ),
              showErrorMessage(),
              showPrimaryButton(),

            ],
          ),
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return const SizedBox(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.isNotEmpty && _errorMessage != null) {
      return  Text(
        _errorMessage,
        style: const TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return  Container(
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
        decoration: const InputDecoration(
            hintText: 'Email',
            icon:  Icon(
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
        decoration: const InputDecoration(
          hintText: 'Password',
          icon:  Icon(
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



  Widget showPrimaryButton() {
    return  Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child:  ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius:  BorderRadius.circular(30.0)
              )),

          child:  const Text(
             'Login',
            style:  TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          onPressed: () => {
                validateAndSubmit(),
          },
        ),
      ),
    );
  }

}
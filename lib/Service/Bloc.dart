import 'package:rxdart/rxdart.dart';
import 'package:inventory/Service/Repository.dart';
import 'package:inventory/Model/Transaction.dart';
import 'package:inventory/Model/user.dart';




class UserBloc {
  final PublishSubject<User> _userGetter = PublishSubject<User>();
  User _user = new User.blank();

  UserBloc._privateConstructor();

  static final UserBloc _instance = UserBloc._privateConstructor();

  factory UserBloc() {
    return _instance;
  }

  Stream<User> get getUser => _userGetter.stream;

  User getUserObject() {
    return _user;
  }

  Future<void> registerUser(Map<dynamic,dynamic> user) async {
    try {
      _user = await repository.registerUser(user);

      _userGetter.sink.add(_user);
    } catch (e) {
      throw e;
    }
  }

  Future<void> emailsigninUser(
      String email, String password) async {
    try {
      _user = await repository.signinUser(email, password);
      _userGetter.sink.add(_user);
    } catch (e) {
      print(e);
      throw e;
    }
  }


  Future<void> currentuser() async {
    try {
      _user = await repository.currentuser();
      _userGetter.sink.add(_user);
    } catch (e) {
      throw e;
    }
  }



  dispose() {
    _userGetter.close();
  }
}

UserBloc userBloc = UserBloc();

class TransactionBloc {
  final PublishSubject<List<dynamic>> _transactionGetter = PublishSubject<List<dynamic>>();
  final PublishSubject<Map<dynamic, dynamic>> _totalAmountGetter = PublishSubject<Map<dynamic, dynamic>>();
  List<dynamic> _transactions = [];
  Map<dynamic, dynamic>? _totalAmount;

  TransactionBloc._privateConstructor();

  static final TransactionBloc _instance = TransactionBloc._privateConstructor();

  factory TransactionBloc() {
    return _instance;
  }

  Stream<List<dynamic>> get getTransactions => _transactionGetter.stream;

  List<dynamic> getTransactionsObject() {
    return _transactions;
  }

  Stream<Map<dynamic, dynamic>> get getTotalAmount => _totalAmountGetter.stream;

  Map<dynamic, dynamic> getTotalAmountObject() {
    return _totalAmount!;
  }

  Future<void> fetchTransactions() async {
    try {
      _transactions = await repository.getTransactions();
      _transactionGetter.sink.add(_transactions);
    } catch (e) {
      throw e;
    }
  }

  Future<void> createTransaction(Map<dynamic, dynamic> transactionData) async {
    try {
      Transaction transaction = await repository.createTransaction(transactionData);
      fetchTransactions();
      fetchTotalAmount();
    } catch (e) {
      throw e;
    }
  }

  Future<void> fetchTotalAmount() async {
    //try {
      _totalAmount = await repository.getTotalAmount();
      _totalAmountGetter.sink.add(_totalAmount!);
    } //catch (e) {
      //throw e;
    //}
  //}

  dispose() {
    _transactionGetter.close();
    _totalAmountGetter.close();
  }
}

TransactionBloc transactionbloc = TransactionBloc();


import 'package:flutter/material.dart';
import 'package:inventory/Service/Bloc.dart';
import 'package:get/get.dart';
import 'package:inventory/screens/Invoice.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {

  Future<void> retrieveInfo() async {
    transactionbloc.fetchTransactions();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await retrieveInfo();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:transactionbloc.getTransactions,
      initialData: [],
        builder: (context,  AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Container(child: Center(child: Text('Error: ${snapshot.error}')));
          }
        if (!snapshot.hasData) {
            return Container(child: Center(child: Text('No Data Available')));
          }
          else{
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Transaction History',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        elevation: 4.0,
                        color: Colors.grey[100],
                        child: ClipPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6))),
                          child: Container(
                            decoration: BoxDecoration(
                               border: Border(
                               right: BorderSide(color: Colors.black87, width: 10,)),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: snapshot.data != null
                                          ? ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var item = snapshot.data[index];
                                          return GestureDetector(
                                            onTap: (){
                                              print(item.transaction_time);
                                              Get.to(InvoiceScreen(transaction: item));
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            'Transaction Id',
                                                            style: TextStyle(
                                                              fontSize: 11.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${item.id}',
                                                            style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Colors.yellow,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            'Payment',
                                                            style: TextStyle(
                                                              fontSize: 11.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${item.payment_method}',
                                                            style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: Colors.pink,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Purchased On',
                                                            style: TextStyle(
                                                              fontSize: 11.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item.transaction_time))}',
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                            color: Colors.deepOrangeAccent,
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            'Total Amount',
                                                            style: TextStyle(
                                                              fontSize: 11.0,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Rs.${item.total}',
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: Colors.green,
                                                            ),
                                                          ),

                                                        ],
                                                      ),

                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(8.0),
                                                    child: Divider(
                                                      thickness: 2.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                          : Center(
                                        child: CircularProgressIndicator(),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      }
    );
  }
}


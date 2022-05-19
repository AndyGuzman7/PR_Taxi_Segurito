import 'package:flutter/material.dart';
import 'package:taxi_segurito_app/components/buttons/CustomButtonWithLinearBorder.dart';
import 'package:taxi_segurito_app/models/client_request.dart';
import 'package:taxi_segurito_app/pages/v2_list_request_client/taxi_service_request_list_functionality.dart';
import 'package:taxi_segurito_app/pages/v2_list_request_client/request_decision_functionality.dart';
import 'package:taxi_segurito_app/pages/v2_list_request_client/widgets/request_list.dart';
import 'package:taxi_segurito_app/pages/v2_list_request_client/widgets/request_list_item.dart';
import 'package:taxi_segurito_app/pages/v2_request_client_info_estimates/client_service_request_information_page.dart';

class TaxiServiceRequestListPage extends StatefulWidget {
  TaxiServiceRequestListPage({Key? key}) : super(key: key);

  @override
  State<TaxiServiceRequestListPage> createState() =>
      _TaxiServiceRequestListPageState();
}

class _TaxiServiceRequestListPageState
    extends State<TaxiServiceRequestListPage> {
  late List<ClienRequest> listRequest;
  late GlobalKey<RefreshIndicatorState> refreshListKey;
  RequestList requestList = new RequestList();

  late String idUserTaxista = "-N1vHdpBe2km7i6xJbkz";
  late bool estadoSolicitud = false;

  RequestDecisionFunctionality requestDecisionFunctionality =
      new RequestDecisionFunctionality();

  Color colorMain = Color.fromRGBO(255, 193, 7, 1);
  Color colorMainDanger = Color.fromRGBO(242, 78, 30, 1);
  Color colorMainNull = Color.fromARGB(255, 244, 123, 123);

  TaxiServiceRequestListPageFunctionality listRequestClientFunctionality =
      new TaxiServiceRequestListPageFunctionality();
  @override
  void initState() {
    super.initState();
    requestDecisionFunctionality.initFirebase();
    requestList.listRequest = [];
    listRequestClientFunctionality
        .initServiceUbicationPermisson()
        .then((value) {
      if (value) {
        listRequestClientFunctionality.initServiceUbication();
        listRequestClientFunctionality.updateListRequest = ((value) {
          setState(() {
            listRequest = value;
            requestList.listRequest = listRequest;
          });
        });
      }
    });

    refreshListKey = new GlobalKey<RefreshIndicatorState>();
    listRequest = new List<ClienRequest>.empty(growable: true);
  }

  Widget showList() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return new Container(
        height: height,
        width: width,
        child: ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: requestList.listRequest!.length,
            itemBuilder: (BuildContext context, int index) {
              return rowItem(context, index);
            }));
  }

  Widget rowItem(context, index) {
    dynamic dinamycOb = requestList.listRequest![index];

    return Dismissible(
      key: Key(listRequest[index].toString()),
      onDismissed: (direction) {
        var item = listRequest[index];
        showSnackBar(context, item, index);
        removeItem(index);
      },
      resizeDuration: new Duration(seconds: 2),
      background: deleteItem(),
      child: Card(
        child: new RequestListItem(
          clientRequest: dinamycOb,
          callbackRequest: (value) {
            requestList.callback!(value);
          },
        ),
      ),
    );
  }

  showSnackBar(context, item, index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Elemento removido de la lista'),
      action: SnackBarAction(
          label: "NO REMOVER SOLICITUD",
          onPressed: () {
            undoDelete(index, item);
          }),
    ));
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    addRandomItem();
    return null;
  }

  addRandomItem() {
    listRequestClientFunctionality.updateListRequest = ((value) {
      setState(() {
        listRequest = value;
        requestList.listRequest = listRequest;
        requestList.listRequest!.add(listRequest);
      });
    });
  }

  undoDelete(index, item) {
    setState(() {
      listRequest.insert(index, item);
    });
  }

  removeItem(index) {
    setState(() {
      listRequest.removeAt(index);
    });
  }

  Widget deleteItem() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      color: Colors.blue,
      child: Icon(Icons.delete, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    //check if you have requests from the customer user
    requestDecisionFunctionality.updateStatus = ((value) {
      setState(() {
        estadoSolicitud = value;
      });
    });

    //if available display the request confirmation notice
    if (estadoSolicitud) {
      Future.delayed(Duration.zero, () => showAlert(context));
    }

    //requestList.listRequest = listRequest;
    requestList.setCallbak = (ClienRequest value) {
      print(value.idFirebase);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClientServiceRequestInformationPage(
            serviceRequestId: value.idFirebase,
          ),
        ),
      );
    };

    Text title = new Text(
      "Lista de Solicitudes",
      style: const TextStyle(
          fontSize: 25.0, color: Colors.black, fontWeight: FontWeight.w700),
      textAlign: TextAlign.left,
    );

    AppBar appbar = new AppBar(
      foregroundColor: Colors.white,
      elevation: 0,
      title: Container(
        alignment: Alignment.center,
        child: Text(
          "Servicios de Taxi",
          style: TextStyle(),
        ),
      ),
    );
    return Scaffold(
      appBar: appbar,
      body: Container(
        color: Color.fromARGB(255, 248, 248, 248),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            title,
            Expanded(
              child: Container(
                child: RefreshIndicator(
                  key: refreshListKey,
                  child: showList(),
                  onRefresh: () async {
                    await refreshList();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//AlertDialog confirm request
  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        title: Text(
          "¿Quiere aceptar el servicio?",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        content: Row(
          children: [
            Expanded(
              child: CustomButtonWithLinearBorder(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  buttonBorderColor: colorMainNull,
                  marginBotton: 0,
                  marginLeft: 0,
                  marginRight: 0,
                  marginTop: 0,
                  buttonText: "Rechazar",
                  buttonColor: Colors.white,
                  buttonTextColor: colorMainNull),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: CustomButtonWithLinearBorder(
                  onTap: () {
                    requestDecisionFunctionality
                        .updateStatusRequest(idUserTaxista);
                    Navigator.pop(context);
                  },
                  buttonBorderColor: colorMainDanger,
                  marginBotton: 0,
                  marginLeft: 0,
                  marginRight: 0,
                  marginTop: 0,
                  buttonText: "Aceptar",
                  buttonColor: Colors.white,
                  buttonTextColor: colorMainDanger),
            ),
          ],
        ),
      ),
    );
  }
}

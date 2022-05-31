import 'package:flutter/material.dart';
import 'package:taxi_segurito_app/pages/v2_request_client_info_estimates/nameGalleryStateConfirmation.dart';
import 'package:taxi_segurito_app/strategis/firebase/implementation/service_request_estimates_impl.dart';
import 'package:taxi_segurito_app/strategis/firebase/implementation/taxi_impl.dart';

class ViewTaxiRequestFunctionality {
  late BuildContext context;
  ServiceRequestEstimatesImpl serviceRequestEstimatesImpl =
      new ServiceRequestEstimatesImpl();

  TaxiImpl taxiImpl = new TaxiImpl();
  ViewTaxiRequestFunctionality();

  void sendReasonCancel(idFirebase, motivo) {
    //value, motivo, status
    serviceRequestEstimatesImpl
        .cancelEstimateTaxi(
            idFirebase, motivo, NameGalleryStateConfirmation.CANCELADO)
        .then(
          (value) => {
            if (value) {Navigator.pop(context)}
          },
        );
  }

  void sendTerminateService(idFirebase, idTaxi) {
    serviceRequestEstimatesImpl
        .terminateService(idFirebase, NameGalleryStateConfirmation.FINALIZADO)
        .then(
          (value) => {
            print("Se finalizo el servicio con exito"),
            taxiImpl
                .updateStatusTaxi(
                    idTaxi, NameGalleryStateConfirmation.DISPONIBLE)
                .then((value) => print("Estado taxista: Disponible :)"))
          },
        );
  }
}

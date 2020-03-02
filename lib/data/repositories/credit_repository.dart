import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:built_collection/built_collection.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/serializers.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/data/web_client.dart';

class CreditRepository {
  const CreditRepository({
    this.webClient = const WebClient(),
  });

  final WebClient webClient;

  Future<InvoiceEntity> loadItem(
      Credentials credentials, String entityId) async {
    final dynamic response = await webClient.get(
        '${credentials.url}/credits/$entityId', credentials.token);

    final CreditItemResponse creditResponse =
        serializers.deserializeWith(CreditItemResponse.serializer, response);

    return creditResponse.data;
  }

  Future<BuiltList<InvoiceEntity>> loadList(
      Credentials credentials, int updatedAt) async {
    String url = credentials.url + '/credits?';

    if (updatedAt > 0) {
      url += '&updated_at=${updatedAt - kUpdatedAtBufferSeconds}';
    }

    final dynamic response = await webClient.get(url, credentials.token);

    final CreditListResponse creditResponse =
        serializers.deserializeWith(CreditListResponse.serializer, response);

    return creditResponse.data;
  }

  Future<List<InvoiceEntity>> bulkAction(
      Credentials credentials, List<String> ids, EntityAction action) async {
    var url = credentials.url + '/credits/bulk?';
    if (action != null) {
      url += '&action=' + action.toString();
    }
    final dynamic response = await webClient.post(url, credentials.token,
        data: json.encode({'ids': ids}));

    final CreditListResponse invoiceResponse =
    serializers.deserializeWith(CreditListResponse.serializer, response);

    return invoiceResponse.data.toList();
  }

  Future<InvoiceEntity> saveData(Credentials credentials, InvoiceEntity credit,
      [EntityAction action]) async {
    final data = serializers.serializeWith(InvoiceEntity.serializer, credit);
    dynamic response;

    if (credit.isNew) {
      response = await webClient.post(
          credentials.url + '/credits', credentials.token,
          data: json.encode(data));
    } else {
      var url = credentials.url + '/credits/' + credit.id.toString();
      if (action != null) {
        url += '?action=' + action.toString();
      }
      response =
          await webClient.put(url, credentials.token, data: json.encode(data));
    }

    final CreditItemResponse creditResponse =
        serializers.deserializeWith(CreditItemResponse.serializer, response);

    return creditResponse.data;
  }
}

import '../../../core/services/api_client.dart';

class OrderService {
  final ApiClient _api;

  OrderService(this._api);

  Future<Map<String, dynamic>> createOrder({
    required String type,
    String? deliveryAddress,
    List<int>? cartItemIds,
    int? totalAmount,
    List<Map<String, dynamic>>? items,
    int? couponId,
    String? storeName,
    String? storeImageUrl,
  }) async {
    final body = <String, dynamic>{'type': type};
    if (deliveryAddress != null) body['deliveryAddress'] = deliveryAddress;
    if (cartItemIds != null) body['cartItemIds'] = cartItemIds;
    if (totalAmount != null) body['totalAmount'] = totalAmount;
    if (items != null) body['items'] = items;
    if (couponId != null) body['couponId'] = couponId;
    if (storeName != null) body['storeName'] = storeName;
    if (storeImageUrl != null) body['storeImageUrl'] = storeImageUrl;

    final res = await _api.post('/orders', data: body);
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getOrderStatus(int orderId) async {
    final res = await _api.get('/orders/$orderId/status');
    return res['data'] as Map<String, dynamic>;
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/order_history_model.dart';
import '../../data/order_history_service.dart';

class OrdersProvider extends ChangeNotifier {
  static const _localOrdersKey = 'naru_local_orders';

  OrderHistoryService? _service;

  List<OrderHistoryModel> _all = [];
  List<OrderHistoryModel> _pending = [];
  List<OrderHistoryModel> _completed = [];
  bool _isLoading = false;
  String? _error;

  List<OrderHistoryModel> get all => _all;
  List<OrderHistoryModel> get pending => _pending;
  List<OrderHistoryModel> get completed => _completed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    final api = await ApiClient.getInstance();
    _service = OrderHistoryService(api);
  }

  Future<void> fetchAll() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localOrders = await _loadLocalOrders();

    try {
      final remoteOrders = await _service!.fetchAllOrders();
      _all = _sortOrders([...localOrders, ...remoteOrders]);
    } catch (e) {
      if (localOrders.isNotEmpty) {
        _all = _sortOrders(localOrders);
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPending() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localOrders =
        (await _loadLocalOrders()).where((order) => order.isPending).toList();

    try {
      final remoteOrders = await _service!.fetchPendingOrders();
      _pending = _sortOrders([...localOrders, ...remoteOrders]);
    } catch (e) {
      if (localOrders.isNotEmpty) {
        _pending = _sortOrders(localOrders);
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompleted() async {
    if (_service == null) await init();
    _isLoading = true;
    _error = null;
    notifyListeners();

    final localOrders = (await _loadLocalOrders())
        .where((order) => order.status == 'COMPLETED')
        .toList();

    try {
      final remoteOrders = await _service!.fetchCompletedOrders();
      _completed = _sortOrders([...localOrders, ...remoteOrders]);
    } catch (e) {
      if (localOrders.isNotEmpty) {
        _completed = _sortOrders(localOrders);
      }
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderHistoryModel> recordLocalOrder({
    int? remoteOrderId,
    int? storeId,
    required String storeName,
    String? storeImageUrl,
    required int totalAmount,
    required List<OrderHistoryItemModel> items,
    String status = 'PAID',
  }) async {
    final localOrders = await _loadLocalOrders();
    final order = OrderHistoryModel(
      id: remoteOrderId ?? -DateTime.now().microsecondsSinceEpoch,
      status: status,
      storeId: storeId,
      storeName: storeName,
      storeImageUrl: storeImageUrl,
      totalAmount: totalAmount,
      orderedAt: DateTime.now().toIso8601String(),
      items: items,
      isLocal: true,
    );

    final updatedLocalOrders = _sortOrders([order, ...localOrders]);
    await _saveLocalOrders(updatedLocalOrders);
    _all = _sortOrders([order, ..._all]);
    if (order.isPending) {
      _pending = _sortOrders([order, ..._pending]);
    }
    if (order.status == 'COMPLETED') {
      _completed = _sortOrders([order, ..._completed]);
    }
    _error = null;
    notifyListeners();
    return order;
  }

  Future<void> completeOrder(int orderId) async {
    if (_service == null) await init();

    if (orderId > 0) {
      try {
        await _service!
            .updateOrderStatus(orderId: orderId, status: 'COMPLETED');
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        rethrow;
      }
    }

    final localOrders = await _loadLocalOrders();
    OrderHistoryModel? completedOrder;
    final updatedLocalOrders = <OrderHistoryModel>[];

    for (final order in localOrders) {
      if (order.id == orderId) {
        completedOrder = order.copyWith(status: 'COMPLETED');
        updatedLocalOrders.add(completedOrder);
      } else {
        updatedLocalOrders.add(order);
      }
    }

    if (completedOrder == null) {
      for (final order in _all) {
        if (order.id == orderId) {
          completedOrder = order.copyWith(status: 'COMPLETED');
          if (completedOrder.isLocal) {
            updatedLocalOrders.add(completedOrder);
          }
          break;
        }
      }
    }

    await _saveLocalOrders(_sortOrders(updatedLocalOrders));

    if (completedOrder != null) {
      _all = _sortOrders([
        completedOrder,
        ..._all.where((order) => order.id != orderId),
      ]);
    }
    _pending = _sortOrders(
      _pending.where((order) => order.id != orderId).toList(),
    );
    if (completedOrder != null) {
      _completed = _sortOrders([
        completedOrder,
        ..._completed.where((order) => order.id != orderId),
      ]);
    }

    _error = null;
    notifyListeners();
  }

  List<OrderHistoryModel> _sortOrders(List<OrderHistoryModel> orders) {
    final deduped = <String, OrderHistoryModel>{};
    for (final order in orders) {
      final key = order.id > 0 ? 'order:${order.id}' : 'local:${order.id}';
      final existing = deduped[key];
      if (existing != null && existing.isLocal && !order.isLocal) {
        deduped[key] = _mergeRemoteWithLocal(
          remote: order,
          local: existing,
        );
        continue;
      }
      if (existing != null && !existing.isLocal && order.isLocal) {
        deduped[key] = _mergeRemoteWithLocal(
          remote: existing,
          local: order,
        );
        continue;
      }
      deduped[key] = order;
    }

    final list = deduped.values.toList();
    list.sort((a, b) => _orderTime(b).compareTo(_orderTime(a)));
    return list;
  }

  OrderHistoryModel _mergeRemoteWithLocal({
    required OrderHistoryModel remote,
    required OrderHistoryModel local,
  }) {
    return remote.copyWith(
      storeId: remote.storeId ?? local.storeId,
      storeName: _hasUsefulStoreName(remote.storeName)
          ? remote.storeName
          : local.storeName,
      storeImageUrl: _nonEmpty(remote.storeImageUrl) ?? local.storeImageUrl,
      totalAmount:
          remote.totalAmount > 0 ? remote.totalAmount : local.totalAmount,
      orderedAt: _nonEmpty(remote.orderedAt) ?? local.orderedAt,
      items: _mergeItems(remote.items, local.items),
      isLocal: local.isLocal,
    );
  }

  List<OrderHistoryItemModel> _mergeItems(
    List<OrderHistoryItemModel> remoteItems,
    List<OrderHistoryItemModel> localItems,
  ) {
    if (!_hasUsefulItems(remoteItems)) return localItems;
    if (localItems.isEmpty) return remoteItems;

    return List.generate(remoteItems.length, (index) {
      final remoteItem = remoteItems[index];
      if (index >= localItems.length) return remoteItem;

      final localItem = localItems[index];
      return OrderHistoryItemModel(
        menuId: remoteItem.menuId ?? localItem.menuId,
        name: _hasUsefulItemName(remoteItem.name)
            ? remoteItem.name
            : localItem.name,
        imageUrl: _nonEmpty(remoteItem.imageUrl) ?? localItem.imageUrl,
        quantity: remoteItem.quantity,
        unitPrice: remoteItem.unitPrice > 0
            ? remoteItem.unitPrice
            : localItem.unitPrice,
        selectedSize:
            _nonEmpty(remoteItem.selectedSize) ?? localItem.selectedSize,
        selectedJokbal:
            _nonEmpty(remoteItem.selectedJokbal) ?? localItem.selectedJokbal,
        selectedDrink:
            _nonEmpty(remoteItem.selectedDrink) ?? localItem.selectedDrink,
      );
    });
  }

  bool _hasUsefulStoreName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'delivery order' &&
        normalized != '알 수 없는 가게';
  }

  bool _hasUsefulItems(List<OrderHistoryItemModel> items) {
    return items.any((item) => _hasUsefulItemName(item.name));
  }

  bool _hasUsefulItemName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'ordered item';
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  DateTime _orderTime(OrderHistoryModel order) {
    return DateTime.tryParse(order.orderedAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<OrderHistoryModel>> _loadLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localOrdersKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
              (e) => OrderHistoryModel.fromLocalJson(e as Map<String, dynamic>))
          .where((order) => order.id != 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveLocalOrders(List<OrderHistoryModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final localOrders = orders.where((order) => order.isLocal).toList();
    final encoded = jsonEncode(
      localOrders.map((order) => order.toLocalJson()).toList(),
    );
    await prefs.setString(_localOrdersKey, encoded);
  }
}

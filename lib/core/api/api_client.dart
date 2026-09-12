import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this.storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final t = await storage.token;
          if (t != null) o.headers['Authorization'] = 'Bearer $t';
          h.next(o);
        },
      ),
    );
  }
  final SecureStorageService storage;
  final Dio dio;
  Future<dynamic> get(String p, {Map<String, dynamic>? query}) =>
      _run(() => dio.get(p, queryParameters: query));
  Future<dynamic> post(String p, {Object? data}) =>
      _run(() => dio.post(p, data: data));
  Future<dynamic> put(String p, {Object? data}) =>
      _run(() => dio.put(p, data: data));
  Future<dynamic> delete(String p) => _run(() => dio.delete(p));
  Future<dynamic> _run(Future<Response> Function() f) async {
    try {
      return (await f()).data['data'];
    } on DioException catch (e) {
      final d = e.response?.data;
      throw ApiException(
        d is Map
            ? d['message']?.toString() ?? 'Request failed'
            : 'Unable to connect to the server',
        e.response?.statusCode,
      );
    }
  }
}

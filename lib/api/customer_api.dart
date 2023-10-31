import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<List<Map<String, dynamic>>?> fetchData(
      {int page = 1, int pageSize = 30}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/v1/users/?page=$page&pageSize=$pageSize'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> customerData = (data['data'] as List)
          .where((userData) =>
              userData is Map<String, dynamic> &&
              userData['__t'] == 'Customer') // Filter for 'Customer'
          .map((userData) => userData as Map<String, dynamic>)
          .toList();

      return customerData;
    } else {
      throw Exception('Failed to load data from the API');
    }
  }
}

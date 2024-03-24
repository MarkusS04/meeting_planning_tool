import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meeting_planning_tool/data/api.dart';
import 'package:logger/web.dart';
import 'dart:convert';
import 'package:meeting_planning_tool/utils/dialog_utils.dart';
import 'package:meeting_planning_tool/utils/file_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:universal_html/html.dart' as html;

class ApiService {
  static Future<T> fetchData<T>(BuildContext context, String path,
      Map<String, dynamic> queryParams, T Function(dynamic) parser) async {
    final Uri url = Uri.parse('${ApiData.apiUrl}/$path')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      url,
      headers: {'Authorization': '${ApiData.authToken}'},
    );

    if (response.statusCode == 200) {
      dynamic data = json.decode(response.body);
      return parser(data);
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        unauthorizedDialog(context);
      }
    } else {
      if (context.mounted) {
        _dialogError(context);
      }
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    return Future.value();
  }

  static Future<String> downloadFile(BuildContext context, String path,
      Map<String, dynamic> queryParams) async {
    final Uri url = Uri.parse('${ApiData.apiUrl}/$path')
        .replace(queryParameters: queryParams);

    if (!kIsWeb) {
      return _downloadFileNative(context, url);
    } else {
      return _downloadFileWeb(context, url);
    }
  }

  static Future<String> _downloadFileNative(
      BuildContext context, Uri url) async {
    Directory? directory = await getDownloadsDirectory();

    if (directory == null) {
      context.mounted ? _dialogError(context) : null;
      return "";
    }

    final response = await http.get(
      url,
      headers: {'Authorization': '${ApiData.authToken}'},
    );

    if (response.statusCode == 200) {
      File file = File(
          '${directory.path}/${getFileNameFromHeader(response.headers['content-disposition'], 'Plan.pdf')}');
      file = await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        unauthorizedDialog(context);
      }
    } else {
      if (context.mounted) {
        _dialogError(context);
      }
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    return "";
  }

  static Future<String> _downloadFileWeb(BuildContext context, Uri url) async {
    html.AnchorElement anchorElement = html.AnchorElement(href: '');

    final response = await http.get(
      url,
      headers: {'Authorization': '${ApiData.authToken}'},
    );

    if (response.statusCode == 200) {
      anchorElement.download = getFileNameFromHeader(
          response.headers['content-disposition'], 'Plan.pdf');
      final blob = html.Blob([response.bodyBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      anchorElement.href = url;
      anchorElement.click();
      html.Url.revokeObjectUrl(url);
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        unauthorizedDialog(context);
      }
    } else {
      if (context.mounted) {
        _dialogError(context);
      }
      throw Exception('Failed to load data: ${response.statusCode}');
    }

    return "";
  }

  static Future<T> postData<T>(BuildContext context, String path, dynamic data,
      Map<String, dynamic> queryParams, T Function(dynamic) parser) async {
    final Uri url = Uri.parse('${ApiData.apiUrl}/$path')
        .replace(queryParameters: queryParams);

    final response = await http.post(url,
        headers: {
          'Authorization': '${ApiData.authToken}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data));

    switch (response.statusCode) {
      case 200 || 201:
        if (response.body.isNotEmpty) {
          dynamic data = json.decode(response.body);
          return parser(data);
        } else {
          return Future.value();
        }
      case 401:
        if (context.mounted) {
          unauthorizedDialog(context);
        }
        return Future.value();
      default:
        Logger().e(response.statusCode);
        if (context.mounted) {
          _dialogError(context);
        }
        return Future.value();
    }
  }

  static Future<T> putData<T>(BuildContext context, String path, dynamic data,
      T Function(dynamic) parser) async {
    final Uri url = Uri.parse('${ApiData.apiUrl}/$path');

    final response = await http.put(url,
        headers: {
          'Authorization': '${ApiData.authToken}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data));

    switch (response.statusCode) {
      case 200:
        if (response.body.isNotEmpty) {
          dynamic data = json.decode(response.body);
          return parser(data);
        } else {
          return Future.value();
        }
      case 401:
        if (context.mounted) {
          unauthorizedDialog(context);
        }
        return Future.value();
      default:
        Logger().e(response.statusCode);
        if (context.mounted) {
          _dialogError(context);
        }
        return Future.value();
    }
  }

  static Future<T> deleteData<T>(
      BuildContext context, String path, dynamic data) async {
    final Uri url = Uri.parse('${ApiData.apiUrl}/$path');

    final response = await http.delete(url,
        headers: {
          'Authorization': '${ApiData.authToken}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data));

    switch (response.statusCode) {
      case 200:
        return Future.value();
      case 401:
        if (context.mounted) {
          unauthorizedDialog(context);
        }
        return Future.value();
      default:
        if (context.mounted) {
          _dialogError(context);
        }
        return Future.value();
    }
  }

  static _dialogError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to fetch data'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meeting_planning_tool/models/api.dart';
import 'package:logger/web.dart';
import 'dart:convert';
import 'package:meeting_planning_tool/widgets/dialog_utils.dart';
import 'package:meeting_planning_tool/utils/file_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    final response = await http.get(
      url,
      headers: {
        'Authorization': '${ApiData.authToken}',
        'accept': 'application/pdf'
      },
    );

    if (response.statusCode == 200) {
      if (!kIsWeb) {
        return _downloadFileNative(context, response);
      } else {
        _downloadFileWeb(context, response);
        return "";
      }
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

  static Future<String> _downloadFileNative(
      BuildContext context, http.Response response) async {
    Directory? directory = await getDownloadsDirectory();

    if (directory == null) {
      context.mounted ? _dialogError(context) : null;
      return "";
    }

    File file = File(
        '${directory.path}/${getFileNameFromHeader(response.headers['content-disposition'], 'Plan.pdf')}');
    file = await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  static Future<void> _downloadFileWeb(
      BuildContext context, http.Response response) async {
    html.AnchorElement anchorElement = html.AnchorElement(href: '');

    anchorElement.download = getFileNameFromHeader(
        response.headers['content-disposition'], 'Plan.pdf');
    final blob = html.Blob([response.bodyBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    anchorElement.href = url;
    anchorElement.click();
    html.Url.revokeObjectUrl(url);
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
      case 200:
      case 201:
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
        Logger().e(response.body);
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
        title: Text(AppLocalizations.of(context).error),
        content: Text(AppLocalizations.of(context).failedFetchData),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}

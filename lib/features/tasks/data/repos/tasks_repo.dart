import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class TasksRepo {
  Future<Response> getEmployees({
    required BuildContext context,
    required Map<String, dynamic> query,
  });

  Future<Response> getTasks({
    required BuildContext context,
    required Map<String, dynamic> query,
  });

  Future<Response> getOneTask({
    required BuildContext context,
    required String id,
  });

  Future<Response> addTask({
    required BuildContext context,
    required Map<String, dynamic> data,
  });

  Future<Response> updateTask({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
  });

  Future<Response> updateStatusTask({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
  });
}

class TasksRepoImpl implements TasksRepo {
  @override
  Future<Response> getEmployees({
    required BuildContext context,
    required Map<String, dynamic> query,
  }) async {
    return await DioHelper.getData(
      url: "/emp_requests/v1/employees",
      query: query,
      context: context,
    );
  }

  @override
  Future<Response> getTasks({
    required BuildContext context,
    required Map<String, dynamic> query,
  }) async {
    return await DioHelper.getData(
      url: "/emp_requests/v1/task",
      query: query,
      context: context,
    );
  }

  @override
  Future<Response> getOneTask({
    required BuildContext context,
    required String id,
  }) async {
    return await DioHelper.getData(
      url: "/emp_requests/v1/task/$id",
      query: null,
      context: context,
    );
  }

  @override
  Future<Response> addTask({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    return await DioHelper.postData(
      url: "/emp_requests/v1/task",
      query: null,
      context: context,
      data: data,
    );
  }

  @override
  Future<Response> updateTask({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return await DioHelper.putData(
      url: "/emp_requests/v1/task/$id",
      query: null,
      context: context,
      data: data,
    );
  }

  @override
  Future<Response> updateStatusTask({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return await DioHelper.patchData(
      url: "/emp_requests/v1/task/$id/status",
      query: null,
      context: context,
      data: data,
    );
  }
}

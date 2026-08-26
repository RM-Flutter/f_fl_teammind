import re

with open('lib/features/overtime_requests/controllers/overtime_requests_controller.dart', 'r') as f:
    content = f.read()

# Replace variables
old_vars = """  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;"""
new_vars = """  int personalCurrentPage = 1;
  bool personalHasMore = true;
  bool personalIsLoadingMore = false;

  int incomingCurrentPage = 1;
  bool incomingHasMore = true;
  bool incomingIsLoadingMore = false;"""
content = content.replace(old_vars, new_vars)

# Replace fetchRequests
fetch_pattern = r'  Future<void> fetchRequests\(BuildContext context, \{bool loadMore = false\}\) async \{.*?(?=  void toggleDepartmentView)'
fetch_replacement = """  Future<void> fetchRequests(BuildContext context, {bool loadMore = false}) async {
    if (loadMore) {
      if (isForDepartment) {
        if (!incomingHasMore || incomingIsLoadingMore) return;
        incomingIsLoadingMore = true;
        incomingCurrentPage++;
      } else {
        if (!personalHasMore || personalIsLoadingMore) return;
        personalIsLoadingMore = true;
        personalCurrentPage++;
      }
      notifyListeners();
    } else {
      if (isForDepartment) {
        incomingCurrentPage = 1;
        incomingHasMore = true;
      } else {
        personalCurrentPage = 1;
        personalHasMore = true;
      }
      isLoading = true;
      notifyListeners();
    }

    try {
      // Fetch employees to map names if they are missing
      Map<int, String> employeeNames = {};
      try {
        final empResponse = await EmployeeService.getEmployees(context: context);
        if (empResponse.success && empResponse.data != null && empResponse.data!['employees'] != null) {
          final List<dynamic> emps = empResponse.data!['employees'];
          for (var e in emps) {
            if (e['id'] != null && e['name'] != null) {
              employeeNames[int.tryParse(e['id'].toString()) ?? 0] = e['name'];
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching employees for mapping: $e");
      }

      final String? jsonString = CacheHelper.getString("US1");
      int? currentUserId;
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> gCache = json.decode(jsonString);
        if (gCache['employee_profile_id'] != null) {
           currentUserId = int.tryParse(gCache['employee_profile_id'].toString());
        }
        if (currentUserId == null && gCache['id'] != null) {
           currentUserId = int.tryParse(gCache['id'].toString());
        }
      }

      String? apiEmployeeProfileId;
      if (!isForDepartment && currentUserId != null) {
        apiEmployeeProfileId = currentUserId.toString();
      } else {
        apiEmployeeProfileId = filterEmpId;
      }

      final pageToLoad = isForDepartment ? incomingCurrentPage : personalCurrentPage;
      final response = await OvertimeRequestsService.getOvertimeRequests(
        context: context,
        employeeProfileId: apiEmployeeProfileId,
        departmentId: filterDepId,
        from: filterFrom,
        to: filterTo,
        page: pageToLoad,
      );
      
      if (response.success && response.data != null && response.data!['requests'] != null) {
        final List<dynamic> requestsData = response.data!['requests'];
        List<OvertimeRequestModel> allRequests = requestsData.map((e) {
          final model = OvertimeRequestModel.fromJson(e);
          if ((model.employeeName == null || model.employeeName!.isEmpty) && model.employeeProfileId != null) {
            model.employeeName = employeeNames[model.employeeProfileId];
          }
          return model;
        }).toList();

        if (filterEmpId != null && filterEmpId!.isNotEmpty && isForDepartment) {
          final int? empId = int.tryParse(filterEmpId!);
          if (empId != null) {
            allRequests = allRequests.where((e) => e.employeeProfileId == empId).toList();
          }
        }

        if (filterDepName != null && filterDepName!.isNotEmpty) {
          allRequests = allRequests.where((e) => e.employeeProfile?.department == filterDepName).toList();
        }

        if (currentUserId != null) {
           final newMyRequests = allRequests.where((element) => element.employeeProfileId == currentUserId).toList();
           final newTeamRequests = allRequests.where((element) => element.employeeProfileId != currentUserId).toList();
           
           if (loadMore) {
             if (isForDepartment) {
               teamRequests.addAll(newTeamRequests);
             } else {
               myRequests.addAll(newMyRequests);
             }
           } else {
             if (isForDepartment) {
               teamRequests = newTeamRequests;
             } else {
               myRequests = newMyRequests;
             }
           }
        } else {
           if (loadMore) {
             if (isForDepartment) {
                teamRequests.addAll(allRequests);
             } else {
                myRequests.addAll(allRequests);
             }
           } else {
             if (isForDepartment) {
                teamRequests = allRequests;
             } else {
                myRequests = allRequests;
             }
           }
        }
        
        if (allRequests.isEmpty) {
          if (isForDepartment) {
            incomingHasMore = false;
          } else {
            personalHasMore = false;
          }
        }

      } else {
        if (isForDepartment) {
          incomingHasMore = false;
          if (!loadMore) teamRequests = [];
        } else {
          personalHasMore = false;
          if (!loadMore) myRequests = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching overtime requests: $e");
    }

    isLoading = false;
    if (isForDepartment) {
      incomingIsLoadingMore = false;
    } else {
      personalIsLoadingMore = false;
    }
    notifyListeners();
  }
"""

content = re.sub(fetch_pattern, fetch_replacement, content, flags=re.DOTALL)

with open('lib/features/overtime_requests/controllers/overtime_requests_controller.dart', 'w') as f:
    f.write(content)

with open('lib/features/overtime_requests/views/overtime_requests_screen.dart', 'r') as f:
    screen_content = f.read()

screen_old = """      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!provider.isLoadingMore && provider.hasMore) {
          provider.fetchRequests(context, loadMore: true);
        }
      }"""
screen_new = """      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (provider.isForDepartment) {
          if (!provider.incomingIsLoadingMore && provider.incomingHasMore) {
            provider.fetchRequests(context, loadMore: true);
          }
        } else {
          if (!provider.personalIsLoadingMore && provider.personalHasMore) {
            provider.fetchRequests(context, loadMore: true);
          }
        }
      }"""
screen_content = screen_content.replace(screen_old, screen_new)

screen_count_old = "itemCount: list.length + (provider.isLoadingMore ? 1 : 0),"
screen_count_new = "itemCount: list.length + (provider.isForDepartment ? (provider.incomingIsLoadingMore ? 1 : 0) : (provider.personalIsLoadingMore ? 1 : 0)),"
screen_content = screen_content.replace(screen_count_old, screen_count_new)

with open('lib/features/overtime_requests/views/overtime_requests_screen.dart', 'w') as f:
    f.write(screen_content)

print("Done replacing.")

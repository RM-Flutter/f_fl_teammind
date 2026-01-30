import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'package:app_test/features/home/controllers/home_controller.dart';

import '../../../../../../../../controllers/points_controller/points_controller.dart';


class ContactSelectionScreen extends StatefulWidget {
  const ContactSelectionScreen({super.key});

  @override
  _ContactSelectionScreenState createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  final Map<String, dynamic> _selectedContacts = {
    "items": []
  };
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _getContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true, withPhoto: true);
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    }
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where((contact) => contact.displayName.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleSelection(Contact contact) async {
    if (contact.phones.isEmpty) return;

    String rawPhoneNumber = contact.phones.first.number.replaceAll(RegExp(r'\D'), ''); // Normalize number
    String countryCode = await getCountryCode(rawPhoneNumber);

    setState(() {
      List items = _selectedContacts["items"];
      int existingIndex = items.indexWhere((item) =>
          (item["phonesNumbers"] as List).contains(rawPhoneNumber)
      );

      if (existingIndex != -1) {
        items.removeAt(existingIndex);
      } else {
        items.add({
          "name": contact.displayName.toString(),
          "country_code": countryCode.toString(),
          "phonesNumbers": [rawPhoneNumber.toString()],
        });
      }
    });
    debugPrint("_selectedContacts is --> $_selectedContacts");
    debugPrint("_selectedContacts is --> ${_selectedContacts.length}");
  }
  Future<String> getCountryCode(String phoneNumber) async {
    try {
      final parsed = PhoneNumber.parse(phoneNumber, callerCountry: IsoCode.EG); // Use IsoCode.EG instead of "EG"
      return "+${parsed.countryCode}"; // Returns country code with "+"
    } catch (e) {
      debugPrint("Error extracting country code: $e");
      return ""; // Return empty if parsing fails
    }
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => PointsController(),),
      ChangeNotifierProvider(create: (context) => HomeController(),),
    ],
    child: Consumer<HomeController>(
      builder: (context, values, child) {
        return Consumer<PointsController>(
          builder: (context, value, child) {
            if(value.isAddFriendContactSuccess == true){
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedContacts['items'].clear();
                });
                values.initializeHomeScreen(context, null);
              });
              value.isAddFriendContactSuccess = false;
            }
            return Scaffold(
              backgroundColor: const Color(0xffFFFFFF),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child:  Icon(
                    Icons.arrow_back,
                    color: Color(AppColors.dark),
                  ),
                ),
                centerTitle: true,
                title: Text(
                  AppStrings.recommendFriends.tr().toUpperCase(),
                  style:  TextStyle(
                    color: Color(AppColors.dark),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${_selectedContacts['items'].length} ${AppStrings.selected.tr()}",
                            style: const TextStyle(color: Color(0xff5E5E5E), fontSize: 12 ,fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          if(value.isAddFriendLoading == true)Container(
                            width: 90,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                          if(value.isAddFriendLoading == false)SizedBox(
                            height: 30,
                            child: CustomElevatedButton(
                                width: 90,
                                onPressed: () async {
                                  value.addFriendContact(context,contact: _selectedContacts);
                                },
                                title: AppStrings.add.tr().toUpperCase(),
                                isPrimaryBackground: true,
                                isFuture: false),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 45,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.search.tr(),
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: GestureDetector(
                                        onTap: (){
                                          _searchController.clear();
                                        },
                                        child: const Icon(Icons.close)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          GestureDetector(
                              onTap: (){
                                _searchController.clear();
                              },
                              child: Text(AppStrings.cancel.tr().toUpperCase(),style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black)),))
                        ],
                      ),
                    ),
                    if(_filteredContacts.isEmpty)Container(
                      height: MediaQuery.sizeOf(context).height * 0.7,
                      alignment: Alignment.center,
                      child: Center(child: Text("${AppStrings.searchingInContacts.tr()} ...", style: const TextStyle(color: Colors.black, fontSize: 18),),),
                    ),
                    if(_filteredContacts.isNotEmpty)SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.7,
                      child: ListView.builder(
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          Contact contact = _filteredContacts[index];

                          // Ensure the contact has at least one phone number
                          String contactNumber = contact.phones.isNotEmpty
                              ? contact.phones.first.number
                              : "No number";

                          bool isSelected = _selectedContacts["items"].any((item) {
                            var phoneNumbers = item["phonesNumbers"] as List;
                            return contact.phones.isNotEmpty && phoneNumbers.contains(
                                contact.phones.first.number.replaceAll(RegExp(r'\D'), '')
                            );
                          });

                          return ListTile(
                            leading: (contact.photo != null)
                                ? CircleAvatar(backgroundImage: MemoryImage(contact.photo!))
                                : CircleAvatar(child: Text(contact.displayName.isNotEmpty ? contact.displayName[0] : '?')),
                            title: Text(contact.displayName.isNotEmpty ? contact.displayName : "Unknown"),
                            subtitle: Text(contactNumber),
                            trailing: isSelected ? Icon(Icons.check_circle, color: Color(AppColors.primary)) : null,
                            onTap: () => _toggleSelection(contact),
                          );
                        },
                      ),
                    ),


                  ],
                ),
              ),
            );
          },
        );
      },
    ),
    );
  }
}

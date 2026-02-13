import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../utils/tab_bar_widget.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import '../../models/smart_card_profile_models.dart';
import '../../services/cv_reference_data.service.dart';
import '../../services/smart_card.service.dart';

class UpdateCompanyInfoScreen extends StatefulWidget {
  final Map<String, dynamic> company;

  const UpdateCompanyInfoScreen({super.key, required this.company});

  @override
  State<UpdateCompanyInfoScreen> createState() =>
      _UpdateCompanyInfoScreenState();
}

class _UpdateCompanyInfoScreenState extends State<UpdateCompanyInfoScreen> {
  Map<String, dynamic> _company = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _initialLoadDone = false;

  int _selectedTabIndex = 0;
  late final List<String> _tabs;

  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _businessController;
  late final TextEditingController _addressController;
  late final TextEditingController _countryKeyController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _behanceController;
  late final TextEditingController _websiteController;
  late final TextEditingController _whatsappController;

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _cities = [];
  int? _countryId;
  int? _stateId;
  int? _cityId;

  final List<TextEditingController> _morePhonesControllers = [];
  final List<TextEditingController> _otherLinksControllers = [];
  final List<TextEditingController> _portfolioNames = [];
  final List<TextEditingController> _portfolioDescs = [];
  final List<TextEditingController> _portfolioLinks = [];

  // Media: each item is either Map{id, file} (existing from API) or String (base64 new). API expects works_gallery[]/logo[]/video_gallery[] as array of IDs for existing + files for new.
  List<dynamic> _logo = [];
  List<dynamic> _worksGallery = [];
  List<dynamic> _videoGallery = [];
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _aboutController = TextEditingController();
    _businessController = TextEditingController();
    _addressController = TextEditingController();
    _countryKeyController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _linkedinController = TextEditingController();
    _behanceController = TextEditingController();
    _websiteController = TextEditingController();
    _whatsappController = TextEditingController();
    _tabs = [
      AppStrings.personal.tr().toUpperCase(),
      AppStrings.contact.tr().toUpperCase(),
      AppStrings.jopInfo.tr().toUpperCase(),
      AppStrings.portfolio.tr().toUpperCase(),
    ];
    _loadFullCompanyAndRefs();
  }

  Future<void> _loadFullCompanyAndRefs() async {
    if (_initialLoadDone) return;
    setState(() => _isLoading = true);
    try {
      final id = widget.company['id'] as int?;
      Map<String, dynamic> full = Map<String, dynamic>.from(widget.company);
      if (id != null) {
        try {
          final res = await SmartCardService.getCompanyProfile(context, companyId: id);
          final data = res['data'];
          if (data is Map) {
            full = Map<String, dynamic>.from(data);
            full['id'] = id;
          }
        } catch (_) {}
      }
      _company = full;
      _isPremium = _company['is_premium'] == true;

      _nameController.text = _company['name']?.toString() ?? '';
      _aboutController.text = _company['about']?.toString() ?? '';
      _businessController.text = _company['business']?.toString() ?? '';
      _addressController.text = _company['address']?.toString() ?? '';
      _countryKeyController.text = _company['country_key']?.toString() ?? '';
      _phoneController.text = _company['phone']?.toString() ?? '';
      _emailController.text = _company['email']?.toString() ?? '';
      _linkedinController.text = _company['linkedin']?.toString() ?? '';
      _behanceController.text = _company['behance']?.toString() ?? '';
      _websiteController.text = _company['website']?.toString() ?? '';
      _whatsappController.text = _company['whatsapp']?.toString() ?? '';

      _countryId = _parseId(_company['country_id']) ?? _parseId(_company['country']?['id']);
      _stateId = _parseId(_company['state_id']) ?? _parseId(_company['state']?['id']);
      _cityId = _parseId(_company['city_id']) ?? _parseId(_company['city']?['id']);

      final morePhones = _company['more_phones'] as List<dynamic>?;
      if (morePhones != null && morePhones.isNotEmpty) {
        for (final e in morePhones) {
          final phone = (e is Map ? (e['phone'] ?? e['number']) : null)?.toString() ?? '';
          _morePhonesControllers.add(TextEditingController(text: phone));
        }
      }
      final otherLinks = _company['other_links'] as List<dynamic>?;
      if (otherLinks != null && otherLinks.isNotEmpty) {
        for (final e in otherLinks) {
          final url = (e is Map ? e['url'] : null)?.toString() ?? '';
          _otherLinksControllers.add(TextEditingController(text: url));
        }
      }
      final portfolios = _company['portfolios'] as List<dynamic>?;
      if (portfolios != null && portfolios.isNotEmpty) {
        for (final e in portfolios) {
          if (e is Map<String, dynamic>) {
            _portfolioNames.add(TextEditingController(text: e['project_name']?.toString() ?? ''));
            _portfolioDescs.add(TextEditingController(text: e['project_description']?.toString() ?? ''));
            _portfolioLinks.add(TextEditingController(text: e['project_link']?.toString() ?? ''));
          }
        }
      }

      // Initialize logo & galleries: store existing as {id, file} so we send IDs on update; new uploads stay as base64 String.
      final rawLogo = _company['logo'];
      if (rawLogo is List) {
        _logo = rawLogo.map((e) {
          if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
            return {
              'id': e['id'],
              'file': (e['file'] ?? e['thumbnail'])?.toString(),
            };
          }
          return e.toString();
        }).toList();
      } else if (rawLogo is String) {
        final trimmed = rawLogo.trim();
        if (trimmed.isNotEmpty && trimmed != '[]') {
          if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            try {
              final decoded = json.decode(trimmed);
              if (decoded is List) {
                _logo = decoded.map((e) => e.toString()).toList();
              }
            } catch (_) {
              _logo = [trimmed];
            }
          } else {
            _logo = [trimmed];
          }
        }
      }
      final worksGallery = _company['works_gallery'] as List<dynamic>?;
      final videoGallery = _company['video_gallery'] as List<dynamic>?;
      _worksGallery = worksGallery
              ?.map((e) {
                if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
                  return {
                    'id': e['id'],
                    'file': (e['file'] ?? e['thumbnail'])?.toString(),
                  };
                }
                return e.toString();
              })
              .toList() ??
          [];
      _videoGallery = videoGallery
              ?.map((e) {
                if (e is Map && (e['id'] != null || e['file'] != null || e['thumbnail'] != null)) {
                  return {
                    'id': e['id'],
                    'thumbnail' : e['thumbnail'],
                    'file': (e['file'] ?? e['thumbnail'])?.toString(),
                  };
                }
                return e.toString();
              })
              .toList() ??
          [];

      final countries = await CVReferenceDataService.getCountries(context);
      _countries = countries;
      if (_countryId != null) await _loadStates(_countryId!, clearStateAndCity: false);
      if (_stateId != null) await _loadCities(_stateId!);
      _initialLoadDone = true;
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _company = Map<String, dynamic>.from(widget.company);
        _nameController.text = _company['name']?.toString() ?? '';
        _aboutController.text = _company['about']?.toString() ?? '';
        _businessController.text = _company['business']?.toString() ?? '';
        _addressController.text = _company['address']?.toString() ?? '';
        _countryKeyController.text = _company['country_key']?.toString() ?? '';
        _phoneController.text = _company['phone']?.toString() ?? '';
        _emailController.text = _company['email']?.toString() ?? '';
        _linkedinController.text = _company['linkedin']?.toString() ?? '';
        _behanceController.text = _company['behance']?.toString() ?? '';
        _websiteController.text = _company['website']?.toString() ?? '';
        _whatsappController.text = _company['whatsapp']?.toString() ?? '';
        _countryId = _parseId(_company['country_id']) ?? _parseId(_company['country']?['id']);
        _stateId = _parseId(_company['state_id']) ?? _parseId(_company['state']?['id']);
        _cityId = _parseId(_company['city_id']) ?? _parseId(_company['city']?['id']);
      });
      if (_countryId != null) await _loadStates(_countryId!, clearStateAndCity: false);
      if (_stateId != null) await _loadCities(_stateId!);
      _initialLoadDone = true;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static int? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  bool _idMatch(dynamic itemId, int? targetId) {
    if (targetId == null) return false;
    final id = _parseId(itemId);
    return id != null && id == targetId;
  }

  /// URL or base64 string for display: item is Map{id, file} or String (base64).
  String? _mediaDisplayUrl(dynamic item) {
    if (item is Map) return (item['file'] ?? item['thumbnail'])?.toString();
    if (item is String) return item;
    return null;
  }

  Future<void> _loadStates(int countryId, {bool clearStateAndCity = true}) async {
    List<Map<String, dynamic>> states = await CVReferenceDataService.getStates(context, countryId);
    if (!clearStateAndCity && _stateId != null && _company['state'] is Map) {
      final fromRes = _company['state'] as Map;
      final hasMatch = states.any((s) => _idMatch(s['id'], _stateId));
      if (!hasMatch) {
        states = [...states, {
          'id': _parseId(fromRes['id']),
          'title': fromRes['title']?.toString() ?? fromRes['name']?.toString() ?? '',
        }];
      }
    }
    setState(() {
      _states = states;
      if (clearStateAndCity) {
        _cities = [];
        _stateId = null;
        _cityId = null;
      }
    });
  }

  Future<void> _loadCities(int stateId) async {
    List<Map<String, dynamic>> cities = await CVReferenceDataService.getCities(context, stateId);
    if (_cityId != null && _company['city'] is Map) {
      final fromRes = _company['city'] as Map;
      final hasMatch = cities.any((c) => _idMatch(c['id'], _cityId));
      if (!hasMatch) {
        cities = [...cities, {
          'id': _parseId(fromRes['id']),
          'title': fromRes['title']?.toString() ?? fromRes['name']?.toString() ?? '',
        }];
      }
    }
    setState(() => _cities = cities);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _businessController.dispose();
    _addressController.dispose();
    _countryKeyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _behanceController.dispose();
    _websiteController.dispose();
    _whatsappController.dispose();
    for (final c in _morePhonesControllers) c.dispose();
    for (final c in _otherLinksControllers) c.dispose();
    for (final c in _portfolioNames) c.dispose();
    for (final c in _portfolioDescs) c.dispose();
    for (final c in _portfolioLinks) c.dispose();
    super.dispose();
  }

  void _addMorePhone() => setState(() => _morePhonesControllers.add(TextEditingController()));
  void _removeMorePhone(int i) {
    if (i >= 0 && i < _morePhonesControllers.length) {
      _morePhonesControllers[i].dispose();
      _morePhonesControllers.removeAt(i);
      setState(() {});
    }
  }
  void _addOtherLink() => setState(() => _otherLinksControllers.add(TextEditingController()));
  void _removeOtherLink(int i) {
    if (i >= 0 && i < _otherLinksControllers.length) {
      _otherLinksControllers[i].dispose();
      _otherLinksControllers.removeAt(i);
      setState(() {});
    }
  }
  void _addPortfolio() => setState(() {
    _portfolioNames.add(TextEditingController());
    _portfolioDescs.add(TextEditingController());
    _portfolioLinks.add(TextEditingController());
  });
  void _removePortfolio(int i) {
    if (i >= 0 && i < _portfolioNames.length) {
      _portfolioNames[i].dispose();
      _portfolioDescs[i].dispose();
      _portfolioLinks[i].dispose();
      _portfolioNames.removeAt(i);
      _portfolioDescs.removeAt(i);
      _portfolioLinks.removeAt(i);
      setState(() {});
    }
  }

  Future<void> _pickWorksImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final List<String> files = [];
      for (final file in result.files) {
        if (file.bytes != null) {
          files.add(base64Encode(file.bytes!));
        }
      }
      if (files.isEmpty) return;
      setState(() {
        _worksGallery.addAll(files);
      });
    } catch (e) {
      debugPrint('Failed to pick works gallery images: $e');
    }
  }

  Future<void> _pickVideos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.video,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final List<String> files = [];
      for (final file in result.files) {
        if (file.bytes != null) {
          files.add(base64Encode(file.bytes!));
        }
      }
      if (files.isEmpty) return;
      setState(() {
        _videoGallery.addAll(files);
      });
    } catch (e) {
      debugPrint('Failed to pick video gallery files: $e');
    }
  }

  Future<void> _pickLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      final encoded = base64Encode(file.bytes!);
      setState(() {
        _logo = [encoded];
      });
    } catch (e) {
      debugPrint('Failed to pick logo image: $e');
    }
  }


  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = AppStrings.pleaseEnterCompanyName.tr());
      return;
    }
    final id = _company['id'] as int?;
    if (id == null) return;
    setState(() { _isSubmitting = true; _errorMessage = null; });
    try {
      final morePhonesList = _morePhonesControllers
          .map((c) => SmartCardMorePhone(phone: c.text.trim().isEmpty ? null : c.text.trim()))
          .toList();
      final otherLinksList = _otherLinksControllers
          .map((c) => SmartCardOtherLink(url: c.text.trim().isEmpty ? null : c.text.trim()))
          .toList();
      final portfolioList = <SmartCardPortfolioItem>[];
      for (var i = 0; i < _portfolioNames.length; i++) {
        portfolioList.add(SmartCardPortfolioItem(
          projectName: _portfolioNames[i].text.trim().isEmpty ? null : _portfolioNames[i].text.trim(),
          projectDescription: _portfolioDescs[i].text.trim().isEmpty ? null : _portfolioDescs[i].text.trim(),
          projectLink: _portfolioLinks[i].text.trim().isEmpty ? null : _portfolioLinks[i].text.trim(),
        ));
      }
      final fullModel = SmartCardCompanyProfileModel(
        logo: _logo.isEmpty ? null : _logo,
        name: name,
        about: _aboutController.text.trim().isEmpty ? null : _aboutController.text.trim(),
        business: _businessController.text.trim().isEmpty ? null : _businessController.text.trim(),
        countryId: _countryId,
        stateId: _stateId,
        cityId: _cityId,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        countryKey: _countryKeyController.text.trim().isEmpty ? null : _countryKeyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        morePhones: morePhonesList.isEmpty ? null : morePhonesList,
        linkedin: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
        behance: _behanceController.text.trim().isEmpty ? null : _behanceController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        otherLinks: otherLinksList.isEmpty ? null : otherLinksList,
        portfolios: portfolioList.isEmpty ? null : portfolioList,
        worksGallery: _worksGallery,
        videoGallery: _videoGallery,
      );
      await SmartCardService.updateCompany(
        context,
        companyId: id,
        body: fullModel.toFullJson(),
        logoBase64: null,
        worksGalleryBase64: null,
        videoGalleryBase64: null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.updatedSuccessfully.tr())),
        );
        GoRouter.of(context).pop();
      }
    } catch (e) {
      final msg = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      if (mounted) {
        setState(() { _errorMessage = msg; _isSubmitting = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(text, style: TextStyle(color: Color(AppColors.dark), fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppColors.dark))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final selected = _countryId != null
        ? _countries.cast<Map<String, dynamic>?>().firstWhere(
            (c) => c != null && _idMatch(c['id'], _countryId),
            orElse: () => null,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.country.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppColors.dark))),
          const SizedBox(height: 8),
          CustomDropdown.search(
            items: _countries,
            selectedValue: selected,
            nameKey: 'title',
            hintText: AppStrings.selectCountry.tr(),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onChanged: (value) {
              if (value.isNotEmpty && value['id'] != null) {
                final id = value['id'] is int ? value['id'] as int : int.tryParse(value['id'].toString());
                if (id != null) {
                  setState(() {
                    _countryId = id;
                    // Set country key (phone code) automatically like CV create/update
                    final phoneCode = value['phone_code'];
                    if (phoneCode != null) {
                      _countryKeyController.text = phoneCode.toString();
                    }
                  });
                  _loadStates(id);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStateDropdown() {
    final selected = _stateId != null
        ? _states.cast<Map<String, dynamic>?>().firstWhere(
            (s) => s != null && _idMatch(s['id'], _stateId),
            orElse: () => null,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.stateProvince.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppColors.dark))),
          const SizedBox(height: 8),
          CustomDropdown.search(
            items: _states,
            selectedValue: selected,
            nameKey: 'title',
            hintText: AppStrings.selectStateProvince.tr(),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onChanged: (value) {
              if (value.isNotEmpty && value['id'] != null) {
                final id = value['id'] is int ? value['id'] as int : int.tryParse(value['id'].toString());
                if (id != null) { setState(() => _stateId = id); _loadCities(id); }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Color(AppColors.dark),
        borderRadius: BorderRadius.circular(AppSizes.s30),
      ),
      height: AppSizes.s55,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s6, vertical: AppSizes.s6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: defaultTapBarItem(
          isVertical: false,
          items: _tabs,
          tapBarItemsWidth: MediaQuery.sizeOf(context).width * 0.95,
          selectIndex: _selectedTabIndex,
          enableScroll: kIsWeb ? false : true,
          onTapItem: (index) {
            setState(() => _selectedTabIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    final selected = _cityId != null
        ? _cities.cast<Map<String, dynamic>?>().firstWhere(
            (c) => c != null && _idMatch(c['id'], _cityId),
            orElse: () => null,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.city.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppColors.dark))),
          const SizedBox(height: 8),
          CustomDropdown.search(
            items: _cities,
            selectedValue: selected,
            nameKey: 'title',
            hintText: AppStrings.selectCity.tr(),
            hintStyle: TextStyle(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onChanged: (value) {
              if (value.isNotEmpty && value['id'] != null) {
                final id = value['id'] is int ? value['id'] as int : int.tryParse(value['id'].toString());
                if (id != null) setState(() => _cityId = id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(int index) {
    if (index >= _portfolioNames.length) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${AppStrings.portfolio.tr()} ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removePortfolio(index)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _portfolioNames[index],
              decoration: InputDecoration(
                labelText: AppStrings.projectName.tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portfolioDescs[index],
              decoration: InputDecoration(
                labelText: AppStrings.projectDescription.tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portfolioLinks[index],
              decoration: InputDecoration(
                labelText: AppStrings.projectLink.tr(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithBookmark(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Color(AppColors.dark), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
          onPressed: () { try { GoRouter.of(context).pop(); } catch (e) { Navigator.of(context).pop(); } },
        ),
        title: AppStrings.updateCompanyInfo.tr(),
        titleStyle: TextStyle(color: Color(AppColors.dark), fontSize: 18, fontWeight: FontWeight.w500),
        centerTitle: true,
        routeName: AppRoutes.updateCompanyInfoScreen.name,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  if (_selectedTabIndex == 0) ...[
                    // Logo avatar at top (similar style to PersonalProfileScreen header)
                    Center(
                      child: GestureDetector(
                        onTap: _pickLogo,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Builder(
                              builder: (context) {
                                ImageProvider? provider;
                                if (_logo.isNotEmpty) {
                                  final urlOrBase64 = _mediaDisplayUrl(_logo.first);
                                  if (urlOrBase64 != null) {
                                    if (urlOrBase64.startsWith('http') || urlOrBase64.startsWith('https')) {
                                      provider = NetworkImage(urlOrBase64);
                                    } else {
                                      try {
                                        provider = MemoryImage(base64Decode(urlOrBase64));
                                      } catch (_) {}
                                    }
                                  }
                                }
                                return CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: provider,
                                  child: provider == null
                                      ? const Icon(Icons.image, size: 32, color: Colors.grey)
                                      : null,
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(AppColors.dark),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(controller: _nameController, label: AppStrings.companyName.tr(), hint: AppStrings.companyName.tr()),
                    _buildCountryDropdown(),
                    _buildStateDropdown(),
                    _buildCityDropdown(),
                    _buildField(controller: _addressController, label: AppStrings.address.tr(), hint: AppStrings.address.tr(), maxLines: 2),
                  ],
                  if (_selectedTabIndex == 1) ...[
                    _buildField(controller: _phoneController, label: AppStrings.phone.tr(), hint: AppStrings.phoneNumber.tr(), keyboardType: TextInputType.phone),
                    ...List.generate(_morePhonesControllers.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _morePhonesControllers[i],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: '${AppStrings.phone.tr()} ${i + 2}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
                              ),
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeMorePhone(i)),
                        ],
                      ),
                    )),
                    if (_morePhonesControllers.isNotEmpty) const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addMorePhone,
                      icon: const Icon(Icons.add),
                      label: Text('${AppStrings.phone.tr()} (${AppStrings.addOne.tr()})', style: const TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                    ),
                    const SizedBox(height: 8),
                    _buildField(controller: _emailController, label: AppStrings.email.tr(), hint: AppStrings.email.tr(), keyboardType: TextInputType.emailAddress),
                    _buildField(controller: _whatsappController, label: AppStrings.whatsapp.tr(), hint: AppStrings.whatsapp.tr(), keyboardType: TextInputType.phone),
                    _buildField(controller: _linkedinController, label: AppStrings.linkedin.tr(), hint: 'https://linkedin.com/company/...', keyboardType: TextInputType.url),
                    _buildField(controller: _behanceController, label: AppStrings.behance.tr(), hint: 'https://behance.net/...', keyboardType: TextInputType.url),
                    _buildField(controller: _websiteController, label: AppStrings.website.tr(), hint: 'https://...', keyboardType: TextInputType.url),
                    ...List.generate(_otherLinksControllers.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _otherLinksControllers[i],
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: '${AppStrings.website.tr()} / URL ${i + 1}',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
                              ),
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => _removeOtherLink(i)),
                        ],
                      ),
                    )),
                    if (_otherLinksControllers.isNotEmpty) const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _addOtherLink,
                      icon: const Icon(Icons.add),
                      label: Text('${AppStrings.website.tr()} / URL (${AppStrings.addOne.tr()})', style: const TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                    ),
                  ],
                  if (_selectedTabIndex == 2) ...[
                    // country key is filled automatically from selected country (phone_code) and sent only to API – not shown in UI
                    _buildField(controller: _aboutController, label: AppStrings.aboutComapny.tr(), hint: AppStrings.aboutMe.tr(), maxLines: 4),
                    _buildField(controller: _businessController, label: AppStrings.business.tr(), hint: AppStrings.business.tr()),
                  ],
                  if (_selectedTabIndex == 3) ...[
                    _sectionTitle(AppStrings.portfolio.tr()),
                    ...List.generate(_portfolioNames.length, (i) => _buildPortfolioItem(i)),
                    OutlinedButton.icon(
                      onPressed: _addPortfolio,
                      icon: const Icon(Icons.add),
                      label: Text(AppStrings.addPortfolio.tr(), style: const TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                    ),
                    if (!_isPremium) ...[

                      _sectionTitle(AppStrings.gallery.tr()),
                      if (_worksGallery.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_worksGallery.length, (i) {
                            final value = _worksGallery[i];
                            final urlOrBase64 = _mediaDisplayUrl(value);
                            ImageProvider? provider;
                            if (urlOrBase64 != null) {
                              if (urlOrBase64.startsWith('http') || urlOrBase64.startsWith('https')) {
                                provider = NetworkImage(urlOrBase64);
                              } else {
                                try {
                                  provider = MemoryImage(base64Decode(urlOrBase64));
                                } catch (_) {}
                              }
                            }
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black12),
                                    color: Colors.grey.shade200,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: provider != null
                                      ? Image(image: provider, fit: BoxFit.cover)
                                      : const Icon(Icons.image, size: 32),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _worksGallery.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            );
                          }),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickWorksImages,
                        icon: const Icon(Icons.photo_library),
                        label: Text(AppStrings.gallery.tr(), style: const TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                      ),
                      const SizedBox(height: 16),
                      _sectionTitle(AppStrings.videos.tr()),
                      if (_videoGallery.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_videoGallery.length, (i) {
                            final value = _videoGallery[i];
                            final urlOrBase64 = _mediaDisplayUrl(value);
                            final isUrl = urlOrBase64 != null && urlOrBase64.startsWith('https');
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black12),
                                    color: Colors.grey.shade200,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: isUrl
                                      ? Image.network(_videoGallery[i]['thumbnail'], fit: BoxFit.cover)
                                      : const Icon(Icons.videocam, size: 32),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _videoGallery.removeAt(i);
                                    });
                                  },
                                ),
                              ],
                            );
                          }),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickVideos,
                        icon: const Icon(Icons.video_library),
                        label:  Text(AppStrings.videos.tr(), style: TextStyle(fontSize: 16)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.black)),
                      ),
                    ],
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(AppColors.dark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                        : Text(AppStrings.update.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/authentication/login/data/saved_account.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet listing the accounts that logged in before on this domain.
/// Returns the tapped [SavedAccount] (to fill the login form), or `null` when
/// closed. Deleting stays inside the sheet through [onDelete].
class SavedAccountsSheet extends StatefulWidget {
  const SavedAccountsSheet({
    super.key,
    required this.accounts,
    required this.onDelete,
  });

  final List<SavedAccount> accounts;
  final Future<void> Function(SavedAccount account) onDelete;

  static Future<SavedAccount?> show(
    BuildContext context, {
    required List<SavedAccount> accounts,
    required Future<void> Function(SavedAccount account) onDelete,
  }) {
    return showModalBottomSheet<SavedAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SavedAccountsSheet(accounts: accounts, onDelete: onDelete),
    );
  }

  @override
  State<SavedAccountsSheet> createState() => _SavedAccountsSheetState();
}

class _SavedAccountsSheetState extends State<SavedAccountsSheet> {
  late List<SavedAccount> _accounts = List.of(widget.accounts);

  Future<void> _confirmDelete(SavedAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(AppStrings.removeSavedAccountQuestion.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.delete.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.onDelete(account);
    if (!mounted) return;
    setState(() => _accounts.removeWhere((a) => a.id == account.id));
    if (_accounts.isEmpty) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(12.r),
        constraints: BoxConstraints(maxHeight: 0.6.sh),
        // Material (not a decorated Container) paints the background, so the ListTile
        // ink splashes are drawn on it instead of being hidden behind it.
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    AppStrings.savedAccounts.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Color(AppColors.buttons),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
                  child: Text(
                    AppStrings.tapToFillLoginForm.tr(),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _accounts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      return ListTile(
                        leading: _AccountAvatar(account: account),
                        title: Text(
                          account.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        trailing: IconButton(
                          tooltip: AppStrings.delete.tr(),
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _confirmDelete(account),
                        ),
                        onTap: () => Navigator.pop(context, account),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The user's photo; falls back to a person icon while the photo is unknown
/// or when it fails to load.
class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.account});

  final SavedAccount account;

  @override
  Widget build(BuildContext context) {
    final blue = Color(AppColors.buttons);
    final size = 44.r;
    final fallback = Icon(Icons.person, color: blue, size: 24.r);

    Widget child = fallback;
    if (account.avatar.isNotEmpty) {
      child = ClipOval(
        child: kIsWeb
            ? Image.network(
                account.avatar,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : CachedNetworkImage(
                imageUrl: account.avatar,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: blue.withOpacity(0.12),
      child: child,
    );
  }
}

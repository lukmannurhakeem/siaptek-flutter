import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/local_storage_constant.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    userName =
        LocalStorageService.getString(LocalStorageConstant.userFirstName) +
        ' ' +
        LocalStorageService.getString(LocalStorageConstant.userLastName);
    userEmail = LocalStorageService.getString(LocalStorageConstant.userEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth,
      padding: context.paddingAll,
      child: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.zero,
          child: Container(
            width: context.screenWidth,
            padding: context.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Edit',
                    textAlign: TextAlign.center,
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // makes both children fill vertically
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            // center the icon vertically
                            child: Icon(Icons.person, size: 40, color: context.colors.primary),
                          ),
                        ),
                      ),
                      context.hM,
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPT 23009',
                              textAlign: TextAlign.center,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                            context.vS,
                            Text(
                              userName ?? '',
                              textAlign: TextAlign.center,
                              style: context.topology.textTheme.titleMedium?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                            context.vS,
                            Text(
                              'Head of Operation',
                              textAlign: TextAlign.center,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                            context.vS,
                            Text(
                              userEmail ?? '',
                              textAlign: TextAlign.center,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                context.vM,
                context.divider,
                context.vM,
                Text(
                  'Connected Device',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vS,
                _deviceList(true, 'SM-T733', 'Last used on : 7/17/2025, 5:13:18 PM'),
                context.vS,
                _deviceList(false, 'iPhone 13', 'Last used on : 7/4/2025, 12:23:41 AM'),
                context.vS,
                _deviceList(false, 'iPhone 15', 'Last used on : 6/3/2025, 8:35:01 AM'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _deviceList(bool isAndroid, String deviceName, String deviceLogin) {
    return Row(
      children: [
        Icon(isAndroid ? Icons.phone_android : Icons.phone_iphone, color: context.colors.primary),
        context.hS,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deviceName,
              textAlign: TextAlign.center,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
            Text(
              deviceLogin,
              textAlign: TextAlign.center,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}

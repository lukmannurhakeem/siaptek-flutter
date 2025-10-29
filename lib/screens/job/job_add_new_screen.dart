import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobAddNewScreen extends StatefulWidget {
  const JobAddNewScreen({super.key});

  @override
  State<JobAddNewScreen> createState() => _JobAddNewScreen();
}

class _JobAddNewScreen extends State<JobAddNewScreen> {
  @override
  void initState() {
    super.initState();
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.fetchCustomers(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image at bottom right
        Positioned(
          bottom: 0,
          right: 0,
          child: Image.asset(
            'assets/images/bg_2.png',
            fit: BoxFit.contain,
            alignment: Alignment.bottomRight,
            height: context.screenHeight * 0.70,
          ),
        ),

        // Foreground content
        Container(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          padding: context.paddingHorizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              context.vXxl,

              // Customer Dropdown
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Customer',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Consumer2<CustomerProvider, SiteProvider>(
                      builder: (context, customerProvider, siteProvider, _) {
                        final customers = customerProvider.customers;

                        return DropdownButtonFormField<String>(
                          value: siteProvider.selectedCustomerId,
                          decoration: InputDecoration(
                            hintText: 'Select Customer',
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            hintStyle: context.topology.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          items:
                              customers.map((customer) {
                                return DropdownMenuItem<String>(
                                  value: customer.customerid,
                                  child: Text(
                                    customer.customername ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            siteProvider.setSelectedCustomer(value);
                            // Clear site selection when customer changes
                            siteProvider.setSelectedCustomerById(null);
                            // Fetch sites for the selected customer
                            if (value != null) {
                              siteProvider.fetchSiteByCustomerId(context, value);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Site Dropdown
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Site',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Consumer<SiteProvider>(
                      builder: (context, siteProvider, _) {
                        final sites = siteProvider.sitesCustomerList;
                        final isEnabled =
                            siteProvider.selectedCustomerId != null && sites.isNotEmpty;

                        return DropdownButtonFormField<String>(
                          value: siteProvider.selectedCustomerIdSite,
                          decoration: InputDecoration(
                            hintText:
                                siteProvider.selectedCustomerId == null
                                    ? 'Select Site First'
                                    : (sites.isEmpty ? 'No Sites Available' : 'Select Site'),
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            hintStyle: context.topology.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          items:
                              sites.map((site) {
                                return DropdownMenuItem<String>(
                                  value: site.siteid,
                                  child: Text(
                                    '${site.siteName ?? site.siteCode ?? '-'} (${site.siteCode ?? ''})',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged:
                              isEnabled
                                  ? (value) {
                                    siteProvider.setSelectedCustomerById(value);
                                  }
                                  : null,
                        );
                      },
                    ),
                  ),
                ],
              ),

              context.vXxl,

              Consumer<SiteProvider>(
                builder: (context, value, child) {
                  return CommonButton(
                    onPressed:
                        (value.selectedCustomerIdSite == '')
                            ? null
                            : () {
                              NavigationService().navigateTo(
                                AppRoutes.jobAddNewDetailsScreen,
                                arguments: {
                                  'customer': value.selectedCustomerId,
                                  'site': value.selectedCustomerIdSite,
                                },
                              );
                            },
                    text: 'Next',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

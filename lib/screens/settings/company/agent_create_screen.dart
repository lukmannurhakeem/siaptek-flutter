import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/agent_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgentCreateScreen extends StatefulWidget {
  const AgentCreateScreen({super.key});

  @override
  State<AgentCreateScreen> createState() => _AgentCreateScreenState();
}

class _AgentCreateScreenState extends State<AgentCreateScreen> {
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title,
    Widget child, {
    bool isRequired = false,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    title + (isRequired ? ' *' : ''),
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(flex: 3, child: child),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, AgentProvider agentProvider) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          context.vM,
          _buildSectionHeader(context, 'Basic Information', Icons.person_outlined),
          context.vM,
          _buildRow(
            context,
            'Agent Name',
            CommonTextField(
              hintText: 'Enter Agent Name',
              controller: agentProvider.agentnameController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            isRequired: true,
            icon: Icons.person_outline,
          ),
          context.vS,
          _buildRow(
            context,
            'Account Code',
            CommonTextField(
              hintText: 'Enter Account Code',
              controller: agentProvider.accountcodeController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            isRequired: true,
            icon: Icons.tag,
          ),
          context.vL,
          _buildSectionHeader(context, 'Additional Details', Icons.description_outlined),
          context.vM,
          _buildRow(
            context,
            'Notes',
            CommonTextField(
              hintText: 'Enter Notes',
              controller: agentProvider.notesController,
              maxLines: 3,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.notes,
          ),
          context.vS,
          _buildRow(
            context,
            'Address',
            CommonTextField(
              hintText: 'Enter Address',
              controller: agentProvider.addressController,
              maxLines: 2,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.location_on_outlined,
          ),
          context.vL,
          CommonButton(
            text: _isLoading ? 'Saving...' : 'Save Agent',
            onPressed: _isLoading ? null : () => _saveAgent(agentProvider),
          ),
          context.vL,
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AgentProvider agentProvider) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Basic Information', Icons.person_outlined),
                        context.vM,
                        _buildRow(
                          context,
                          'Agent Name',
                          CommonTextField(
                            hintText: 'Enter Agent Name',
                            controller: agentProvider.agentnameController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          isRequired: true,
                          icon: Icons.person_outline,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Account Code',
                          CommonTextField(
                            hintText: 'Enter Account Code',
                            controller: agentProvider.accountcodeController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          isRequired: true,
                          icon: Icons.tag,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
                context.hXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          'Additional Details',
                          Icons.description_outlined,
                        ),
                        context.vM,
                        _buildRow(
                          context,
                          'Notes',
                          CommonTextField(
                            hintText: 'Enter Notes',
                            controller: agentProvider.notesController,
                            maxLines: 3,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.notes,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Address',
                          CommonTextField(
                            hintText: 'Enter Address',
                            controller: agentProvider.addressController,
                            maxLines: 2,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.location_on_outlined,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          context.vL,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: CommonButton(
                  text: _isLoading ? 'Saving...' : 'Save Agent',
                  onPressed: _isLoading ? null : () => _saveAgent(agentProvider),
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  void _saveAgent(AgentProvider agentProvider) {
    // Validate required fields
    if (agentProvider.agentnameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please enter agent name')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (agentProvider.accountcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please enter account code')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    agentProvider
        .createAgent(context)
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Error: ${error.toString()}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Create Agent',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: context.colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Saving agent...',
                      style: context.topology.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              )
            : (context.isTablet
                ? _buildTabletLayout(context, agentProvider)
                : _buildMobileLayout(context, agentProvider)),
      ),
    );
  }
}
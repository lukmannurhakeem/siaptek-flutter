import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/service/service_locator.dart';
import 'package:INSPECT/model/get_agent_model.dart';
import 'package:INSPECT/repositories/agent/agent_repository.dart';
import 'package:INSPECT/widget/common_snackbar.dart';
import 'package:flutter/material.dart';

class AgentProvider extends ChangeNotifier {
  final AgentRepository _agentRepository = ServiceLocator().agentRepository;

  // TextEditingControllers
  final TextEditingController agentnameController = TextEditingController();
  final TextEditingController accountcodeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  GetAgentModel? _getAgentModel;

  GetAgentModel? get getAgentModel => _getAgentModel;

  List<Agent> _agents = [];

  List<Agent> get agents => _agents;

  // Loading states
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isFetching = false;

  bool get isFetching => _isFetching;

  bool _isCreating = false;

  bool get isCreating => _isCreating;

  // Expose repository for direct access
  AgentRepository get agentRepository => _agentRepository;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetching(bool value) {
    _isFetching = value;
    notifyListeners();
  }

  void _setCreating(bool value) {
    _isCreating = value;
    notifyListeners();
  }

  // Fetch agents list
  Future<void> fetchAgents(BuildContext context) async {
    _setFetching(true);
    try {
      final model = await _agentRepository.fetchAgents();
      _getAgentModel = model;
      _agents = model.agents ?? [];
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    } finally {
      _setFetching(false);
    }
  }

  // Create new agent
  Future<void> createAgent(BuildContext context) async {
    _setCreating(true);
    _setLoading(true);
    try {
      await _agentRepository.createAgent(
        agentname: agentnameController.text,
        accountcode: accountcodeController.text,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        address: addressController.text.isNotEmpty ? addressController.text : null,
      );

      await fetchAgents(context);
      NavigationService().goBack();
      CommonSnackbar.showSuccess(context, "Agent created successfully");

      // Clear controllers after successful creation
      _clearControllers();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    } finally {
      _setCreating(false);
      _setLoading(false);
    }
  }

  void _clearControllers() {
    agentnameController.clear();
    accountcodeController.clear();
    notesController.clear();
    addressController.clear();
  }

  // Dispose controllers
  @override
  void dispose() {
    agentnameController.dispose();
    accountcodeController.dispose();
    notesController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

import 'package:INSPECT/core/service/offline_http_service.dart';
import 'package:INSPECT/model/get_agent_model.dart';
import 'package:INSPECT/repositories/agent/agent_repository.dart';
import 'package:INSPECT/route/endpoint.dart';

class AgentImpl implements AgentRepository {
  final OfflineHttpService _api;

  AgentImpl(this._api);

  @override
  Future<GetAgentModel> fetchAgents() async {
    final response = await _api.get(Endpoint.agent, requiresAuth: true);
    return GetAgentModel.fromJson(response.data);
  }

  @override
  Future<void> createAgent({
    required String agentname,
    required String accountcode,
    String? notes,
    String? address,
  }) async {
    final response = await _api.post(
      Endpoint.createAgent,
      requiresAuth: true,
      data: {
        'agentname': agentname,
        'accountcode': accountcode,
        if (notes != null) 'notes': notes,
        if (address != null) 'address': address,
      },
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Agent saved locally. Will sync when online.');
    }
  }
}
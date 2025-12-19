import 'package:INSPECT/model/get_agent_model.dart';

abstract class AgentRepository {
  Future<GetAgentModel> fetchAgents();

  Future<void> createAgent({
    required String agentname,
    required String accountcode,
    String? notes,
    String? address,
  });
}
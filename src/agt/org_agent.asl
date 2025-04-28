// organization agent

/* Initial beliefs and rules */
org_name("lab_monitoring_org"). // the agent beliefs that it can manage organizations with the id "lab_monitoting_org"
group_name("monitoring_team"). // the agent beliefs that it can manage groups with the id "monitoring_team"
sch_name("monitoring_scheme"). // the agent beliefs that it can manage schemes with the id "monitoring_scheme"

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : org_name(OrgName) & group_name(GroupName) & sch_name(SchemeName) <-
	.print("Initializing organization: ", OrgName);
  
	createWorkspace(OrgName);
	joinWorkspace(OrgName, OrgWsp);
	
  makeArtifact(OrgName, "ora4mas.nopl.OrgBoard", ["src/org/org-spec.xml"], OrgBoardId)[wid(OrgWsp)];
  focus(OrgBoardId)[wid(OrgWsp)];
  .print("Organization Board created with ID: ", OrgBoardId);
	
	createGroup(GroupName, "monitoring_team", GroupId)[artifact_id(OrgBoardId)];
	focus(GroupId)[wid(OrgWsp)];
	.print("Group Board created with ID: ", GroupId);
	
	createScheme(SchemeName, "monitoring_scheme", SchemeId)[artifact_id(OrgBoardId)];
	focus(SchemeId)[wid(OrgWsp)];
	.print("Scheme Board created with ID: ", SchemeId);
	
	.broadcast(tell, organization_ready(OrgName));
	.print("Broadcasted that organization workspace ", OrgName, " is available");
	
	?formationStatus(ok)[artifact_id(GroupId)];
	.print("Group ", GroupName, " is now well-formed");
	
	addResponsibleGroup(GroupName)[artifact_id(SchemeId)];
	.print("Made group ", GroupName, " responsible for scheme ", SchemeName);
	
	!inspect(GroupId).

/* 
 * Plan for reacting to the addition of the test-goal ?formationStatus(ok)
 * Triggering event: addition of goal ?formationStatus(ok)
 * Context: the agent beliefs that there exists a group G whose formation status is being tested
 * Body: if the belief formationStatus(ok)[artifact_id(G)] is not already in the agents belief base
 * the agent waits until the belief is added in the belief base
*/
@test_formation_status_is_ok_plan
+?formationStatus(ok)[artifact_id(G)] : group(GroupName,_,G)[artifact_id(OrgName)] <-
  .print("Waiting for group ", GroupName," to become well-formed");
  .wait({+formationStatus(ok)[artifact_id(G)]}). // waits until the belief is added in the belief base

/* 
 * Plan for reacting to the addition of the goal !inspect(OrganizationalArtifactId)
 * Triggering event: addition of goal !inspect(OrganizationalArtifactId)
 * Context: true (the plan is always applicable)
 * Body: performs an action that launches a console for observing the organizational artifact 
 * identified by OrganizationalArtifactId
*/
@inspect_org_artifacts_plan
+!inspect(OrganizationalArtifactId) : true <-
  // performs an action that launches a console for observing the organizational artifact
  // the action is offered as an operation by the superclass OrgArt (https://moise.sourceforge.net/doc/api/ora4mas/nopl/OrgArt.html)
  debug(inspector_gui(on))[artifact_id(OrganizationalArtifactId)]. 

/* 
 * Plan for reacting to the addition of the belief play(Ag, Role, GroupId)
 * Triggering event: addition of belief play(Ag, Role, GroupId)
 * Context: true (the plan is always applicable)
 * Body: the agent announces that it observed that agent Ag adopted role Role in the group GroupId.
 * The belief is added when a Group Board artifact (https://moise.sourceforge.net/doc/api/ora4mas/nopl/GroupBoard.html)
 * emmits an observable event play(Ag, Role, GroupId)
*/
@play_plan
+play(Ag, Role, GroupId) : true <-
  .print("Agent ", Ag, " adopted the role ", Role, " in group ", GroupId).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }
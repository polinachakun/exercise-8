// acting agent

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://ci.mines-stetienne.fr/kg/ontology#PhantomX
robot_td("https://raw.githubusercontent.com/Interactions-HSG/example-tds/main/tds/leubot1.ttl").

/* Initial beliefs and rules */
// Keep track of roles already adopted
adopted_role(none).
// Keep track of workspaces joined
joined_workspace(main). 
// Keep track of roles already adopted
adopted_role(none).

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").

/* 
 * Plan for reacting to the addition of the goal !manifest_temperature
 * Triggering event: addition of goal !manifest_temperature
 * Context: the agent believes that there is a temperature in Celsius and
 * that a WoT TD of an onto:PhantomX is located at Location
 * Body: converts the temperature from Celsius to binary degrees that are compatible with the 
 * movement of the robotic arm. Then, manifests the temperature with the robotic arm
*/
@manifest_temperature_plan 
+!manifest_temperature : temperature(Celsius) & robot_td(Location) <-
	.print("I will manifest the temperature: ", Celsius);
	makeArtifact("converter", "tools.Converter", [], ConverterId); // creates a converter artifact
	convert(Celsius, -20.00, 20.00, 200.00, 830.00, Degrees)[artifact_id(ConverterId)]; // converts Celsius to binary degress based on the input scale
	.print("Temperature Manifesting (moving robotic arm to): ", Degrees);

	/* 
	 * If you want to test with the real robotic arm, 
	 * follow the instructions here: https://github.com/HSG-WAS-FS25/exercise-8/blob/main/README.md#test-with-the-real-phantomx-reactor-robot-arm
	 */
	// creates a ThingArtifact based on the TD of the robotic arm
	makeArtifact("leubot1", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Location, true], Leubot1Id); 
	
	// sets the API key for controlling the robotic arm as an authenticated user
	//setAPIKey("77d7a2250abbdb59c6f6324bf1dcddb5")[artifact_id(Leubot1Id)];

	// invokes the action onto:SetWristAngle for manifesting the temperature with the wrist of the robotic arm
	invokeAction("https://ci.mines-stetienne.fr/kg/ontology#SetWristAngle", ["https://www.w3.org/2019/wot/json-schema#IntegerSchema"], [Degrees])[artifact_id(Leubot1Id)].


@role_available_plan
+role_available(Role, OrgName) : adopted_role(none) | adopted_role(Role) <-
    .print("Role ", Role, " is available in organization ", OrgName, ". Checking...");
    
    // Join the organization workspace only if not already joined
    if (not joined_workspace(OrgName)) {
        joinWorkspace(OrgName, OrgWsp);
        +joined_workspace(OrgName);
        .print("Joined workspace: ", OrgName);
    } else {
        .print("Already joined workspace: ", OrgName);
    }
    
    lookupArtifact(OrgName, OrgBoardId)[wid(OrgWsp)];
    focus(OrgBoardId)[wid(OrgWsp)];
    .print("Focused on Organization Board: ", OrgBoardId);
    
    // Find and focus on Group Board and Scheme Board
    for (group(GroupName, _, GroupBoardId)[artifact_id(OrgBoardId)]) {
        focus(GroupBoardId)[wid(OrgWsp)];
        .print("Focused on Group Board: ", GroupBoardId, " for group ", GroupName);
        
        if (adopted_role(none)) {
            .print("Adopting role: ", Role);
            adoptRole(Role)[artifact_id(GroupBoardId)];
            -+adopted_role(Role); 
            .print("Adopted role: ", Role, " in group ", GroupName);
        }
    }
    
    // Focus on scheme board
    for (scheme(SchemeName, _, SchemeBoardId)[artifact_id(OrgBoardId)]) {
        focus(SchemeBoardId)[wid(OrgWsp)];
        .print("Focused on Scheme Board: ", SchemeBoardId, " for scheme ", SchemeName);
    }.

// Ignore role availability messages if a different role was already adopted 
@role_available_other_plan
+role_available(Role, OrgName) : adopted_role(CurrentRole) & CurrentRole \== none & CurrentRole \== Role <-
    .print("Ignoring role ", Role, " as I've already adopted role ", CurrentRole).


@obligation_achieved_plan
+obligation(Ag,Norm,what(achieved(Scheme,Goal,Ag)),Deadline)[artifact_id(ArtId)] : .my_name(Ag) <-
    .print("I am obliged to achieve goal ", Goal, " in scheme ", Scheme);
    !Goal[scheme(Scheme)];
    .print("Goal ", Goal, " achieved!");
    goalAchieved(Goal)[artifact_id(ArtId)].

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }

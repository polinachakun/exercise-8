// sensing agent


/* Initial beliefs and rules */

/* Define a rule to find roles that the agent can adopt */
can_achieve(Goal) :- .plan_label(_,_,_,{ +!Goal[_|_] },_).
relevant_role(Role, Org) :- 
    role(Role,Org) & 
    mission_goal(Mission,Goal) & 
    mission_role(Mission,Role) & 
    can_achieve(Goal).

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
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
    .print("I will read the temperature");
    makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
    focus(WeatherStationId); // focuses on the weather station artifact
    readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
    .print("Temperature Reading (Celcius): ", Celcius);
    .broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

@organization_ready_plan
+organization_ready(OrgName) <-
    .print("Organization workspace ", OrgName, " is available. Joining...");
    joinWorkspace(OrgName, OrgWsp);
    
    lookupArtifact(OrgName, OrgBoardId)[wid(OrgWsp)];
    focus(OrgBoardId)[wid(OrgWsp)];
    .print("Focused on Organization Board: ", OrgBoardId);
    
    // Find group and scheme boards more directly
    for (group(GroupName, _, GroupId)[artifact_id(OrgBoardId)]) {
        focus(GroupId)[wid(OrgWsp)];
        .print("Focused on Group Board: ", GroupId, " for group ", GroupName);
    }
    
    for (scheme(SchemeName, _, SchemeId)[artifact_id(OrgBoardId)]) {
        focus(SchemeId)[wid(OrgWsp)];
        .print("Focused on Scheme Board: ", SchemeId, " for scheme ", SchemeName);
    }
    
    // Start reasoning about roles to adopt
    !adopt_relevant_roles(OrgName).


//Plan for adopting relevant roles based on capabilities
@adopt_relevant_roles_plan
+!adopt_relevant_roles(OrgName) <-
    .print("Reasoning on organization to find relevant roles...");
    
    // We specifically want to adopt the temperature_reader role
    // since this agent has the capability to read temperature
    ?group(GroupName, _, GroupId);
    adoptRole(temperature_reader)[artifact_id(GroupId)];
    .print("Adopted role: temperature_reader in group ", GroupName).
 
// Plan for reacting to goal obligation events from organization
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
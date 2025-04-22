/*
	Additional agent skills for reacting to organizational events
	(if observing, i.e. being focused on the appropriate organization artifacts)
*/

/*
	React to an event of a normative board artifact with id NormArtId being
	available for a scheme Scheme. React by focusing on the artifact
*/
+normative_board(Scheme, NormArtId) : true
<-
	focus(NormArtId).

/*
	React to an event of an obligation being assigned to agent Ag based on a
	norm Norm (reason for obligation generation) with a goal committed(Ag,Mission,Scheme).
	The goal indicates that the agent Ag must commit to mission Mission in the
	context of the scheme Scheme before the deadline Deadline is due

	The agent Ag reacts by looking up and focusing on the relevant scheme Board
	artifact, and then, commiting to the mission Mission using the artifact
*/
+obligation(Ag,Norm,committed(Ag,Mission,Scheme),Deadline)
	: .my_name(Ag)
<-
	.print("I am obliged to commit to ", Mission, " on ", Scheme);
	lookupArtifact(Scheme, SchemeArtId);
	focus(SchemeArtId);
	commitMission(Mission)[artifact_id(SchemeArtId)].

/*
	React to an event of an obligation being assigned to agent Ag based on a
	norm Norm (reason for obligation generation) with a goal done(Scheme,Goal,Ag).
	The goal indicates that the goal Goal must be achieved by agent Ag in the
	context of the scheme Scheme before the deadline Deadline is due.

	The agent Ag reacts by executing a plan for the goal Goal, and then,
	setting the goal as performed using the relevant scheme board artifact
*/
+obligation(Ag,Norm,done(Scheme,Goal,Ag),Deadline)
	: .my_name(Ag)
<-
	.println("I am obliged to achieve goal ",Goal, " on ", Scheme);
	lookupArtifact(Scheme, SchemeArtId);
  !Goal[scheme(Scheme)];
  goalAchieved(Goal)[artifact_id(SchemeArtId)].

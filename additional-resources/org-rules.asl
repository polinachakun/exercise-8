
//Organizational rules available in https://github.com/moise-lang/moise/blob/master/src/main/resources/asl/org-rules.asl

/*
  Infer that the organization specification specifies a role type R
  that is a subtype of role type Super
*/
role(R,Super) :-
   specification(os(_,G,_,_)) &
   role(R,Super,G).

/*
  Infer that the organization specification specifies a role type R
  that is a subtype of role types SuperRoles defined in a group specification
*/
role(R,SuperRoles,group_specification(Gr,Roles,SubGroups,Props)) :-
   .member( role(R,SubRoles,SuperRoles,Min,Max,Compats,Links), Roles).

/*
  Infer that the organization specification specifies a role type R
  that is a subtype of role type Super defined in a group specification
*/
role(R,Super,group_specification(Gr,Roles,SubGroups,Props)) :-
   .member( subgroup(Min,Max,G), SubGroups) & role(R,Super,G).

/*
  Infer that the organization specification specifies a role type R
  that is a subtype of role type S related to a mission MT
*/
role_mission(Role,S,MT) :-
   specification(os(_,_,_,Norms)) &
   .print(Role, S, MT) &
   role(Role,Super) &
   .member(R,[Role|Super]) & // for all super roles
   .member(norm(Id,R,_,MS),Norms) &
   .substring(".",MS,P) &
   .substring(MS,M,P+1) &
   .term2string(MT,M) &
   .substring(MS,SS,0,P) &
   .term2string(S,SS).

/*
   Infer that the organization specification specifies a goal G that is relevant
   for accomplishing the mission MT
*/
mission_goal(MT,G) :-
   specification(os(_,_,Schemes,_)) &
   .member(scheme_specification(S,RootGoal,Missions,Pros),Schemes) &
   .member(mission(MT,Min,Max,Goals,_),Missions) &
   .member(G,Goals).

/*
  Infer that the organization specification specifies a role type R that should
  played by at least Min number of agents and at most Max number of agents
*/
role_cardinality(R,Min,Max) :-
   specification(os(_,G,_,_)) &
   role_cardinality(R,Min,Max,G).

/*
   Infer that the organization specification specifies a role type R, defined
   in a group specification, that should played by at least Min number of agents
   and at most Max number of agents.
*/
role_cardinality(R,Min,Max,group_specification(Gr,Roles,SubGroups,Props)) :-
   .member( role(R,SubRoles,SuperRoles,Min,Max,Compats,Links), Roles).

/*
  Infer that the organization specification specifies a role type R, defined
  in a group specification, that should played by at least Min number of agents
  and at most Max number of agents.
*/
role_cardinality(R,Min,Max,group_specification(Gr,Roles,SubGroups,Props)) :-
   .member( subgroup(_,_,G), SubGroups) & role_cardinality(R,Min,Max,G).

lparameters toProject, ;
	tcOutputName, ;
	tnBuildAction, ;
	tlShowErrors, ;
	tlBuildNewGUIDs
return toProject.Build(tcOutputName, int(tnBuildAction), .F., tlShowErrors, ;
	tlBuildNewGUIDs)

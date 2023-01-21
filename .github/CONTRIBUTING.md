# How to contribute to Project Explorer

## Report a bug
- Please check [issues](https://github.com/DougHennig/ProjectExplorer/issues) if the bug has already been reported.

- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

## Fix a bug or add an enhancement
- Fork the project: see this [guide](https://www.dataschool.io/how-to-contribute-on-github/) for setting up and using a fork.

- Make whatever changes are necessary.

- If this is a new major release, edit the Version setting in *BuildProcess\ProjectSettings.txt*.

- If you added or removed files, update *BuildProcess\InstalledFiles.txt* as necessary.

- Describe the changes at the top of *ChangeLog.md*.

- If you haven't already done so, install VFPX Deployment: choose Check for Updates from the Thor menu, turn on the checkbox for VFPX Deployment, and click Install.

- Start VFP 9 (not VFP Advanced) and CD to the Project Explorer folder.

- Run the VFPX Deployment tool to create the installation files: choose VFPX Project Deployment from the Thor Tools, Application menu. Alternately, execute ```EXECSCRIPT(_screen.cThorDispatcher, 'Thor_Tool_DeployVFPXProject')```.

- Commit the changes.

- Push to your fork.

- Create a pull request; ensure the description clearly describes the problem and solution or the enhancement.

----
Last changed: 2023-01-21
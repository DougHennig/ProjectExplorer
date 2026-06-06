# Project Explorer

Project Explorer replaces the VFP Project Manager with a modern interface and modern capabilities.

## Release History

### 2026-05-12: version 1.0.09628

* Added an option to automatically activate a VFP project when it's selected in Project Explorer (pull request 229 by Nicola Marangon).

* Fixed an issue in AddCmdWindow.prg when there's a space in the path (issue #227).

* Fixed an incorrect tooltip for the Clear button in the Sort and Filter dialog (issue #228).

* Project Explorer no longer gives an error if you run the main program and it does a CLEAR ALL.

### 2025-05-22, version 1.0.09273

* A tag starting with "Code" no longer conflicts with the built-in Code tag.

* Project Explorer no longer adds a file with the same name as an existing file but in a different folder.

### 2024-03-10, Version 1.0.08835

* The EditFile method now returns .F. if it can't edit the file (for example, the specified file isn't part of the project).

### 2024-01-13, Version 1.0.08778

* Restores the former dock position of the form when it's opened (issue #223).

* Handle tags with special characters (issue #211).

* Automated generation of version number when using VFPX Deployment.

* ProjectExplorerForm.SelectNodeForFile: return .T. if an item was selected in the TreeView.

### 2023-03-05, Version 1.0.08464

* Added support for editing an MPR in the project as a program (issue #220).

* Fixed an issue with Project Explorer hanging after saving changes to a file under some conditions (issue #219).

### 2023-01-21, Version 1.0.08421

* Added a new add-in, SetCurDirOnProjectOpen.prg, which automatically does a CD to the solution's folder when a solution is opened.

* Added support for [VFPX Deployment](https://github.com/VFPX/VFPXDeployment) as the deployment mechanism.

### 2022-06-15, Version 1.0.8201

* Fixed a bug: when adding a file, it doesn't appear in "All" until you close and reopen Project Explorer.

* Fixed a bug: binary files show with version control status "?" (unknown) if only text equivalents are included in the repository and there is no .gitignore or it doesn't exclude binary files.

### 2022-03-26, Version 1.0.8120

* Added support for binary-to-text conversion using Christof Wollenhaupt's TwoFox.

* Added support for selecting which binary-to-text converter to use on a project-by-project basis (for example, one project may use FoxBin2PRG while another uses TwoFox).

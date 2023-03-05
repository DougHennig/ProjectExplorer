# Project Explorer

Project Explorer replaces the VFP Project Manager with a modern interface and modern capabilities.

## Release History

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

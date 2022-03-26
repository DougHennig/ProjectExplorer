# Project Explorer

The Project Manager is one of the oldest tools built into VFP, and it has showed its age for a long time. For example, it doesn't provide integration with modern distributed version control systems (DVCS) such as Mercurial and Git, it doesn't have a way to filter or organize the list of items, and it can only work with one project at a time.

Project Explorer is a VFPX project that replaces the Project Manager with a modern interface and modern capabilities. It has most of the features of the Project Manager but adds integration with DVCS (including built-in support for FoxBin2PRG and optional auto-commit after changes), support for multiple projects within a "solution," allows you to organize your items by keyword or other criteria, and has support for easy "auto-registering" addins that can customize the appearance and behavior of the tool.

See [ProjectExplorer.pdf](ProjectExplorer.pdf) for documentation on Project Explorer.

A [video](https://youtu.be/G43sUwYlDJ0) is available showing Project Explorer and how it works.

## Releases

### 2022-03-26

* Added support for binary-to-text conversion using Christof Wollenhaupt's TwoFox

* Added support for selecting which binary-to-text converter to use on a project-by-project basis (for example, one project may use FoxBin2PRG while another uses TwoFox).
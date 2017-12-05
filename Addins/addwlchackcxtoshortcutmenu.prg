******************************************************************************************
*  PROGRAM: AddWLCHackCXtoShortcutMenu.prg
*
*  AUTHOR: 
*     Richard A. Schummer, November 2017
*     White Light Computing, Inc.
*     PO Box 391
*     Washington Twp., MI  48094
*     raschummer@whitelightcomputing.com
*
*  LICENSE FOR VFPX 
*
*  PROGRAM DESCRIPTION:
*     This program is an addin for the VFPX ProjectExplorer written by Doug Hennig. This
*     addin adds a new menu option to the ProjectExplorer shortcut menu. It is only enabled
*     for Forms and Visual Class Libraries. The code looks for a registry entry created
*     by HackCX:
*
*     HKEY_CURRENT_USER\Software\WhiteLightComputingTools\HackCX\4.0\Options\Location
*     
*     If the Registry entry is not set, use HackCX Professional, go to the Configuration page
*     and set the location using the ellipse button to locate the HackCX4.EXE on your computer.
*
*     If HackCX is not installed, or the registry is not set, the menu option is not 
*     registered and does not show up in ProjectExplorer.
*
*     NOTE: This program does use the Fox Foundation Class (FFC) Registry class.
*
*  CALLING SYNTAX:
*     Drop this into the ProjectExplorer Addin folder. No need to run it any other way.
*
*  INPUT PARAMETERS:
*     toParameter1 = a reference to an addin parameter object if only one parameter is 
*                    passed (meaning this is a registration call) or a reference to 
*                    ProjectExplorerForm object.
*     tuParameter2 = ProjectExplorerShortcutMenu object
*     tuParameter3 = Not used
*
*  OUTPUT PARAMETERS:
*     None
*
*  DATABASES ACCESSED:
*     None
* 
*  GLOBAL PROCEDURES REQUIRED:
*     None
* 
*  CODING STANDARDS:
*     Version 5.2 compliant with no exceptions
*  
*  TEST INFORMATION:
*     None
*   
*  SPECIAL REQUIREMENTS/DEVICES:
*     None
*
*  FUTURE ENHANCEMENTS:
*     None
*
*  LANGUAGE/VERSION:
*     Visual FoxPro 09.00.0000.7423 or higher
* 
******************************************************************************************
*                             C H A N G E    L O G                              
*
*    Date     Developer               Version  Description
* ----------  ----------------------  -------  ---------------------------------
* 11/29/2017  Richard A. Schummer     1.0      Created Program
* ----------------------------------------------------------------------------------------
*
******************************************************************************************
LPARAMETERS toParameter1, tuParameter2, tuParameter3

LOCAL loHackCX, ;
      lcHackCXPath, ;
      lnMenuItem

* Localization opportunities
#DEFINE ccMENU_CAPTION      "Run HackCX Professional"
#DEFINE ccTOOL_NAME         "Add HackCX Professional to Shortcut Menu"
      
* Allow you to determine the menu item number.
#DEFINE cnMENU_ITEM_NUMBER   6


* If this is a registration call, tell the addin manager which 
* method we're an addin for.
IF PCOUNT() = 1
	toParameter1.Method = "AfterCreateShortcutMenu"
	toParameter1.Active = .F.
	toParameter1.Name   = ccTOOL_NAME
	RETURN 
ENDIF 

loHackCX = CREATEOBJECT("cusGetHackCX")

IF VARTYPE(m.loHackCX) = "O"
   lcHackCXPath = ALLTRIM(m.loHackCX.cLocation)

   IF EMPTY(m.lcHackCXPath)
      * Registry entry is not set. Use HackCX Professional, go to the configuration page and
      * set the location using the ellipse button to locate the HackCX4.EXE on your computer.
   ELSE 
      * This is an addin call, so add "HackCX" as the fifth item in the treeview shortcut menu.
      tuParameter2.AddMenuBar(ccMENU_CAPTION, ;
      	                     "DO " + m.lcHackCXPath + " with loForm.oItem.Path", ;
                           	"VARTYPE(loForm.oItem) # 'O' or not (INLIST(loForm.oItem.Type, [V], [K]))", ;
                           	, cnMENU_ITEM_NUMBER)
   ENDIF 
ENDIF 

loHackCX = NULL
RELEASE loHackCX

RETURN .T.


***********************************************************************************************
*   Class:        cusGetHackCX
*   BaseClass:    Custom
*
*   This custom class provides the developer the option to hack the SCX or VCX with 
*   WLC HackCX Professional when the form or class is modified. 
*
***********************************************************************************************
DEFINE CLASS cusGetHackCX AS Custom

   * This property is an object reference to the current Registry object to access the Windows Registry.
   oRegistry    = .NULL.
   * This property contains the base registry key used to store the location of HackCX Professional.
   cRegistryKey = "Software\WhiteLightComputingTools\HackCX\"
   * This property contains the current major version number.
   cVersion     = "v4.0"
   * This property contains the location (path and EXE) for HackCX Professional.
   cLocation    = SPACE(0)

   PROCEDURE oRegistry_Access()
      * Requires the VFP Registry Fox Foundation Class (FFC).
      * You will need to hard code the path to this file if you do not have
      * this class available in the FFC folder.
      LOCAL lcHomeFFCDirectory

      lcHomeFFCDirectory = HOME()+ "FFC\"

      IF ISNULL(this.oRegistry)
         this.oRegistry = NEWOBJECT("registry", lcHomeFFCDirectory + "registry.vcx")
      ENDIF

      RETURN this.oRegistry
   ENDPROC


   *-- This method is called to get the base registry key used to store the location of White Light Computing's HackCX Professional.
   PROCEDURE GetBaseRegistryKey()
      * Registry roots (ripped off from VFP98\ffc\Registry.h)
      #DEFINE HKEY_CURRENT_USER           -2147483647  && BITSET(0,31)+1

      LOCAL lcMajorVersion, ;                && Major version used to build registry key
            lcReturnVal, ;                   && Key returned to calling method
            lcNode, ;                        && Registry Node name
            lcVersion, ;                     && Fully formatted version xx.xx.xx
            lcRegistryKey, ;                 && Main registry key for the tool
            llNewKey                         && Check to see if key is new, used to convert

      lcRegistryKey  = this.GetProp("cRegistryKey")
      lcVersion      = this.GetProp("cVersion")
      lcMajorVersion = SUBSTRC(lcVersion, 1, ATC(".", lcVersion)) + "0"
      lcMajorVersion = STRTRAN(lcMajorVersion, "v", SPACE(0))
      lcMajorVersion = STRTRAN(lcMajorVersion, "V", SPACE(0))
      lcNode         = "Options"

      * Build the base registry key
      lcReturnVal = lcRegistryKey + ;
                    lcMajorVersion + ;
                    "\" + lcNode + "\"

      * RAS 14-May-2004, Added to convert to the new registry entries
      llNewKey = this.oRegistry.IsKey(lcReturnVal,;
                                      HKEY_CURRENT_USER)

      RETURN lcReturnVal
   ENDPROC


   * This method allows developers to access the value of any property (public or protected).
   PROCEDURE GetProp()
      LPARAMETERS tcProperty
      RETURN EVAL("this." + tcProperty)
   ENDPROC


   PROCEDURE cLocation_Access()
      * Registry roots (ripped off from VFP98\ffc\Registry.h)
      #DEFINE HKEY_CLASSES_ROOT           -2147483648  && BITSET(0,31)
      #DEFINE HKEY_CURRENT_USER           -2147483647  && BITSET(0,31)+1
      #DEFINE HKEY_LOCAL_MACHINE          -2147483646  && BITSET(0,31)+2
      #DEFINE HKEY_USERS                  -2147483645  && BITSET(0,31)+3

      LOCAL lcLocation, ;
            lcToolKey

      IF NOT ISNULL(this.oRegistry)
         lcToolKey  = this.GetBaseRegistryKey()
         lcLocation = SPACE(0)

         this.oRegistry.GetRegKey("Location", ;
                                  @lcLocation,;
                                  lcToolKey,;
                                  HKEY_CURRENT_USER)
         this.cLocation = lcLocation
      ENDIF

      RETURN this.cLocation
   ENDPROC


   PROCEDURE Destroy()
      this.oRegistry = .NULL.
      RETURN
   ENDPROC

ENDDEFINE


*: EOF :*
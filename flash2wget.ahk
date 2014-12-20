; ----------------------------------------------------------------------------------------------------------------------
; Name .........: flash2wget
; Description ..: Integrate Firefox's FlashGot plugin with a remote linux wget.
; AHK Version ..: AHK_L x32/64 Unicode
; Requirements .: kscp.exe and klink.exe. Released under the MIT license by 9bis software - http://kitty.9bis.net/. 
; Author .......: Cyruz - http://ciroprincipe.info
; Changelog ....: Dic. 13, 2014 - v0.1 - First version.
; License ......: GNU General Public License
; ..............: flash2wget is free software: you can redistribute it and/or modify it under the terms of the GNU 
; ..............: General Public License as published by the Free Software Foundation, either version 3 of the License, 
; ..............: or (at your option) any later version.
; ..............: flash2wget is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
; ..............: the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General  
; ..............: Public License for more details.
; ..............: You should have received a copy of the GNU General Public License along with flash2wget. If not, see 
; ..............: <http://www.gnu.org/licenses/>.
; ----------------------------------------------------------------------------------------------------------------------

#SingleInstance force
#Persistent
#NoTrayIcon
INIFILENAME := A_ScriptDir "\flash2wget.ini"

; If the configuration file doesn't exists regenerate it.
If ( !FileExist(INIFILENAME) )
{
    MsgBox, 0x30, flash2wget, Configuration file not present. It will be created`, please update it with your settings.
    IniWrite, % "",            %INIFILENAME%, SETTINGS, SSH_IP
    IniWrite, 22,              %INIFILENAME%, SETTINGS, SSH_PORT
    IniWrite, % "",            %INIFILENAME%, SETTINGS, SSH_USER
    IniWrite, % "",            %INIFILENAME%, SETTINGS, SSH_PASSWORD
    IniWrite, % "",            %INIFILENAME%, SETTINGS, SSH_PRIVATEKEY
    IniWrite, /usr/bin/wget,   %INIFILENAME%, SETTINGS, WGET_PATH
    IniWrite, 0,               %INIFILENAME%, SETTINGS, WGET_BG
    IniWrite, /tmp/f2w_cookie, %INIFILENAME%, SETTINGS, WGET_COOKIE
    IniWrite, --continue,      %INIFILENAME%, SETTINGS, WGET_DEFOPT
    IniWrite, % "",            %INIFILENAME%, SETTINGS, WGET_DLDIR
    IniWrite, % "",            %INIFILENAME%, SETTINGS, WGET_LOGDIR
    IniWrite, 0,               %INIFILENAME%, SETTINGS, WGET_MODIFY
    IniWrite, 0,               %INIFILENAME%, SETTINGS, JOB_NOTIFY
    ExitApp
}

; Check commandline parameters.
If 0 = 0
    ExitForThisReason("No commandline parameters. What I have to do?")

; Read configuration.
IniRead, SSH_IP,         %INIFILENAME%, SETTINGS, SSH_IP,         0 ; REQUIRED
IniRead, SSH_PORT,       %INIFILENAME%, SETTINGS, SSH_PORT,       0 ; REQUIRED
IniRead, SSH_USER,       %INIFILENAME%, SETTINGS, SSH_USER,       0 ; REQUIRED
IniRead, SSH_PASSWORD,   %INIFILENAME%, SETTINGS, SSH_PASSWORD,   0 ; REQUIRED
IniRead, SSH_PRIVATEKEY, %INIFILENAME%, SETTINGS, SSH_PRIVATEKEY, 0 ; REQUIRED
IniRead, WGET_PATH,      %INIFILENAME%, SETTINGS, WGET_PATH,      0 ; REQUIRED
IniRead, WGET_BG,        %INIFILENAME%, SETTINGS, WGET_BG,        0 ; OPTIONAL
IniRead, WGET_COOKIE,    %INIFILENAME%, SETTINGS, WGET_COOKIE,    0 ; REQUIRED
IniRead, WGET_DEFOPT,    %INIFILENAME%, SETTINGS, WGET_DEFOPT,    0 ; OPTIONAL
IniRead, WGET_DLDIR,     %INIFILENAME%, SETTINGS, WGET_DLDIR,     0 ; REQUIRED
IniRead, WGET_LOGDIR,    %INIFILENAME%, SETTINGS, WGET_LOGDIR,    0 ; OPTIONAL
IniRead, WGET_MODIFY,    %INIFILENAME%, SETTINGS, WGET_MODIFY,    0 ; OPTIONAL
IniRead, JOB_NOTIFY,     %INIFILENAME%, SETTINGS, JOB_NOTIFY,     0 ; OPTIONAL

; Check configuration settings.
If  ( !SSH_IP || !SSH_PORT || !SSH_USER || !( SSH_PASSWORD || SSH_PRIVATEKEY ) 
   || !WGET_PATH || !WGET_COOKIE || !WGET_DLDIR )
    ExitForThisReason("Some required configuration settings are missing or wrong. Please check the configuration file.")

; Check if the private key file exists.
If ( SSH_PRIVATEKEY && !FileExist(SSH_PRIVATEKEY) )
    ExitForThisReason("Private key file configured but not existing.")

; Check default options. We don't want options that overlap with the ones that have a dedicated ini setting.
sOverlapRegex := "S)(?:\-{2}(?:background|directory\-prefix|output\-document|output\-file|append-output)\={1}"
              .  "|\B\-{1}\b(?:b|P|o|O|a)\b\s+)"
If ( RegExMatch(WGET_DEFOPT, sOverlapRegex) )
    ExitForThisReason( "Overlapping option found in the <WGET_DEFOPT> setting. Please note that the "
                     . "background/directory-prefix/output-document/output-file/append-output parameters have a "
                     . "dedicated setting in the configuration file." )

; Regex for the commandline parameters sent by FlashGot. The Command line arguments template must be:
; [--output-document=FNAME] [--referer=REFERER] [--post-data=POST] [--load-cookies=CFILE] [--header=Cookie:COOKIE] 
; [--user-agent=UA] [URL]
sParamRegex := "S)^(?:(\-{2}(?:output\-document|referer|load\-cookies|post\-data|header|user\-agent)\={1}))([^\n\r]+)"
            .  "|(?:https?|ftp):\/\/.*$"
aParamShort := {"--output-document=": "-O ", "--user-agent=": "-U "} ; Short parameters associative array.
Loop %0%
{
    sParam := RTrim(%A_Index%)
    If ( !RegExMatch(sParam, sParamRegex, sCapt) )
        ExitForThisReason("Wrong parameter(s). Check FlashGot's configuration.")
    ; This check is required to discriminate between the wget options and the URL.
    If ( sCapt1 != "" && sCapt2 != "" )
    {
        ; If the current parameter is in WGET_DEFOPT, avoid parsing it.
        If ( InStr(WGET_DEFOPT, sCapt1) || (aParamShort[sCapt1] && InStr(WGET_DEFOPT, aParamShort[sCapt1])) )
            Continue
        ; If we are parsing the "output-document" parameter, we modify it prefixing it with the download directory.
        Else If ( sCapt1 == "--output-document=" )
            sParam := sCapt1 "'" WGET_DLDIR "/" sCapt2 "'", sFileName := sCapt2
        ; If we are parsing the "load-cookies" parameter, we modify the cookie file path for the remote linux machine.
        Else If ( sCapt1 == "--load-cookies=" )
            sParam := sCapt1 "'" WGET_COOKIE "'", sCookieFile := sCapt2
        Else sParam := sCapt1 "'" sCapt2 "'" 
    }
    Else sParam := "'" sParam "'" ; It's the URL.
    sParamString .= sParam " "
}
StringTrimRight, sParamString, sParamString, 1

; Prepare the wget commandline.
; (We manage the --background parameter separated from the others, so we eventually remove it from default options).
sWgetCmdline := WGET_PATH " " (( WGET_BG ) ? "--background " : "" ) 
             .  (( WGET_LOGDIR && WGET_LOGDIR == "NULL" ) ? "--output-file='/dev/null' " 
             :  (  WGET_LOGDIR ) ? "--output-file='" WGET_LOGDIR "/" sFileName ".log' " : "" )
             .  WGET_DEFOPT " " sParamString

; Ask for user modification of the wget commandline.
If ( WGET_MODIFY )
{
    InputBox, sWgetCustom, flash2wget, Please modify the wget commandline according to your needs:
                                     ,, 600, 130,,,,, %sWgetCmdline%
    If ( ! ErrorLevel )
        sWgetCmdline := sWgetCustom
}

; Prepare the full commandlines for kscp and klink.
sCopyCookie := A_ScriptDir "\tools\kscp.exe -P " SSH_PORT (( SSH_PRIVATEKEY && SSH_PRIVATEKEY != "NONE" ) ? " -i " 
            .  SSH_PRIVATEKEY : " -pw " SSH_PASSWORD) " """ sCookieFile """ " SSH_USER "@" SSH_IP ":" WGET_COOKIE
sRunWgetJob := A_ScriptDir "\tools\klink.exe -P " SSH_PORT (( SSH_PRIVATEKEY && SSH_PRIVATEKEY != "NONE" ) ? " -i " 
            .  SSH_PRIVATEKEY : " -pw " SSH_PASSWORD) " " SSH_USER "@" SSH_IP " """ sWgetCmdline """"

; Check if the required tools are present.
If ( A_IsCompiled )
{
    If ( !InStr(FileExist(A_ScriptDir "\tools"), "D") )
        FileCreateDir, %A_ScriptDir%\tools
    FileInstall, tools\kscp.exe,  %A_ScriptDir%\tools\kscp.exe
    FileInstall, tools\klink.exe, %A_ScriptDir%\tools\klink.exe
}

; Run the kscp and klink commandlines.
RunWait, %sCopyCookie%,, Hide
Run,     %sRunWgetJob%,, % ( WGET_BG || WGET_LOGDIR ) ? "Hide" : ""

; Notify about the jobs.
If ( JOB_NOTIFY )
    MsgBox, 0x40, flash2wget, % "Wget job started." (( JOB_NOTIFY == 2 ) ? "`n`n" sCopyCookie "`n`n" sRunWgetJob : "")
ExitApp

; ----------------------------------------------------------------------------------------------------------------------

ExitForThisReason(sMsg) {
    MsgBox, 0x10, flash2wget, %sMsg%
    ExitApp
}

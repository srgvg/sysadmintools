
Sub GetParentDir
  ParentDir = InputBox("Type the path of the parent folder for the user folders:", "Parent Directory Input Prompt", ParentDir)
  If Not FS.FolderExists(ParentDir) Then
    GetParentDir
  End If
End Sub

Dim WSHNetwork, WSHShell, FS, Domain, DomainObj, Computer, ShareServiceObj, ParentDir, Hidden, Drive
Set FS = CreateObject("Scripting.FileSystemObject")
Set WSHNetwork = CreateObject("WScript.Network")
Set ShareServiceObj = GetObject("WinNT://" & WSHNetwork.ComputerName & "/LanManServer")
 
Domain = InputBox("Type the name of your domain:","Enumeration and Creation of User Shares","DomainName")
ParentDir = "C:\Users"
GetParentDir
Hidden = MsgBox("Do you want the user shares to be hidden? If yes, the share will be username$; If no, the share will be username", 4, "Hidden Shares?")
Hidden = Hidden - 7
Drive = InputBox("What drive letter do you want to map the home folder to?", "Drive Letter?", "X:")
Set DomainObj = GetObject("WinNT://" & Domain)
DomainObj.Filter = Array("User")

For Each UserObj in DomainObj
  Dim ShareName
  If Not FS.FolderExists(ParentDir & "\" & UserObj.Name) Then
    FS.CreateFolder(ParentDir & "\" & UserObj.Name)
  End If
  ShareName = "_" & UserObj.Name
  If Hidden Then
    ShareName = ShareName & "$"
  End If
  On Error Resume Next
  Set NewShare = ShareServiceObj.Create("fileshare", ShareName)
  If Not Err Then
    NewShare.Path = ParentDir & "\" & UserObj.Name
    NewShare.MaxUserCount = 1 'Sets the limit for the number of user connections
    NewShare.SetInfo
    UserObj.HomeDirectory = "\\" & WSHNetwork.ComputerName & "\" & ShareName
    UserObj.HomeDirDrive = Drive 'Requires ADSI 2.5
    UserObj.SetInfo
  End If
Next

MsgBox "Script Complete",, "Finished" 


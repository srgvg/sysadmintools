'==========================================================================
'
' VBScript Source File -- Created with SAPIEN Technologies PrimalSCRIPT(TM)
'
' NAME: DelFiles
'
' AUTHOR: Lode Bovyn , NV Velleman Components
' DATE  : 14/03/2002
'
' COMMENT: Delete files older than x days
'			Parameters: directory, days
'
'==========================================================================
'

Dim Days
Dim Directory
Dim SubDir


Set objArgs = WScript.Arguments

If ObjArgs.Count <> 3 Then
	MsgBox "Usage: delFiles [directory] [days] [sub/nosub]"
Else
	Directory = objArgs(0)
	Days = objArgs(1)
	SubDir = objArgs(2)
	Recurse Directory,Days,SubDir
End If



Sub Recurse(Path,Days,SubDir)
Dim fso, Root, Files, Folders, File, i, FoldersArray(100)
    			
Set fso = CreateObject("Scripting.FileSystemObject")
Set Root = fso.getfolder(Path)
Set Files = Root.Files
Set Folders = Root.SubFolders
For Each File In Files
	If File.DateLastModified < DateAdd("d",-Days,Now()) Then
   		File.Delete
	End If
Next
If Subdir = "Sub" then	
	For Each Folder In Folders
		FoldersArray(i) = Folder.Path
		i = i + 1
	Next
    			 	
	For i = 0 To UBound(FoldersArray)
		if FoldersArray(i) <> "" Then 
			Recurse FoldersArray(i),Days,SubDir				
		Else
			Exit For
		End if
	Next
End if
End Sub

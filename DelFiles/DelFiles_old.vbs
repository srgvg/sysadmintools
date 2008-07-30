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
Dim FSO
Dim f
Dim fc
Dim Days
Dim Directory

Set objArgs = WScript.Arguments

If ObjArgs.Count <> 2 Then
	MsgBox "Usage: delFiles [directory] [days]"
Else
	Directory = objArgs(0)
	Days = objArgs(1)

	Set FSO = CreateObject("Scripting.FileSystemObject")
	Set f = fso.GetFolder(directory)
	Set fc = f.Files
	For Each f1 in fc
		if f1.DateLastModified < DateAdd("d",-days,Now()) Then
   			f1.Delete
	   	End If
	Next
End If




Function fileCompare(ByVal content, ByVal FSO, ByVal fileAllName) 

	Dim fNewLen
	Dim cLen
	Dim tmpContent
	Const ForReading = 1
	Const TristateTrue = 0
	
	Set TS = FSO.OpenTextFile(fileAllName, ForReading, False, TristateTrue)
	tmpContent = TS.ReadAll
	fNewLen = Len(tmpContent)
	cLen = Len(content)
	TS.Close
	
	If(Not (fNewLen = cLen)) Then  
		fileCompare = 1
		MsgBox "FC: 1"
		Exit Function
	End If  
	Set TS = FSO.GetFile(fileAllName)
	If(TS.Size > 0) Then
		Set TS = FSO.OpenTextFile(fileAllName, ForReading, False, TristateTrue)
		tmpContent = TS.ReadAll
		TS.Close
		If(content <> tmpContent) Then
			fileCompare = 3
			MsgBox "FC: 3"
			Exit Function 
		End If
	Else
		fileCompare = 2
		MsgBox "FC: 2"
		Exit Function 
	End If

	fileCompare = 0

End Function       

Function fileRead(ByVal fileAllName, ByRef content)

	Const ForReading = 1
	Const TristateTrue = 0
	Set FSO = CreateObject("Scripting.FileSystemObject") 
	If(FSO.FileExists(fileAllName)) Then
		Set TS = FSO.GetFile(fileAllName)
		If(TS.Size > 0) Then
			'TristateUseDefault
			Set TS = FSO.OpenTextFile(fileAllName, ForReading, False, TristateTrue)
			content = TS.ReadAll
			TS.Close
			Set FSO = Nothing   
		Else
			MsgBox "FR: Nothing to read. 2" 
			fileRead = 2
			Set FSO = Nothing 
			Exit Function 
		End If
		 
	Else
		MsgBox "FR: No input file. 1"
		fileRead = 1
		Exit Function
	End If
	
	fileRead = 0

End Function

Function textReplace(ByRef content, ByVal oldText, ByVal newText)

	If(content <> "") Then
		tmp = content
		content = Replace(content, oldText, newText)
		'MsgBox content
		'MsgBox oldText
		'MsgBox NewText
		If (tmp = content) then
			MsgBox "TR: There is no string to replace. 2" 
			textReplace = 2
			Exit Function
		End If
	Else  
		MsgBox "TR:  Nothing to Replace. 1"
		textReplace = 1
		Exit Function
	End If

	textReplace = 0

End Function

Function fileWrite(ByVal fileAllName, ByVal content)

		If(content <> "") Then
		Set FSO = CreateObject("Scripting.FileSystemObject")
		fileTemp = fileAllName & ".tmp"
		If(FSO.FileExists(fileAllName)) Then
			If (Not FSO.FileExists(fileTemp)) Then
				FSO.CopyFile fileAllName, fileTemp, False
				Const TristateTrue = 0
  				Set TS = FSO.CreateTextFile(fileAllName, True, TristateTrue)
				TS.Write content  
				TS.Close			
				Dim tmp
				tmp = fileCompare(content, FSO, fileAllName) 
				If (tmp <> 0) Then
					MsgBox "Files not equals."
					fileWrite = 4
					FSO.DeleteFile fileAllName
					FSO.CopyFile fileTemp, fileAllName, False
					FSO.DeleteFile fileTemp
					Set FSO = Nothing
					Exit Function
				End If
				
				FSO.DeleteFile fileTemp
				Set FSO = Nothing
			Else 
				MsgBox "FW: There is a temp file. 3"
				fileWrite = 3
				Set FSO = Nothing
				Exit Function
			End If
		Else
			MsgBox "FW: No output file. 2"
			fileWrite = 2
			Set FSO = Nothing
			Exit Function
		End If
	Else
		MsgBox "FW: Nothing to write. 1"
		fileWrite = 1
		Exit Function
	End If

	fileWrite = 0

End Function

Function fileManage(ByVal fileAllName, ByVal oldText, ByVal newText)

	Dim content
	Dim result
	result = fileRead(fileAllName, content)
	'MsgBox content
	If (result = 0) Then
		result =  textReplace(content, oldText, newText)
		If (result = 0) Then
			result = fileWrite(fileAllName, content)
		End If
	End If	
	content = ""

	If(result = 0) Then
		MsgBox "Программа завершена."
	End If

End Function

Function startTests()
	
	Dim wsh
        Dim RetCode
	Dim str1

	str1 = """C:\Program Files\NUnit 2.6.2\bin\nunit-console-x86.exe"" /xml=testResults.xml ""C:\test.dll"""

	Set wsh = WScript.CreateObject("WScript.Shell")
	RetCode = wsh.Run(str1, 1, True)
        MsgBox "Тесты завершены. Код возврата приложения (nunit-console-x86.exe) - " & RetCode
	

	path = wsh.CurrentDirectory + "\testResults.xml"
	old = "<!--This file represents the results of running a test suite-->"
	newT = "<?xml-stylesheet type='text/xsl' href='TestResult.xsl'?> <!--This file represents the results of running a test suite-->"
	Call fileManage(path, old, newT)
	

	wsh.Run("testResults.xml")
	'wsh.Run("testResults.txt")
	
	Set wsh = Nothing

End Function

'----Manage----------------

Call startTests



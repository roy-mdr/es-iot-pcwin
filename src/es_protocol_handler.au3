
; ===========================================================

; https://www.autoitscript.com/autoit3/docs/directives/pragma-compile.htm

; #pragma compile(Out, myProg.exe)
#pragma compile(Icon, .\res\es.ico)
#pragma compile(ExecLevel, none)
#pragma compile(UPX, true)
; #pragma compile(AutoItExecuteAllowed, false)
#pragma compile(Console, false)
#pragma compile(Compression, 9)
; #pragma compile(Compatibility, win7)
#pragma compile(x64, false)
; #pragma compile(inputboxres, false)
#pragma compile(Comments, '"App for protocol handling: esustenta')
#pragma compile(CompanyName, "Estudio Sustenta")
#pragma compile(FileDescription, "Estudio Sustenta App")
#pragma compile(FileVersion, 0.1.0.0)
#pragma compile(InternalName, "Estudio Sustenta App")
#pragma compile(LegalCopyright, © Estudio Sustenta 2022)
#pragma compile(OriginalFilename, es_protocol_handler.exe)
#pragma compile(ProductName, Estudio Sustenta App)
#pragma compile(ProductVersion, 0.1)

; ===========================================================

#include <JSON.au3>



; msgbox(0, "Runnin", "You are running the app! Now it will pop the raw parameters (if any)")

; msgbox(0, "$CmdLineRaw", $CmdLineRaw) ; Raw parameters string



$protocol = "esustenta"


If $CmdLine[0] = 0 Then Exit

If StringInStr($CmdLine[1], $protocol) = 1 Then
	calledByProtocol( urldecode($CmdLine[1]) )
EndIf


Func calledByProtocol($protocolURL)

	$data = StringTrimLeft($protocolURL, StringLen($protocol) + 1 ) ; Remove protocol + :

	If StringInStr($data, "//") = 1 Then
		$data = StringTrimLeft($data, 2 )
	EndIf

	; msgbox(0, "Data", $data) ; Raw parameters string

	$dataSplit = StringSplit($data, "/")

	$command = $dataSplit[1]
	$commandData = ""

	If $dataSplit[0] > 1 Then
		$commandData = StringTrimLeft($data, StringLen($command) + 1 ) ; Remove protocol + /
	EndIf

	; msgbox(0, "Command:", $command)
	; msgbox(0, "Command Data:", $commandData)

	If $command = "" Then Exit ; No command passed

	If $command = "explorer" Then
		_command_explorer($commandData)
	EndIf

	If $command = "project-rewire-origin" Then

		$esusClientDir = "\\192.168.1.72\esustenta\02 CLIENTES (EEX-CLI)"

		$cmdDataSplit = StringSplit($commandData, "/")
		$project    = StringReplace($cmdDataSplit[1], "\", "") & "\" & StringReplace($cmdDataSplit[2], "\", "")
		$rewireDir = $esusClientDir & "\" & $project & "\" & $cmdDataSplit[3]
		$rewire     = $rewireDir & "\origen.json"
		$newOrig  = $esusClientDir & "\" & $project & "\" & $cmdDataSplit[4]

		If StringUpper($rewireDir) == StringUpper($newOrig) Then
			msgbox(16, "ERROR", "Origin can't be self.")
			Exit
		EndIf

		$fileContents = FileRead( $rewire )

		If $fileContents == "" Then
			msgbox(16, "ERROR", "Error reading file " &  $rewire)
			Exit
		EndIf

		$jsonObj = json_decode( $fileContents )
		Json_ObjPut($jsonObj, 'directorio', $newOrig)
		$newString = Json_Encode($jsonObj, 128)

		If Not FileRecycle( $rewire ) == 1 Then
			msgbox(16, "ERROR", "Error deleting file " &  $rewire)
			Exit
		EndIf

		If Not FileWrite( $rewire, $newString ) == 1 Then
			msgbox(16, "ERROR", "Error writing new file " &  $rewire)
			Run('explorer.exe "' & $rewireDir & '"')
			msgbox(262144, "Fix!", "===== WARNING =====" & @CRLF & @CRLF & "Please create a file called 'origen.json' with the following contents manually:" & @CRLF & @CRLF & $newString)
			Exit
		EndIf

		msgbox(0, "Ok", "===== ALL DONE! =====" & @CRLF & @CRLF & "New origin was set successfully." & @CRLF & "Please reload the project visualizer." )

	EndIf
	
EndFunc




Func _command_explorer($path)
	Run('explorer.exe "' & $path & '"')
EndFunc






Func urlencode($str, $plus = True) ; if second param = true (default) it will encode spaces as plus. If false - the space will be encoded as "%20" (not compliant)
	Local $i, $return, $tmp, $exp
	$return = ""
	$exp = "[a-zA-Z0-9-._~]"
	If $plus Then
		$str = StringReplace ($str, " ", "+")
		$exp = "[a-zA-Z0-9-._~+]"
	EndIf
	For $i = 1 To StringLen($str)
		$tmp = StringMid($str, $i, 1)
		If StringRegExp($tmp, $exp, 0) = 1 Then
			$return &= $tmp
		Else
			$return &= StringMid(StringRegExpReplace(StringToBinary($tmp, 4), "([0-9A-Fa-f]{2})", "%$1"), 3)
		EndIf
	Next
	Return $return
EndFunc

Func urldecode($str)
	Local $i, $return, $tmp
	$return = ""
	$str = StringReplace ($str, "+", " ")
	For $i = 1 To StringLen($str)
		$tmp = StringMid($str, $i, 3)
		If StringRegExp($tmp, "%[0-9A-Fa-f]{2}", 0) = 1 Then
			$i += 2
			While StringRegExp(StringMid($str, $i+1, 3), "%[0-9A-Fa-f]{2}", 0) = 1
				$tmp = $tmp & StringMid($str, $i+2, 2)
				$i += 3
			Wend
			$return &= BinaryToString(StringRegExpReplace($tmp, "%([0-9A-Fa-f]*)", "0x$1"), 4)
		Else
			$return &= StringMid($str, $i, 1)
		EndIf
	Next
	Return $return
EndFunc

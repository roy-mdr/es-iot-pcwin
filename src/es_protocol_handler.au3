
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



; msgbox(0, "Runnin", "You are running the app! Now it will pop the raw parameters (if any)")

; msgbox(0, "$CmdLineRaw", $CmdLineRaw) ; Raw parameters string



$protocol = "esustenta"


If $CmdLine[0] = 0 Then Exit

If StringInStr($CmdLine[1], $protocol) = 1 Then
	calledByProtocol( DecodeUrl($CmdLine[1]) )
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
	
EndFunc




Func _command_explorer($path)
	Run("explorer.exe " & $path)
EndFunc






Func DecodeUrl($src)
    Local $i
    Local $ch
    Local $buff

    ;Init Counter
    $i = 1

    While ($i <= StringLen($src))
        $ch = StringMid($src, $i, 1)
        ;Correct spaces
        If ($ch = "+") Then
            $ch = " "
        EndIf
        ;Decode any hex values
        If ($ch = "%") Then
            $ch = Chr(Dec(StringMid($src, $i + 1, 2)))
            $i += 2
        EndIf
        ;Build buffer
        $buff &= $ch
        ;Inc Counter
        $i += 1
    WEnd

    Return $buff
EndFunc   ;==>DecodeUrl

Func EncodeUrl($src)
    Local $i
    Local $ch
    Local $NewChr
    Local $buff

    ;Init Counter
    $i = 1

    While ($i <= StringLen($src))
        ;Get byte code from string
        $ch = Asc(StringMid($src, $i, 1))

        ;Look for what bytes we have
        Switch $ch
            ;Looks ok here
            Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
                $buff &= Chr($ch)
                ;Space found
            Case 32
                $buff &= "+"
            Case Else
                ;Convert $ch to hexidecimal
                $buff &= "%" & Hex($ch, 2)
        EndSwitch
        ;INC Counter
        $i += 1
    WEnd

    Return $buff
EndFunc   ;==>EncodeUrl
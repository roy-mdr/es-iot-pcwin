Set objArgs = Wscript.Arguments

Dim charCode

If objArgs.Count > 0 Then

	Select case objArgs(0)
		case "muteUnmute"
			charCode = chr(&hAD)
		
		case "volDown"
			charCode = chr(&hAE)
		
		case "volUp"
			charCode = chr(&hAF)
		
		case "next"
			charCode = chr(&hB0)
		
		case "prev"
			charCode = chr(&hB1)
		
		case "stop"
			charCode = chr(&hB2)
		
		case "playPause"
			charCode = ChrB(179)
		
		'case else
		'	charCode = chr(...HEX/KEYCODE...)
	End select

	Set WshShell = CreateObject("WScript.Shell")
	WshShell.SendKeys(charCode)

End If



'173	Windows 2000/XP: Volume Mute key	{VK 173}	VK_VOLUME_MUTE	0xAD
'174	Windows 2000/XP: Volume Down key	{VK 174}	VK_VOLUME_DOWN	0xAE
'175	Windows 2000/XP: Volume Up key	{VK 175}	VK_VOLUME_UP	0xAF
'176	Windows 2000/XP: Next Track key	{VK 176}	VK_MEDIA_NEXT_TRACK	0xB0
'177	Windows 2000/XP: Previous Track key	{VK 177}	VK_MEDIA_PREV_TRACK	0xB1
'178	Windows 2000/XP: Stop Media key	{VK 178}	VK_MEDIA_STOP	0xB2
'179	Windows 2000/XP: Play/Pause Media key	{VK 179}	VK_MEDIA_PLAY_PAUSE	0xB3


' Chr(199) returns a 2-byte character, which is being interpreted as 2 separate characters.
' ChrW(199) to return a Unicode string.
' ChrB(199) to return it as a single-byte character
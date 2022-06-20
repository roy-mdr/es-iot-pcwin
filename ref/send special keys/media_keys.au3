# REFERENCE: https://www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm

If $CmdLine[0] > 0 Then
	
	Switch $CmdLine[1]
		Case "muteUnmute"
			Send("{VOLUME_MUTE}")
		Case "volDown"
			Send("{VOLUME_DOWN}")
		Case "volUp"
			Send("{VOLUME_UP}")
		Case "next"
			Send("{MEDIA_NEXT}")
		Case "prev"
			Send("{MEDIA_PREV}")
		Case "stop"
			Send("{MEDIA_STOP}")
		Case "playPause"
			Send("{MEDIA_PLAY_PAUSE}")
		# Case Else
		# 	Send($CmdLine[1])
	EndSwitch
	
EndIf

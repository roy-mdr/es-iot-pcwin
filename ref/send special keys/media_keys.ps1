$actionName=$args[0]
$keyCode

switch ($actionName)
{
	"muteUnmute" { $keyCode = [char]173; Break}
	"volDown"    { $keyCode = [char]174; Break}
	"volUp"      { $keyCode = [char]175; Break}
	"next"       { $keyCode = [char]176; Break}
	"prev"       { $keyCode = [char]177; Break}
	"stop"       { $keyCode = [char]178; Break}
	"playPause"  { $keyCode = [char]179; Break}
}

$wshShell = new-object -com wscript.shell
$wshShell.SendKeys($keyCode)

<#

http://www.emeditor.org/en/macro_shell_send_keys.html

https://orlandomvp.org/SendKeysMore.asp

https://keycode.info/

https://developpaper.com/vbs-sendkeys-virtual-key-codes-hex-symbol/

https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.keys?view=windowsdesktop-6.0

PROBLEM (NOT SOLVED): https://stackoverflow.com/questions/28313262/wshshell-keystroke-multimedia-next-track-windows

Mute/Unmute:    173
Volume Down:    174
Volume Up:      175
Next Track:     176 (NOT WORKING)
Previous Track: 177
Stop Media:     178
Play/Pause:     179
Pause:          19  (NOT WORKING)
Play:           250 (NOT WORKING)

#>
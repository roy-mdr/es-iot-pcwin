> from: https://superuser.com/questions/934220/get-audio-volume-from-command-prompt

Ideally you would use the same .Net or Win API that tools like NirCmd are using to do this directly.

I have also been struggling to find a good and simple command line option to get the current system volume.

I finally found something that works on Windows 10.

I haven't tried older versions of windows yet, but I presume it works for Windows Vista or later.

It is available here: https://sourceforge.net/projects/mplayer-edl/files/adjust_get_current_system_volume_vista_plus.exe/download

### Usage:

`adjust_get_current_system_volume_vista_plus.exe`

returns the current volume and exits

`adjust_get_current_system_volume_vista_plus.exe 50`

sets the volume to `50` then returns the current volume (50) and exits.

----------

There is also a python option here: https://github.com/AndreMiras/pycaw

----------

It should be possible to do this with PowerShell as well: https://stackoverflow.com/a/19348221/861745

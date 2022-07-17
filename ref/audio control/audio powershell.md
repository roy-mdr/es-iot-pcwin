> from: https://stackoverflow.com/questions/255419/how-can-i-mute-unmute-my-sound-from-powershell/19348221#19348221

Starting with Vista you have to use the [Core Audio API](http://msdn.microsoft.com/en-us/library/windows/desktop/dd370802%28v=vs.85%29.aspx) to control the system volume. It's a COM API that doesn't support automation and thus requires a lot of boilerplate to use from .NET and PowerShell.

Anyways the code bellow let you access the `[Audio]::Volume` and `[Audio]::Mute` properties from PowerShell. This also work on a remote computer which could be useful. Just copy-paste the code in your PowerShell window.


    Add-Type -TypeDefinition @'
    using System.Runtime.InteropServices;
    
    [Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IAudioEndpointVolume {
      // f(), g(), ... are unused COM method slots. Define these if you care
      int f(); int g(); int h(); int i();
      int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
      int j();
      int GetMasterVolumeLevelScalar(out float pfLevel);
      int k(); int l(); int m(); int n();
      int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
      int GetMute(out bool pbMute);
    }
    [Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMMDevice {
      int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
    }
    [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IMMDeviceEnumerator {
      int f(); // Unused
      int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
    }
    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
    
    public class Audio {
      static IAudioEndpointVolume Vol() {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice dev = null;
        Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
        IAudioEndpointVolume epv = null;
        var epvid = typeof(IAudioEndpointVolume).GUID;
        Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
        return epv;
      }
      public static float Volume {
        get {float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v;}
        set {Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty));}
      }
      public static bool Mute {
        get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
        set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
      }
    }
    '@
    
Usage sample:

    PS C:\> [Audio]::Volume         # Check current volume (now about 10%)
    0,09999999
    PS C:\> [Audio]::Mute           # See if speaker is muted
    False
    PS C:\> [Audio]::Mute = $true   # Mute speaker
    PS C:\> [Audio]::Volume = 0.75  # Set volume to 75%
    PS C:\> [Audio]::Volume         # Check that the changes are applied
    0,75
    PS C:\> [Audio]::Mute
    True
    PS C:\>


There are more comprehensive .NET wrappers out there for the Core Audio API if you need one but I'm not aware of a set of PowerShell friendly cmdlets.

*P.S.* [Diogo answer](https://stackoverflow.com/q/12397737) seems clever but it doesn't work for me.


  [1]: http://msdn.microsoft.com/en-us/library/windows/desktop/dd370802%28v=vs.85%29.aspx
  [2]: https://stackoverflow.com/q/12397737


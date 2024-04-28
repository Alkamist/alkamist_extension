package reaper

import "core:c"

//==========================================================================
// Win32 Types
//==========================================================================

INT_PTR :: uintptr
UINT_PTR :: uintptr
LONG_PTR :: int

LPVOID :: rawptr
HANDLE :: LPVOID
HINSTANCE :: HANDLE
HMENU :: HANDLE
HWND :: HANDLE
HICON :: HANDLE
HCURSOR :: HANDLE
HBRUSH :: HANDLE
HDC :: HANDLE
HGLRC :: HANDLE
HMODULE :: HINSTANCE
HFONT :: HANDLE

BOOL :: c.int
UINT :: c.uint
LONG :: c.long
SHORT :: c.short
WORD :: c.ushort
DWORD :: c.ulong
BYTE :: u8
CHAR :: c.char

LPARAM :: LONG_PTR
WPARAM :: UINT_PTR
LRESULT :: LONG_PTR

POINT :: struct {
    x: LONG,
    y: LONG,
}

RECT :: struct {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
}

MSG :: struct {
    hwnd: HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: DWORD,
    pt: POINT,
}

ACCEL :: struct {
    fVirt: u8,
    key: u16,
    cmd: u16,
}

GUID :: struct {
    Data1: c.ulong,
    Data2: c.ushort,
    Data3: c.ushort,
    Data4: [8]u8,
}

//==========================================================================
// Reaper Types
//==========================================================================

UNDO_STATE_MISCCFG :: 8

MIDI_eventlist :: struct {}
PCM_source_peaktransfer_t :: struct {}
IReaperControlSurface :: struct {}
midi_Input :: struct {}
midi_Output :: struct {}
LICE_IBitmap :: struct {}
LICE_IFont :: struct {}
WDL_VirtualWnd_BGCfg :: struct {}
preview_register_t :: struct {}
REAPER_Resample_Interface :: struct {}
IReaperPitchShift :: struct {}
REAPER_PeakGet_Interface :: struct {}
REAPER_PeakBuild_Interface :: struct {}
ISimpleMediaDecoder :: struct {}
PCM_source :: struct {}
PCM_sink :: struct {}
ProjectStateContext :: struct {}

ReaProject :: struct {}
MediaTrack :: struct {}
MediaItem :: struct {}
MediaItem_Take :: struct {}
TrackEnvelope :: struct {}
AudioAccessor :: struct {}
joystick_device :: struct {}

ReaSample :: f64
LICE_pixel :: c.uint
LICE_pixel_chan :: c.uchar

screensetNewCallbackFunc :: #type proc "c" (action: c.int, id: cstring, param: rawptr, actionParm: rawptr, actionParmSize: c.int) -> LRESULT

plugin_info_t :: struct {
    caller_version: c.int,
    hwnd_main: rawptr,
    Register: proc "c" (name: cstring, infostruct: rawptr) -> c.int,
    GetFunc: proc "c" (name: cstring) -> rawptr,
}

gaccel_register_t :: struct {
    accel: ACCEL,
    desc: cstring,
}

KbdCmd :: struct {
    cmd: DWORD,
    text: cstring,
}

KbdKeyBindingInfo :: struct {
    key: c.int,
    cmd: c.int,
    flags: c.int,
}

KbdSectionInfo :: struct {
    uniqueID: c.int,
    name: cstring,
    action_list: ^KbdCmd,
    action_list_cnt: c.int,
    def_keys: ^KbdKeyBindingInfo,
    def_keys_cnt: c.int,
    onAction: proc "c" (cmd, val, valhw, relmode: c.int, hwnd: HWND) -> bool,
    accels: rawptr,
    recent_cmds: rawptr,
    extended_data: [32]rawptr,
}

MIDI_event_t :: struct {
    frame_offset: c.int,
    size: c.int,
    midi_message: [4]u8,
}

audio_hook_register_t :: struct {
    OnAudioBuffer: proc "c" (isPost: bool, len: int, srate: f64, reg: ^audio_hook_register_t),
    userdata1: rawptr,
    userdata2: rawptr,
    input_nch: int,
    output_nch: int,
    GetBuffer: proc "c" (isOutput: bool, idx: int) -> ^ReaSample,
}

PCM_source_transfer_t :: struct {
    time_s: f64,
    samplerate: f64,
    nch: int,
    length: int,
    samples: ^ReaSample,
    samples_out: int,
    midi_events: ^MIDI_eventlist,
    approximate_playback_latency: f64 ,
    absolute_time_s: f64 ,
    force_bpm: f64 ,
}

project_config_extension_t :: struct {
    ProcessExtensionLine: proc "c" (line: cstring, ctx: ^ProjectStateContext, isUndo: bool, reg: ^project_config_extension_t) -> bool,
    SaveExtensionConfig: proc "c" (ctx: ^ProjectStateContext, isUndo: bool, reg: ^project_config_extension_t),
    BeginLoadProjectState: proc "c" (isUndo: bool, reg: ^project_config_extension_t),
    userData: rawptr,
}

//==========================================================================
// Reaper C++ Wrapper
//==========================================================================

foreign import wrapper { "wrapper.lib" }

@(default_calling_convention="c")
foreign wrapper {
    // ProjectStateContext_AddLine :: proc(ctx: ^ProjectStateContext, fmt: cstring, #c_vararg args: ..any) ---
    ProjectStateContext_AddLine :: proc(ctx: ^ProjectStateContext, str: cstring) ---
    ProjectStateContext_GetLine :: proc(ctx: ^ProjectStateContext, buf: [^]byte, buflen: c.int) -> c.int ---
}

//==========================================================================
// Reaper API Function Loader
//==========================================================================

load_api_functions :: proc(plugin_info: ^plugin_info_t) {
    AddCustomizableMenu = cast(type_of(AddCustomizableMenu))plugin_info.GetFunc("AddCustomizableMenu")
    AddExtensionsMainMenu = cast(type_of(AddExtensionsMainMenu))plugin_info.GetFunc("AddExtensionsMainMenu")
    AddMediaItemToTrack = cast(type_of(AddMediaItemToTrack))plugin_info.GetFunc("AddMediaItemToTrack")
    AddProjectMarker = cast(type_of(AddProjectMarker))plugin_info.GetFunc("AddProjectMarker")
    AddProjectMarker2 = cast(type_of(AddProjectMarker2))plugin_info.GetFunc("AddProjectMarker2")
    AddRemoveReaScript = cast(type_of(AddRemoveReaScript))plugin_info.GetFunc("AddRemoveReaScript")
    AddTakeToMediaItem = cast(type_of(AddTakeToMediaItem))plugin_info.GetFunc("AddTakeToMediaItem")
    AddTempoTimeSigMarker = cast(type_of(AddTempoTimeSigMarker))plugin_info.GetFunc("AddTempoTimeSigMarker")
    adjustZoom = cast(type_of(adjustZoom))plugin_info.GetFunc("adjustZoom")
    AnyTrackSolo = cast(type_of(AnyTrackSolo))plugin_info.GetFunc("AnyTrackSolo")
    APIExists = cast(type_of(APIExists))plugin_info.GetFunc("APIExists")
    APITest = cast(type_of(APITest))plugin_info.GetFunc("APITest")
    ApplyNudge = cast(type_of(ApplyNudge))plugin_info.GetFunc("ApplyNudge")
    ArmCommand = cast(type_of(ArmCommand))plugin_info.GetFunc("ArmCommand")
    Audio_Init = cast(type_of(Audio_Init))plugin_info.GetFunc("Audio_Init")
    Audio_IsPreBuffer = cast(type_of(Audio_IsPreBuffer))plugin_info.GetFunc("Audio_IsPreBuffer")
    Audio_IsRunning = cast(type_of(Audio_IsRunning))plugin_info.GetFunc("Audio_IsRunning")
    Audio_Quit = cast(type_of(Audio_Quit))plugin_info.GetFunc("Audio_Quit")
    Audio_RegHardwareHook = cast(type_of(Audio_RegHardwareHook))plugin_info.GetFunc("Audio_RegHardwareHook")
    AudioAccessorStateChanged = cast(type_of(AudioAccessorStateChanged))plugin_info.GetFunc("AudioAccessorStateChanged")
    AudioAccessorUpdate = cast(type_of(AudioAccessorUpdate))plugin_info.GetFunc("AudioAccessorUpdate")
    AudioAccessorValidateState = cast(type_of(AudioAccessorValidateState))plugin_info.GetFunc("AudioAccessorValidateState")
    BypassFxAllTracks = cast(type_of(BypassFxAllTracks))plugin_info.GetFunc("BypassFxAllTracks")
    CalculatePeaks = cast(type_of(CalculatePeaks))plugin_info.GetFunc("CalculatePeaks")
    CalculatePeaksFloatSrcPtr = cast(type_of(CalculatePeaksFloatSrcPtr))plugin_info.GetFunc("CalculatePeaksFloatSrcPtr")
    ClearAllRecArmed = cast(type_of(ClearAllRecArmed))plugin_info.GetFunc("ClearAllRecArmed")
    ClearConsole = cast(type_of(ClearConsole))plugin_info.GetFunc("ClearConsole")
    ClearPeakCache = cast(type_of(ClearPeakCache))plugin_info.GetFunc("ClearPeakCache")
    ColorFromNative = cast(type_of(ColorFromNative))plugin_info.GetFunc("ColorFromNative")
    ColorToNative = cast(type_of(ColorToNative))plugin_info.GetFunc("ColorToNative")
    CountActionShortcuts = cast(type_of(CountActionShortcuts))plugin_info.GetFunc("CountActionShortcuts")
    CountAutomationItems = cast(type_of(CountAutomationItems))plugin_info.GetFunc("CountAutomationItems")
    CountEnvelopePoints = cast(type_of(CountEnvelopePoints))plugin_info.GetFunc("CountEnvelopePoints")
    CountEnvelopePointsEx = cast(type_of(CountEnvelopePointsEx))plugin_info.GetFunc("CountEnvelopePointsEx")
    CountMediaItems = cast(type_of(CountMediaItems))plugin_info.GetFunc("CountMediaItems")
    CountProjectMarkers = cast(type_of(CountProjectMarkers))plugin_info.GetFunc("CountProjectMarkers")
    CountSelectedMediaItems = cast(type_of(CountSelectedMediaItems))plugin_info.GetFunc("CountSelectedMediaItems")
    CountSelectedTracks = cast(type_of(CountSelectedTracks))plugin_info.GetFunc("CountSelectedTracks")
    CountSelectedTracks2 = cast(type_of(CountSelectedTracks2))plugin_info.GetFunc("CountSelectedTracks2")
    CountTakeEnvelopes = cast(type_of(CountTakeEnvelopes))plugin_info.GetFunc("CountTakeEnvelopes")
    CountTakes = cast(type_of(CountTakes))plugin_info.GetFunc("CountTakes")
    CountTCPFXParms = cast(type_of(CountTCPFXParms))plugin_info.GetFunc("CountTCPFXParms")
    CountTempoTimeSigMarkers = cast(type_of(CountTempoTimeSigMarkers))plugin_info.GetFunc("CountTempoTimeSigMarkers")
    CountTrackEnvelopes = cast(type_of(CountTrackEnvelopes))plugin_info.GetFunc("CountTrackEnvelopes")
    CountTrackMediaItems = cast(type_of(CountTrackMediaItems))plugin_info.GetFunc("CountTrackMediaItems")
    CountTracks = cast(type_of(CountTracks))plugin_info.GetFunc("CountTracks")
    CreateLocalOscHandler = cast(type_of(CreateLocalOscHandler))plugin_info.GetFunc("CreateLocalOscHandler")
    CreateMIDIInput = cast(type_of(CreateMIDIInput))plugin_info.GetFunc("CreateMIDIInput")
    CreateMIDIOutput = cast(type_of(CreateMIDIOutput))plugin_info.GetFunc("CreateMIDIOutput")
    CreateNewMIDIItemInProj = cast(type_of(CreateNewMIDIItemInProj))plugin_info.GetFunc("CreateNewMIDIItemInProj")
    CreateTakeAudioAccessor = cast(type_of(CreateTakeAudioAccessor))plugin_info.GetFunc("CreateTakeAudioAccessor")
    CreateTrackAudioAccessor = cast(type_of(CreateTrackAudioAccessor))plugin_info.GetFunc("CreateTrackAudioAccessor")
    CreateTrackSend = cast(type_of(CreateTrackSend))plugin_info.GetFunc("CreateTrackSend")
    CSurf_FlushUndo = cast(type_of(CSurf_FlushUndo))plugin_info.GetFunc("CSurf_FlushUndo")
    CSurf_GetTouchState = cast(type_of(CSurf_GetTouchState))plugin_info.GetFunc("CSurf_GetTouchState")
    CSurf_GoEnd = cast(type_of(CSurf_GoEnd))plugin_info.GetFunc("CSurf_GoEnd")
    CSurf_GoStart = cast(type_of(CSurf_GoStart))plugin_info.GetFunc("CSurf_GoStart")
    CSurf_NumTracks = cast(type_of(CSurf_NumTracks))plugin_info.GetFunc("CSurf_NumTracks")
    CSurf_OnArrow = cast(type_of(CSurf_OnArrow))plugin_info.GetFunc("CSurf_OnArrow")
    CSurf_OnFwd = cast(type_of(CSurf_OnFwd))plugin_info.GetFunc("CSurf_OnFwd")
    CSurf_OnFXChange = cast(type_of(CSurf_OnFXChange))plugin_info.GetFunc("CSurf_OnFXChange")
    CSurf_OnInputMonitorChange = cast(type_of(CSurf_OnInputMonitorChange))plugin_info.GetFunc("CSurf_OnInputMonitorChange")
    CSurf_OnInputMonitorChangeEx = cast(type_of(CSurf_OnInputMonitorChangeEx))plugin_info.GetFunc("CSurf_OnInputMonitorChangeEx")
    CSurf_OnMuteChange = cast(type_of(CSurf_OnMuteChange))plugin_info.GetFunc("CSurf_OnMuteChange")
    CSurf_OnMuteChangeEx = cast(type_of(CSurf_OnMuteChangeEx))plugin_info.GetFunc("CSurf_OnMuteChangeEx")
    CSurf_OnOscControlMessage = cast(type_of(CSurf_OnOscControlMessage))plugin_info.GetFunc("CSurf_OnOscControlMessage")
    CSurf_OnPanChange = cast(type_of(CSurf_OnPanChange))plugin_info.GetFunc("CSurf_OnPanChange")
    CSurf_OnPanChangeEx = cast(type_of(CSurf_OnPanChangeEx))plugin_info.GetFunc("CSurf_OnPanChangeEx")
    CSurf_OnPause = cast(type_of(CSurf_OnPause))plugin_info.GetFunc("CSurf_OnPause")
    CSurf_OnPlay = cast(type_of(CSurf_OnPlay))plugin_info.GetFunc("CSurf_OnPlay")
    CSurf_OnPlayRateChange = cast(type_of(CSurf_OnPlayRateChange))plugin_info.GetFunc("CSurf_OnPlayRateChange")
    CSurf_OnRecArmChange = cast(type_of(CSurf_OnRecArmChange))plugin_info.GetFunc("CSurf_OnRecArmChange")
    CSurf_OnRecArmChangeEx = cast(type_of(CSurf_OnRecArmChangeEx))plugin_info.GetFunc("CSurf_OnRecArmChangeEx")
    CSurf_OnRecord = cast(type_of(CSurf_OnRecord))plugin_info.GetFunc("CSurf_OnRecord")
    CSurf_OnRecvPanChange = cast(type_of(CSurf_OnRecvPanChange))plugin_info.GetFunc("CSurf_OnRecvPanChange")
    CSurf_OnRecvVolumeChange = cast(type_of(CSurf_OnRecvVolumeChange))plugin_info.GetFunc("CSurf_OnRecvVolumeChange")
    CSurf_OnRew = cast(type_of(CSurf_OnRew))plugin_info.GetFunc("CSurf_OnRew")
    CSurf_OnRewFwd = cast(type_of(CSurf_OnRewFwd))plugin_info.GetFunc("CSurf_OnRewFwd")
    CSurf_OnScroll = cast(type_of(CSurf_OnScroll))plugin_info.GetFunc("CSurf_OnScroll")
    CSurf_OnSelectedChange = cast(type_of(CSurf_OnSelectedChange))plugin_info.GetFunc("CSurf_OnSelectedChange")
    CSurf_OnSendPanChange = cast(type_of(CSurf_OnSendPanChange))plugin_info.GetFunc("CSurf_OnSendPanChange")
    CSurf_OnSendVolumeChange = cast(type_of(CSurf_OnSendVolumeChange))plugin_info.GetFunc("CSurf_OnSendVolumeChange")
    CSurf_OnSoloChange = cast(type_of(CSurf_OnSoloChange))plugin_info.GetFunc("CSurf_OnSoloChange")
    CSurf_OnSoloChangeEx = cast(type_of(CSurf_OnSoloChangeEx))plugin_info.GetFunc("CSurf_OnSoloChangeEx")
    CSurf_OnStop = cast(type_of(CSurf_OnStop))plugin_info.GetFunc("CSurf_OnStop")
    CSurf_OnTempoChange = cast(type_of(CSurf_OnTempoChange))plugin_info.GetFunc("CSurf_OnTempoChange")
    CSurf_OnTrackSelection = cast(type_of(CSurf_OnTrackSelection))plugin_info.GetFunc("CSurf_OnTrackSelection")
    CSurf_OnVolumeChange = cast(type_of(CSurf_OnVolumeChange))plugin_info.GetFunc("CSurf_OnVolumeChange")
    CSurf_OnVolumeChangeEx = cast(type_of(CSurf_OnVolumeChangeEx))plugin_info.GetFunc("CSurf_OnVolumeChangeEx")
    CSurf_OnWidthChange = cast(type_of(CSurf_OnWidthChange))plugin_info.GetFunc("CSurf_OnWidthChange")
    CSurf_OnWidthChangeEx = cast(type_of(CSurf_OnWidthChangeEx))plugin_info.GetFunc("CSurf_OnWidthChangeEx")
    CSurf_OnZoom = cast(type_of(CSurf_OnZoom))plugin_info.GetFunc("CSurf_OnZoom")
    CSurf_ResetAllCachedVolPanStates = cast(type_of(CSurf_ResetAllCachedVolPanStates))plugin_info.GetFunc("CSurf_ResetAllCachedVolPanStates")
    CSurf_ScrubAmt = cast(type_of(CSurf_ScrubAmt))plugin_info.GetFunc("CSurf_ScrubAmt")
    CSurf_SetAutoMode = cast(type_of(CSurf_SetAutoMode))plugin_info.GetFunc("CSurf_SetAutoMode")
    CSurf_SetPlayState = cast(type_of(CSurf_SetPlayState))plugin_info.GetFunc("CSurf_SetPlayState")
    CSurf_SetRepeatState = cast(type_of(CSurf_SetRepeatState))plugin_info.GetFunc("CSurf_SetRepeatState")
    CSurf_SetSurfaceMute = cast(type_of(CSurf_SetSurfaceMute))plugin_info.GetFunc("CSurf_SetSurfaceMute")
    CSurf_SetSurfacePan = cast(type_of(CSurf_SetSurfacePan))plugin_info.GetFunc("CSurf_SetSurfacePan")
    CSurf_SetSurfaceRecArm = cast(type_of(CSurf_SetSurfaceRecArm))plugin_info.GetFunc("CSurf_SetSurfaceRecArm")
    CSurf_SetSurfaceSelected = cast(type_of(CSurf_SetSurfaceSelected))plugin_info.GetFunc("CSurf_SetSurfaceSelected")
    CSurf_SetSurfaceSolo = cast(type_of(CSurf_SetSurfaceSolo))plugin_info.GetFunc("CSurf_SetSurfaceSolo")
    CSurf_SetSurfaceVolume = cast(type_of(CSurf_SetSurfaceVolume))plugin_info.GetFunc("CSurf_SetSurfaceVolume")
    CSurf_SetTrackListChange = cast(type_of(CSurf_SetTrackListChange))plugin_info.GetFunc("CSurf_SetTrackListChange")
    CSurf_TrackFromID = cast(type_of(CSurf_TrackFromID))plugin_info.GetFunc("CSurf_TrackFromID")
    CSurf_TrackToID = cast(type_of(CSurf_TrackToID))plugin_info.GetFunc("CSurf_TrackToID")
    DB2SLIDER = cast(type_of(DB2SLIDER))plugin_info.GetFunc("DB2SLIDER")
    DeleteActionShortcut = cast(type_of(DeleteActionShortcut))plugin_info.GetFunc("DeleteActionShortcut")
    DeleteEnvelopePointEx = cast(type_of(DeleteEnvelopePointEx))plugin_info.GetFunc("DeleteEnvelopePointEx")
    DeleteEnvelopePointRange = cast(type_of(DeleteEnvelopePointRange))plugin_info.GetFunc("DeleteEnvelopePointRange")
    DeleteEnvelopePointRangeEx = cast(type_of(DeleteEnvelopePointRangeEx))plugin_info.GetFunc("DeleteEnvelopePointRangeEx")
    DeleteExtState = cast(type_of(DeleteExtState))plugin_info.GetFunc("DeleteExtState")
    DeleteProjectMarker = cast(type_of(DeleteProjectMarker))plugin_info.GetFunc("DeleteProjectMarker")
    DeleteProjectMarkerByIndex = cast(type_of(DeleteProjectMarkerByIndex))plugin_info.GetFunc("DeleteProjectMarkerByIndex")
    DeleteTakeMarker = cast(type_of(DeleteTakeMarker))plugin_info.GetFunc("DeleteTakeMarker")
    DeleteTakeStretchMarkers = cast(type_of(DeleteTakeStretchMarkers))plugin_info.GetFunc("DeleteTakeStretchMarkers")
    DeleteTempoTimeSigMarker = cast(type_of(DeleteTempoTimeSigMarker))plugin_info.GetFunc("DeleteTempoTimeSigMarker")
    DeleteTrack = cast(type_of(DeleteTrack))plugin_info.GetFunc("DeleteTrack")
    DeleteTrackMediaItem = cast(type_of(DeleteTrackMediaItem))plugin_info.GetFunc("DeleteTrackMediaItem")
    DestroyAudioAccessor = cast(type_of(DestroyAudioAccessor))plugin_info.GetFunc("DestroyAudioAccessor")
    DestroyLocalOscHandler = cast(type_of(DestroyLocalOscHandler))plugin_info.GetFunc("DestroyLocalOscHandler")
    DoActionShortcutDialog = cast(type_of(DoActionShortcutDialog))plugin_info.GetFunc("DoActionShortcutDialog")
    Dock_UpdateDockID = cast(type_of(Dock_UpdateDockID))plugin_info.GetFunc("Dock_UpdateDockID")
    DockGetPosition = cast(type_of(DockGetPosition))plugin_info.GetFunc("DockGetPosition")
    DockIsChildOfDock = cast(type_of(DockIsChildOfDock))plugin_info.GetFunc("DockIsChildOfDock")
    DockWindowActivate = cast(type_of(DockWindowActivate))plugin_info.GetFunc("DockWindowActivate")
    DockWindowAdd = cast(type_of(DockWindowAdd))plugin_info.GetFunc("DockWindowAdd")
    DockWindowAddEx = cast(type_of(DockWindowAddEx))plugin_info.GetFunc("DockWindowAddEx")
    DockWindowRefresh = cast(type_of(DockWindowRefresh))plugin_info.GetFunc("DockWindowRefresh")
    DockWindowRefreshForHWND = cast(type_of(DockWindowRefreshForHWND))plugin_info.GetFunc("DockWindowRefreshForHWND")
    DockWindowRemove = cast(type_of(DockWindowRemove))plugin_info.GetFunc("DockWindowRemove")
    DuplicateCustomizableMenu = cast(type_of(DuplicateCustomizableMenu))plugin_info.GetFunc("DuplicateCustomizableMenu")
    EditTempoTimeSigMarker = cast(type_of(EditTempoTimeSigMarker))plugin_info.GetFunc("EditTempoTimeSigMarker")
    EnsureNotCompletelyOffscreen = cast(type_of(EnsureNotCompletelyOffscreen))plugin_info.GetFunc("EnsureNotCompletelyOffscreen")
    EnumerateFiles = cast(type_of(EnumerateFiles))plugin_info.GetFunc("EnumerateFiles")
    EnumerateSubdirectories = cast(type_of(EnumerateSubdirectories))plugin_info.GetFunc("EnumerateSubdirectories")
    EnumPitchShiftModes = cast(type_of(EnumPitchShiftModes))plugin_info.GetFunc("EnumPitchShiftModes")
    EnumPitchShiftSubModes = cast(type_of(EnumPitchShiftSubModes))plugin_info.GetFunc("EnumPitchShiftSubModes")
    EnumProjectMarkers = cast(type_of(EnumProjectMarkers))plugin_info.GetFunc("EnumProjectMarkers")
    EnumProjectMarkers2 = cast(type_of(EnumProjectMarkers2))plugin_info.GetFunc("EnumProjectMarkers2")
    EnumProjectMarkers3 = cast(type_of(EnumProjectMarkers3))plugin_info.GetFunc("EnumProjectMarkers3")
    EnumProjects = cast(type_of(EnumProjects))plugin_info.GetFunc("EnumProjects")
    EnumProjExtState = cast(type_of(EnumProjExtState))plugin_info.GetFunc("EnumProjExtState")
    EnumRegionRenderMatrix = cast(type_of(EnumRegionRenderMatrix))plugin_info.GetFunc("EnumRegionRenderMatrix")
    EnumTrackMIDIProgramNames = cast(type_of(EnumTrackMIDIProgramNames))plugin_info.GetFunc("EnumTrackMIDIProgramNames")
    EnumTrackMIDIProgramNamesEx = cast(type_of(EnumTrackMIDIProgramNamesEx))plugin_info.GetFunc("EnumTrackMIDIProgramNamesEx")
    Envelope_Evaluate = cast(type_of(Envelope_Evaluate))plugin_info.GetFunc("Envelope_Evaluate")
    Envelope_FormatValue = cast(type_of(Envelope_FormatValue))plugin_info.GetFunc("Envelope_FormatValue")
    Envelope_GetParentTake = cast(type_of(Envelope_GetParentTake))plugin_info.GetFunc("Envelope_GetParentTake")
    Envelope_GetParentTrack = cast(type_of(Envelope_GetParentTrack))plugin_info.GetFunc("Envelope_GetParentTrack")
    Envelope_SortPoints = cast(type_of(Envelope_SortPoints))plugin_info.GetFunc("Envelope_SortPoints")
    Envelope_SortPointsEx = cast(type_of(Envelope_SortPointsEx))plugin_info.GetFunc("Envelope_SortPointsEx")
    ExecProcess = cast(type_of(ExecProcess))plugin_info.GetFunc("ExecProcess")
    file_exists = cast(type_of(file_exists))plugin_info.GetFunc("file_exists")
    FindTempoTimeSigMarker = cast(type_of(FindTempoTimeSigMarker))plugin_info.GetFunc("FindTempoTimeSigMarker")
    format_timestr = cast(type_of(format_timestr))plugin_info.GetFunc("format_timestr")
    format_timestr_len = cast(type_of(format_timestr_len))plugin_info.GetFunc("format_timestr_len")
    format_timestr_pos = cast(type_of(format_timestr_pos))plugin_info.GetFunc("format_timestr_pos")
    FreeHeapPtr = cast(type_of(FreeHeapPtr))plugin_info.GetFunc("FreeHeapPtr")
    genGuid = cast(type_of(genGuid))plugin_info.GetFunc("genGuid")
    get_config_var = cast(type_of(get_config_var))plugin_info.GetFunc("get_config_var")
    get_config_var_string = cast(type_of(get_config_var_string))plugin_info.GetFunc("get_config_var_string")
    get_ini_file = cast(type_of(get_ini_file))plugin_info.GetFunc("get_ini_file")
    get_midi_config_var = cast(type_of(get_midi_config_var))plugin_info.GetFunc("get_midi_config_var")
    GetActionShortcutDesc = cast(type_of(GetActionShortcutDesc))plugin_info.GetFunc("GetActionShortcutDesc")
    GetActiveTake = cast(type_of(GetActiveTake))plugin_info.GetFunc("GetActiveTake")
    GetAllProjectPlayStates = cast(type_of(GetAllProjectPlayStates))plugin_info.GetFunc("GetAllProjectPlayStates")
    GetAppVersion = cast(type_of(GetAppVersion))plugin_info.GetFunc("GetAppVersion")
    GetArmedCommand = cast(type_of(GetArmedCommand))plugin_info.GetFunc("GetArmedCommand")
    GetAudioAccessorEndTime = cast(type_of(GetAudioAccessorEndTime))plugin_info.GetFunc("GetAudioAccessorEndTime")
    GetAudioAccessorHash = cast(type_of(GetAudioAccessorHash))plugin_info.GetFunc("GetAudioAccessorHash")
    GetAudioAccessorSamples = cast(type_of(GetAudioAccessorSamples))plugin_info.GetFunc("GetAudioAccessorSamples")
    GetAudioAccessorStartTime = cast(type_of(GetAudioAccessorStartTime))plugin_info.GetFunc("GetAudioAccessorStartTime")
    GetAudioDeviceInfo = cast(type_of(GetAudioDeviceInfo))plugin_info.GetFunc("GetAudioDeviceInfo")
    GetColorTheme = cast(type_of(GetColorTheme))plugin_info.GetFunc("GetColorTheme")
    GetColorThemeStruct = cast(type_of(GetColorThemeStruct))plugin_info.GetFunc("GetColorThemeStruct")
    GetConfigWantsDock = cast(type_of(GetConfigWantsDock))plugin_info.GetFunc("GetConfigWantsDock")
    GetContextMenu = cast(type_of(GetContextMenu))plugin_info.GetFunc("GetContextMenu")
    GetCurrentProjectInLoadSave = cast(type_of(GetCurrentProjectInLoadSave))plugin_info.GetFunc("GetCurrentProjectInLoadSave")
    GetCursorContext = cast(type_of(GetCursorContext))plugin_info.GetFunc("GetCursorContext")
    GetCursorContext2 = cast(type_of(GetCursorContext2))plugin_info.GetFunc("GetCursorContext2")
    GetCursorPosition = cast(type_of(GetCursorPosition))plugin_info.GetFunc("GetCursorPosition")
    GetCursorPositionEx = cast(type_of(GetCursorPositionEx))plugin_info.GetFunc("GetCursorPositionEx")
    GetDisplayedMediaItemColor = cast(type_of(GetDisplayedMediaItemColor))plugin_info.GetFunc("GetDisplayedMediaItemColor")
    GetDisplayedMediaItemColor2 = cast(type_of(GetDisplayedMediaItemColor2))plugin_info.GetFunc("GetDisplayedMediaItemColor2")
    GetEnvelopeInfo_Value = cast(type_of(GetEnvelopeInfo_Value))plugin_info.GetFunc("GetEnvelopeInfo_Value")
    GetEnvelopeName = cast(type_of(GetEnvelopeName))plugin_info.GetFunc("GetEnvelopeName")
    GetEnvelopePoint = cast(type_of(GetEnvelopePoint))plugin_info.GetFunc("GetEnvelopePoint")
    GetEnvelopePointByTime = cast(type_of(GetEnvelopePointByTime))plugin_info.GetFunc("GetEnvelopePointByTime")
    GetEnvelopePointByTimeEx = cast(type_of(GetEnvelopePointByTimeEx))plugin_info.GetFunc("GetEnvelopePointByTimeEx")
    GetEnvelopePointEx = cast(type_of(GetEnvelopePointEx))plugin_info.GetFunc("GetEnvelopePointEx")
    GetEnvelopeScalingMode = cast(type_of(GetEnvelopeScalingMode))plugin_info.GetFunc("GetEnvelopeScalingMode")
    GetEnvelopeStateChunk = cast(type_of(GetEnvelopeStateChunk))plugin_info.GetFunc("GetEnvelopeStateChunk")
    GetExePath = cast(type_of(GetExePath))plugin_info.GetFunc("GetExePath")
    GetExtState = cast(type_of(GetExtState))plugin_info.GetFunc("GetExtState")
    GetFocusedFX = cast(type_of(GetFocusedFX))plugin_info.GetFunc("GetFocusedFX")
    GetFocusedFX2 = cast(type_of(GetFocusedFX2))plugin_info.GetFunc("GetFocusedFX2")
    GetFreeDiskSpaceForRecordPath = cast(type_of(GetFreeDiskSpaceForRecordPath))plugin_info.GetFunc("GetFreeDiskSpaceForRecordPath")
    GetFXEnvelope = cast(type_of(GetFXEnvelope))plugin_info.GetFunc("GetFXEnvelope")
    GetGlobalAutomationOverride = cast(type_of(GetGlobalAutomationOverride))plugin_info.GetFunc("GetGlobalAutomationOverride")
    GetHZoomLevel = cast(type_of(GetHZoomLevel))plugin_info.GetFunc("GetHZoomLevel")
    GetIconThemePointer = cast(type_of(GetIconThemePointer))plugin_info.GetFunc("GetIconThemePointer")
    GetIconThemePointerForDPI = cast(type_of(GetIconThemePointerForDPI))plugin_info.GetFunc("GetIconThemePointerForDPI")
    GetIconThemeStruct = cast(type_of(GetIconThemeStruct))plugin_info.GetFunc("GetIconThemeStruct")
    GetInputChannelName = cast(type_of(GetInputChannelName))plugin_info.GetFunc("GetInputChannelName")
    GetInputOutputLatency = cast(type_of(GetInputOutputLatency))plugin_info.GetFunc("GetInputOutputLatency")
    GetItemEditingTime2 = cast(type_of(GetItemEditingTime2))plugin_info.GetFunc("GetItemEditingTime2")
    GetItemFromPoint = cast(type_of(GetItemFromPoint))plugin_info.GetFunc("GetItemFromPoint")
    GetItemProjectContext = cast(type_of(GetItemProjectContext))plugin_info.GetFunc("GetItemProjectContext")
    GetItemStateChunk = cast(type_of(GetItemStateChunk))plugin_info.GetFunc("GetItemStateChunk")
    GetLastColorThemeFile = cast(type_of(GetLastColorThemeFile))plugin_info.GetFunc("GetLastColorThemeFile")
    GetLastMarkerAndCurRegion = cast(type_of(GetLastMarkerAndCurRegion))plugin_info.GetFunc("GetLastMarkerAndCurRegion")
    GetLastTouchedFX = cast(type_of(GetLastTouchedFX))plugin_info.GetFunc("GetLastTouchedFX")
    GetLastTouchedTrack = cast(type_of(GetLastTouchedTrack))plugin_info.GetFunc("GetLastTouchedTrack")
    GetMainHwnd = cast(type_of(GetMainHwnd))plugin_info.GetFunc("GetMainHwnd")
    GetMasterMuteSoloFlags = cast(type_of(GetMasterMuteSoloFlags))plugin_info.GetFunc("GetMasterMuteSoloFlags")
    GetMasterTrack = cast(type_of(GetMasterTrack))plugin_info.GetFunc("GetMasterTrack")
    GetMasterTrackVisibility = cast(type_of(GetMasterTrackVisibility))plugin_info.GetFunc("GetMasterTrackVisibility")
    GetMaxMidiInputs = cast(type_of(GetMaxMidiInputs))plugin_info.GetFunc("GetMaxMidiInputs")
    GetMaxMidiOutputs = cast(type_of(GetMaxMidiOutputs))plugin_info.GetFunc("GetMaxMidiOutputs")
    GetMediaFileMetadata = cast(type_of(GetMediaFileMetadata))plugin_info.GetFunc("GetMediaFileMetadata")
    GetMediaItem = cast(type_of(GetMediaItem))plugin_info.GetFunc("GetMediaItem")
    GetMediaItemInfo_Value = cast(type_of(GetMediaItemInfo_Value))plugin_info.GetFunc("GetMediaItemInfo_Value")
    GetMediaItemNumTakes = cast(type_of(GetMediaItemNumTakes))plugin_info.GetFunc("GetMediaItemNumTakes")
    GetMediaItemTake = cast(type_of(GetMediaItemTake))plugin_info.GetFunc("GetMediaItemTake")
    GetMediaItemTake_Item = cast(type_of(GetMediaItemTake_Item))plugin_info.GetFunc("GetMediaItemTake_Item")
    GetMediaItemTake_Peaks = cast(type_of(GetMediaItemTake_Peaks))plugin_info.GetFunc("GetMediaItemTake_Peaks")
    GetMediaItemTake_Source = cast(type_of(GetMediaItemTake_Source))plugin_info.GetFunc("GetMediaItemTake_Source")
    GetMediaItemTake_Track = cast(type_of(GetMediaItemTake_Track))plugin_info.GetFunc("GetMediaItemTake_Track")
    GetMediaItemTakeByGUID = cast(type_of(GetMediaItemTakeByGUID))plugin_info.GetFunc("GetMediaItemTakeByGUID")
    GetMediaItemTakeInfo_Value = cast(type_of(GetMediaItemTakeInfo_Value))plugin_info.GetFunc("GetMediaItemTakeInfo_Value")
    GetMediaItemTrack = cast(type_of(GetMediaItemTrack))plugin_info.GetFunc("GetMediaItemTrack")
    GetMediaSourceFileName = cast(type_of(GetMediaSourceFileName))plugin_info.GetFunc("GetMediaSourceFileName")
    GetMediaSourceLength = cast(type_of(GetMediaSourceLength))plugin_info.GetFunc("GetMediaSourceLength")
    GetMediaSourceNumChannels = cast(type_of(GetMediaSourceNumChannels))plugin_info.GetFunc("GetMediaSourceNumChannels")
    GetMediaSourceParent = cast(type_of(GetMediaSourceParent))plugin_info.GetFunc("GetMediaSourceParent")
    GetMediaSourceSampleRate = cast(type_of(GetMediaSourceSampleRate))plugin_info.GetFunc("GetMediaSourceSampleRate")
    GetMediaSourceType = cast(type_of(GetMediaSourceType))plugin_info.GetFunc("GetMediaSourceType")
    GetMediaTrackInfo_Value = cast(type_of(GetMediaTrackInfo_Value))plugin_info.GetFunc("GetMediaTrackInfo_Value")
    GetMIDIInputName = cast(type_of(GetMIDIInputName))plugin_info.GetFunc("GetMIDIInputName")
    GetMIDIOutputName = cast(type_of(GetMIDIOutputName))plugin_info.GetFunc("GetMIDIOutputName")
    GetMixerScroll = cast(type_of(GetMixerScroll))plugin_info.GetFunc("GetMixerScroll")
    GetMouseModifier = cast(type_of(GetMouseModifier))plugin_info.GetFunc("GetMouseModifier")
    GetMousePosition = cast(type_of(GetMousePosition))plugin_info.GetFunc("GetMousePosition")
    GetNumAudioInputs = cast(type_of(GetNumAudioInputs))plugin_info.GetFunc("GetNumAudioInputs")
    GetNumAudioOutputs = cast(type_of(GetNumAudioOutputs))plugin_info.GetFunc("GetNumAudioOutputs")
    GetNumMIDIInputs = cast(type_of(GetNumMIDIInputs))plugin_info.GetFunc("GetNumMIDIInputs")
    GetNumMIDIOutputs = cast(type_of(GetNumMIDIOutputs))plugin_info.GetFunc("GetNumMIDIOutputs")
    GetNumTakeMarkers = cast(type_of(GetNumTakeMarkers))plugin_info.GetFunc("GetNumTakeMarkers")
    GetNumTracks = cast(type_of(GetNumTracks))plugin_info.GetFunc("GetNumTracks")
    GetOS = cast(type_of(GetOS))plugin_info.GetFunc("GetOS")
    GetOutputChannelName = cast(type_of(GetOutputChannelName))plugin_info.GetFunc("GetOutputChannelName")
    GetOutputLatency = cast(type_of(GetOutputLatency))plugin_info.GetFunc("GetOutputLatency")
    GetParentTrack = cast(type_of(GetParentTrack))plugin_info.GetFunc("GetParentTrack")
    GetPeakFileName = cast(type_of(GetPeakFileName))plugin_info.GetFunc("GetPeakFileName")
    GetPeakFileNameEx = cast(type_of(GetPeakFileNameEx))plugin_info.GetFunc("GetPeakFileNameEx")
    GetPeakFileNameEx2 = cast(type_of(GetPeakFileNameEx2))plugin_info.GetFunc("GetPeakFileNameEx2")
    GetPeaksBitmap = cast(type_of(GetPeaksBitmap))plugin_info.GetFunc("GetPeaksBitmap")
    GetPlayPosition = cast(type_of(GetPlayPosition))plugin_info.GetFunc("GetPlayPosition")
    GetPlayPosition2 = cast(type_of(GetPlayPosition2))plugin_info.GetFunc("GetPlayPosition2")
    GetPlayPosition2Ex = cast(type_of(GetPlayPosition2Ex))plugin_info.GetFunc("GetPlayPosition2Ex")
    GetPlayPositionEx = cast(type_of(GetPlayPositionEx))plugin_info.GetFunc("GetPlayPositionEx")
    GetPlayState = cast(type_of(GetPlayState))plugin_info.GetFunc("GetPlayState")
    GetPlayStateEx = cast(type_of(GetPlayStateEx))plugin_info.GetFunc("GetPlayStateEx")
    GetPreferredDiskReadMode = cast(type_of(GetPreferredDiskReadMode))plugin_info.GetFunc("GetPreferredDiskReadMode")
    GetPreferredDiskReadModePeak = cast(type_of(GetPreferredDiskReadModePeak))plugin_info.GetFunc("GetPreferredDiskReadModePeak")
    GetPreferredDiskWriteMode = cast(type_of(GetPreferredDiskWriteMode))plugin_info.GetFunc("GetPreferredDiskWriteMode")
    GetProjectLength = cast(type_of(GetProjectLength))plugin_info.GetFunc("GetProjectLength")
    GetProjectName = cast(type_of(GetProjectName))plugin_info.GetFunc("GetProjectName")
    GetProjectPath = cast(type_of(GetProjectPath))plugin_info.GetFunc("GetProjectPath")
    GetProjectPathEx = cast(type_of(GetProjectPathEx))plugin_info.GetFunc("GetProjectPathEx")
    GetProjectStateChangeCount = cast(type_of(GetProjectStateChangeCount))plugin_info.GetFunc("GetProjectStateChangeCount")
    GetProjectTimeOffset = cast(type_of(GetProjectTimeOffset))plugin_info.GetFunc("GetProjectTimeOffset")
    GetProjectTimeSignature = cast(type_of(GetProjectTimeSignature))plugin_info.GetFunc("GetProjectTimeSignature")
    GetProjectTimeSignature2 = cast(type_of(GetProjectTimeSignature2))plugin_info.GetFunc("GetProjectTimeSignature2")
    GetProjExtState = cast(type_of(GetProjExtState))plugin_info.GetFunc("GetProjExtState")
    GetResourcePath = cast(type_of(GetResourcePath))plugin_info.GetFunc("GetResourcePath")
    GetSelectedEnvelope = cast(type_of(GetSelectedEnvelope))plugin_info.GetFunc("GetSelectedEnvelope")
    GetSelectedMediaItem = cast(type_of(GetSelectedMediaItem))plugin_info.GetFunc("GetSelectedMediaItem")
    GetSelectedTrack = cast(type_of(GetSelectedTrack))plugin_info.GetFunc("GetSelectedTrack")
    GetSelectedTrack2 = cast(type_of(GetSelectedTrack2))plugin_info.GetFunc("GetSelectedTrack2")
    GetSelectedTrackEnvelope = cast(type_of(GetSelectedTrackEnvelope))plugin_info.GetFunc("GetSelectedTrackEnvelope")
    GetSet_ArrangeView2 = cast(type_of(GetSet_ArrangeView2))plugin_info.GetFunc("GetSet_ArrangeView2")
    GetSet_LoopTimeRange = cast(type_of(GetSet_LoopTimeRange))plugin_info.GetFunc("GetSet_LoopTimeRange")
    GetSet_LoopTimeRange2 = cast(type_of(GetSet_LoopTimeRange2))plugin_info.GetFunc("GetSet_LoopTimeRange2")
    GetSetAutomationItemInfo = cast(type_of(GetSetAutomationItemInfo))plugin_info.GetFunc("GetSetAutomationItemInfo")
    GetSetAutomationItemInfo_String = cast(type_of(GetSetAutomationItemInfo_String))plugin_info.GetFunc("GetSetAutomationItemInfo_String")
    GetSetEnvelopeInfo_String = cast(type_of(GetSetEnvelopeInfo_String))plugin_info.GetFunc("GetSetEnvelopeInfo_String")
    GetSetEnvelopeState = cast(type_of(GetSetEnvelopeState))plugin_info.GetFunc("GetSetEnvelopeState")
    GetSetEnvelopeState2 = cast(type_of(GetSetEnvelopeState2))plugin_info.GetFunc("GetSetEnvelopeState2")
    GetSetItemState = cast(type_of(GetSetItemState))plugin_info.GetFunc("GetSetItemState")
    GetSetItemState2 = cast(type_of(GetSetItemState2))plugin_info.GetFunc("GetSetItemState2")
    GetSetMediaItemInfo = cast(type_of(GetSetMediaItemInfo))plugin_info.GetFunc("GetSetMediaItemInfo")
    GetSetMediaItemInfo_String = cast(type_of(GetSetMediaItemInfo_String))plugin_info.GetFunc("GetSetMediaItemInfo_String")
    GetSetMediaItemTakeInfo = cast(type_of(GetSetMediaItemTakeInfo))plugin_info.GetFunc("GetSetMediaItemTakeInfo")
    GetSetMediaItemTakeInfo_String = cast(type_of(GetSetMediaItemTakeInfo_String))plugin_info.GetFunc("GetSetMediaItemTakeInfo_String")
    GetSetMediaTrackInfo = cast(type_of(GetSetMediaTrackInfo))plugin_info.GetFunc("GetSetMediaTrackInfo")
    GetSetMediaTrackInfo_String = cast(type_of(GetSetMediaTrackInfo_String))plugin_info.GetFunc("GetSetMediaTrackInfo_String")
    GetSetObjectState = cast(type_of(GetSetObjectState))plugin_info.GetFunc("GetSetObjectState")
    GetSetObjectState2 = cast(type_of(GetSetObjectState2))plugin_info.GetFunc("GetSetObjectState2")
    GetSetProjectAuthor = cast(type_of(GetSetProjectAuthor))plugin_info.GetFunc("GetSetProjectAuthor")
    GetSetProjectGrid = cast(type_of(GetSetProjectGrid))plugin_info.GetFunc("GetSetProjectGrid")
    GetSetProjectInfo = cast(type_of(GetSetProjectInfo))plugin_info.GetFunc("GetSetProjectInfo")
    GetSetProjectInfo_String = cast(type_of(GetSetProjectInfo_String))plugin_info.GetFunc("GetSetProjectInfo_String")
    GetSetProjectNotes = cast(type_of(GetSetProjectNotes))plugin_info.GetFunc("GetSetProjectNotes")
    GetSetRepeat = cast(type_of(GetSetRepeat))plugin_info.GetFunc("GetSetRepeat")
    GetSetRepeatEx = cast(type_of(GetSetRepeatEx))plugin_info.GetFunc("GetSetRepeatEx")
    GetSetTrackGroupMembership = cast(type_of(GetSetTrackGroupMembership))plugin_info.GetFunc("GetSetTrackGroupMembership")
    GetSetTrackGroupMembershipHigh = cast(type_of(GetSetTrackGroupMembershipHigh))plugin_info.GetFunc("GetSetTrackGroupMembershipHigh")
    GetSetTrackMIDISupportFile = cast(type_of(GetSetTrackMIDISupportFile))plugin_info.GetFunc("GetSetTrackMIDISupportFile")
    GetSetTrackSendInfo = cast(type_of(GetSetTrackSendInfo))plugin_info.GetFunc("GetSetTrackSendInfo")
    GetSetTrackSendInfo_String = cast(type_of(GetSetTrackSendInfo_String))plugin_info.GetFunc("GetSetTrackSendInfo_String")
    GetSetTrackState = cast(type_of(GetSetTrackState))plugin_info.GetFunc("GetSetTrackState")
    GetSetTrackState2 = cast(type_of(GetSetTrackState2))plugin_info.GetFunc("GetSetTrackState2")
    GetSubProjectFromSource = cast(type_of(GetSubProjectFromSource))plugin_info.GetFunc("GetSubProjectFromSource")
    GetTake = cast(type_of(GetTake))plugin_info.GetFunc("GetTake")
    GetTakeEnvelope = cast(type_of(GetTakeEnvelope))plugin_info.GetFunc("GetTakeEnvelope")
    GetTakeEnvelopeByName = cast(type_of(GetTakeEnvelopeByName))plugin_info.GetFunc("GetTakeEnvelopeByName")
    GetTakeMarker = cast(type_of(GetTakeMarker))plugin_info.GetFunc("GetTakeMarker")
    GetTakeName = cast(type_of(GetTakeName))plugin_info.GetFunc("GetTakeName")
    GetTakeNumStretchMarkers = cast(type_of(GetTakeNumStretchMarkers))plugin_info.GetFunc("GetTakeNumStretchMarkers")
    GetTakeStretchMarker = cast(type_of(GetTakeStretchMarker))plugin_info.GetFunc("GetTakeStretchMarker")
    GetTakeStretchMarkerSlope = cast(type_of(GetTakeStretchMarkerSlope))plugin_info.GetFunc("GetTakeStretchMarkerSlope")
    GetTCPFXParm = cast(type_of(GetTCPFXParm))plugin_info.GetFunc("GetTCPFXParm")
    GetTempoMatchPlayRate = cast(type_of(GetTempoMatchPlayRate))plugin_info.GetFunc("GetTempoMatchPlayRate")
    GetTempoTimeSigMarker = cast(type_of(GetTempoTimeSigMarker))plugin_info.GetFunc("GetTempoTimeSigMarker")
    GetThemeColor = cast(type_of(GetThemeColor))plugin_info.GetFunc("GetThemeColor")
    GetToggleCommandState = cast(type_of(GetToggleCommandState))plugin_info.GetFunc("GetToggleCommandState")
    GetToggleCommandState2 = cast(type_of(GetToggleCommandState2))plugin_info.GetFunc("GetToggleCommandState2")
    GetToggleCommandStateEx = cast(type_of(GetToggleCommandStateEx))plugin_info.GetFunc("GetToggleCommandStateEx")
    GetToggleCommandStateThroughHooks = cast(type_of(GetToggleCommandStateThroughHooks))plugin_info.GetFunc("GetToggleCommandStateThroughHooks")
    GetTooltipWindow = cast(type_of(GetTooltipWindow))plugin_info.GetFunc("GetTooltipWindow")
    GetTrack = cast(type_of(GetTrack))plugin_info.GetFunc("GetTrack")
    GetTrackAutomationMode = cast(type_of(GetTrackAutomationMode))plugin_info.GetFunc("GetTrackAutomationMode")
    GetTrackColor = cast(type_of(GetTrackColor))plugin_info.GetFunc("GetTrackColor")
    GetTrackDepth = cast(type_of(GetTrackDepth))plugin_info.GetFunc("GetTrackDepth")
    GetTrackEnvelope = cast(type_of(GetTrackEnvelope))plugin_info.GetFunc("GetTrackEnvelope")
    GetTrackEnvelopeByChunkName = cast(type_of(GetTrackEnvelopeByChunkName))plugin_info.GetFunc("GetTrackEnvelopeByChunkName")
    GetTrackEnvelopeByName = cast(type_of(GetTrackEnvelopeByName))plugin_info.GetFunc("GetTrackEnvelopeByName")
    GetTrackFromPoint = cast(type_of(GetTrackFromPoint))plugin_info.GetFunc("GetTrackFromPoint")
    GetTrackGUID = cast(type_of(GetTrackGUID))plugin_info.GetFunc("GetTrackGUID")
    GetTrackInfo = cast(type_of(GetTrackInfo))plugin_info.GetFunc("GetTrackInfo")
    GetTrackMediaItem = cast(type_of(GetTrackMediaItem))plugin_info.GetFunc("GetTrackMediaItem")
    GetTrackMIDILyrics = cast(type_of(GetTrackMIDILyrics))plugin_info.GetFunc("GetTrackMIDILyrics")
    GetTrackMIDINoteName = cast(type_of(GetTrackMIDINoteName))plugin_info.GetFunc("GetTrackMIDINoteName")
    GetTrackMIDINoteNameEx = cast(type_of(GetTrackMIDINoteNameEx))plugin_info.GetFunc("GetTrackMIDINoteNameEx")
    GetTrackMIDINoteRange = cast(type_of(GetTrackMIDINoteRange))plugin_info.GetFunc("GetTrackMIDINoteRange")
    GetTrackName = cast(type_of(GetTrackName))plugin_info.GetFunc("GetTrackName")
    GetTrackNumMediaItems = cast(type_of(GetTrackNumMediaItems))plugin_info.GetFunc("GetTrackNumMediaItems")
    GetTrackNumSends = cast(type_of(GetTrackNumSends))plugin_info.GetFunc("GetTrackNumSends")
    GetTrackReceiveName = cast(type_of(GetTrackReceiveName))plugin_info.GetFunc("GetTrackReceiveName")
    GetTrackReceiveUIMute = cast(type_of(GetTrackReceiveUIMute))plugin_info.GetFunc("GetTrackReceiveUIMute")
    GetTrackReceiveUIVolPan = cast(type_of(GetTrackReceiveUIVolPan))plugin_info.GetFunc("GetTrackReceiveUIVolPan")
    GetTrackSendInfo_Value = cast(type_of(GetTrackSendInfo_Value))plugin_info.GetFunc("GetTrackSendInfo_Value")
    GetTrackSendName = cast(type_of(GetTrackSendName))plugin_info.GetFunc("GetTrackSendName")
    GetTrackSendUIMute = cast(type_of(GetTrackSendUIMute))plugin_info.GetFunc("GetTrackSendUIMute")
    GetTrackSendUIVolPan = cast(type_of(GetTrackSendUIVolPan))plugin_info.GetFunc("GetTrackSendUIVolPan")
    GetTrackState = cast(type_of(GetTrackState))plugin_info.GetFunc("GetTrackState")
    GetTrackStateChunk = cast(type_of(GetTrackStateChunk))plugin_info.GetFunc("GetTrackStateChunk")
    GetTrackUIMute = cast(type_of(GetTrackUIMute))plugin_info.GetFunc("GetTrackUIMute")
    GetTrackUIPan = cast(type_of(GetTrackUIPan))plugin_info.GetFunc("GetTrackUIPan")
    GetTrackUIVolPan = cast(type_of(GetTrackUIVolPan))plugin_info.GetFunc("GetTrackUIVolPan")
    GetUnderrunTime = cast(type_of(GetUnderrunTime))plugin_info.GetFunc("GetUnderrunTime")
    GetUserFileNameForRead = cast(type_of(GetUserFileNameForRead))plugin_info.GetFunc("GetUserFileNameForRead")
    GetUserInputs = cast(type_of(GetUserInputs))plugin_info.GetFunc("GetUserInputs")
    GoToMarker = cast(type_of(GoToMarker))plugin_info.GetFunc("GoToMarker")
    GoToRegion = cast(type_of(GoToRegion))plugin_info.GetFunc("GoToRegion")
    GR_SelectColor = cast(type_of(GR_SelectColor))plugin_info.GetFunc("GR_SelectColor")
    GSC_mainwnd = cast(type_of(GSC_mainwnd))plugin_info.GetFunc("GSC_mainwnd")
    guidToString = cast(type_of(guidToString))plugin_info.GetFunc("guidToString")
    HasExtState = cast(type_of(HasExtState))plugin_info.GetFunc("HasExtState")
    HasTrackMIDIPrograms = cast(type_of(HasTrackMIDIPrograms))plugin_info.GetFunc("HasTrackMIDIPrograms")
    HasTrackMIDIProgramsEx = cast(type_of(HasTrackMIDIProgramsEx))plugin_info.GetFunc("HasTrackMIDIProgramsEx")
    Help_Set = cast(type_of(Help_Set))plugin_info.GetFunc("Help_Set")
    HiresPeaksFromSource = cast(type_of(HiresPeaksFromSource))plugin_info.GetFunc("HiresPeaksFromSource")
    image_resolve_fn = cast(type_of(image_resolve_fn))plugin_info.GetFunc("image_resolve_fn")
    InsertAutomationItem = cast(type_of(InsertAutomationItem))plugin_info.GetFunc("InsertAutomationItem")
    InsertEnvelopePoint = cast(type_of(InsertEnvelopePoint))plugin_info.GetFunc("InsertEnvelopePoint")
    InsertEnvelopePointEx = cast(type_of(InsertEnvelopePointEx))plugin_info.GetFunc("InsertEnvelopePointEx")
    InsertMedia = cast(type_of(InsertMedia))plugin_info.GetFunc("InsertMedia")
    InsertMediaSection = cast(type_of(InsertMediaSection))plugin_info.GetFunc("InsertMediaSection")
    InsertTrackAtIndex = cast(type_of(InsertTrackAtIndex))plugin_info.GetFunc("InsertTrackAtIndex")
    IsInRealTimeAudio = cast(type_of(IsInRealTimeAudio))plugin_info.GetFunc("IsInRealTimeAudio")
    IsItemTakeActiveForPlayback = cast(type_of(IsItemTakeActiveForPlayback))plugin_info.GetFunc("IsItemTakeActiveForPlayback")
    IsMediaExtension = cast(type_of(IsMediaExtension))plugin_info.GetFunc("IsMediaExtension")
    IsMediaItemSelected = cast(type_of(IsMediaItemSelected))plugin_info.GetFunc("IsMediaItemSelected")
    IsProjectDirty = cast(type_of(IsProjectDirty))plugin_info.GetFunc("IsProjectDirty")
    IsREAPER = cast(type_of(IsREAPER))plugin_info.GetFunc("IsREAPER")
    IsTrackSelected = cast(type_of(IsTrackSelected))plugin_info.GetFunc("IsTrackSelected")
    IsTrackVisible = cast(type_of(IsTrackVisible))plugin_info.GetFunc("IsTrackVisible")
    joystick_create = cast(type_of(joystick_create))plugin_info.GetFunc("joystick_create")
    joystick_destroy = cast(type_of(joystick_destroy))plugin_info.GetFunc("joystick_destroy")
    joystick_enum = cast(type_of(joystick_enum))plugin_info.GetFunc("joystick_enum")
    joystick_getaxis = cast(type_of(joystick_getaxis))plugin_info.GetFunc("joystick_getaxis")
    joystick_getbuttonmask = cast(type_of(joystick_getbuttonmask))plugin_info.GetFunc("joystick_getbuttonmask")
    joystick_getinfo = cast(type_of(joystick_getinfo))plugin_info.GetFunc("joystick_getinfo")
    joystick_getpov = cast(type_of(joystick_getpov))plugin_info.GetFunc("joystick_getpov")
    joystick_update = cast(type_of(joystick_update))plugin_info.GetFunc("joystick_update")
    kbd_enumerateActions = cast(type_of(kbd_enumerateActions))plugin_info.GetFunc("kbd_enumerateActions")
    kbd_formatKeyName = cast(type_of(kbd_formatKeyName))plugin_info.GetFunc("kbd_formatKeyName")
    kbd_getCommandName = cast(type_of(kbd_getCommandName))plugin_info.GetFunc("kbd_getCommandName")
    kbd_getTextFromCmd = cast(type_of(kbd_getTextFromCmd))plugin_info.GetFunc("kbd_getTextFromCmd")
    KBD_OnMainActionEx = cast(type_of(KBD_OnMainActionEx))plugin_info.GetFunc("KBD_OnMainActionEx")
    kbd_OnMidiEvent = cast(type_of(kbd_OnMidiEvent))plugin_info.GetFunc("kbd_OnMidiEvent")
    kbd_OnMidiList = cast(type_of(kbd_OnMidiList))plugin_info.GetFunc("kbd_OnMidiList")
    kbd_ProcessActionsMenu = cast(type_of(kbd_ProcessActionsMenu))plugin_info.GetFunc("kbd_ProcessActionsMenu")
    kbd_processMidiEventActionEx = cast(type_of(kbd_processMidiEventActionEx))plugin_info.GetFunc("kbd_processMidiEventActionEx")
    kbd_reprocessMenu = cast(type_of(kbd_reprocessMenu))plugin_info.GetFunc("kbd_reprocessMenu")
    kbd_RunCommandThroughHooks = cast(type_of(kbd_RunCommandThroughHooks))plugin_info.GetFunc("kbd_RunCommandThroughHooks")
    kbd_translateAccelerator = cast(type_of(kbd_translateAccelerator))plugin_info.GetFunc("kbd_translateAccelerator")
    kbd_translateMouse = cast(type_of(kbd_translateMouse))plugin_info.GetFunc("kbd_translateMouse")
    LICE__Destroy = cast(type_of(LICE__Destroy))plugin_info.GetFunc("LICE__Destroy")
    LICE__DestroyFont = cast(type_of(LICE__DestroyFont))plugin_info.GetFunc("LICE__DestroyFont")
    LICE__DrawText = cast(type_of(LICE__DrawText))plugin_info.GetFunc("LICE__DrawText")
    LICE__GetBits = cast(type_of(LICE__GetBits))plugin_info.GetFunc("LICE__GetBits")
    LICE__GetDC = cast(type_of(LICE__GetDC))plugin_info.GetFunc("LICE__GetDC")
    LICE__GetHeight = cast(type_of(LICE__GetHeight))plugin_info.GetFunc("LICE__GetHeight")
    LICE__GetRowSpan = cast(type_of(LICE__GetRowSpan))plugin_info.GetFunc("LICE__GetRowSpan")
    LICE__GetWidth = cast(type_of(LICE__GetWidth))plugin_info.GetFunc("LICE__GetWidth")
    LICE__IsFlipped = cast(type_of(LICE__IsFlipped))plugin_info.GetFunc("LICE__IsFlipped")
    LICE__resize = cast(type_of(LICE__resize))plugin_info.GetFunc("LICE__resize")
    LICE__SetBkColor = cast(type_of(LICE__SetBkColor))plugin_info.GetFunc("LICE__SetBkColor")
    LICE__SetFromHFont = cast(type_of(LICE__SetFromHFont))plugin_info.GetFunc("LICE__SetFromHFont")
    LICE__SetTextColor = cast(type_of(LICE__SetTextColor))plugin_info.GetFunc("LICE__SetTextColor")
    LICE__SetTextCombineMode = cast(type_of(LICE__SetTextCombineMode))plugin_info.GetFunc("LICE__SetTextCombineMode")
    LICE_Arc = cast(type_of(LICE_Arc))plugin_info.GetFunc("LICE_Arc")
    LICE_Blit = cast(type_of(LICE_Blit))plugin_info.GetFunc("LICE_Blit")
    LICE_Blur = cast(type_of(LICE_Blur))plugin_info.GetFunc("LICE_Blur")
    LICE_BorderedRect = cast(type_of(LICE_BorderedRect))plugin_info.GetFunc("LICE_BorderedRect")
    LICE_Circle = cast(type_of(LICE_Circle))plugin_info.GetFunc("LICE_Circle")
    LICE_Clear = cast(type_of(LICE_Clear))plugin_info.GetFunc("LICE_Clear")
    LICE_ClearRect = cast(type_of(LICE_ClearRect))plugin_info.GetFunc("LICE_ClearRect")
    LICE_ClipLine = cast(type_of(LICE_ClipLine))plugin_info.GetFunc("LICE_ClipLine")
    LICE_Copy = cast(type_of(LICE_Copy))plugin_info.GetFunc("LICE_Copy")
    LICE_CreateBitmap = cast(type_of(LICE_CreateBitmap))plugin_info.GetFunc("LICE_CreateBitmap")
    LICE_CreateFont = cast(type_of(LICE_CreateFont))plugin_info.GetFunc("LICE_CreateFont")
    LICE_DrawCBezier = cast(type_of(LICE_DrawCBezier))plugin_info.GetFunc("LICE_DrawCBezier")
    LICE_DrawChar = cast(type_of(LICE_DrawChar))plugin_info.GetFunc("LICE_DrawChar")
    LICE_DrawGlyph = cast(type_of(LICE_DrawGlyph))plugin_info.GetFunc("LICE_DrawGlyph")
    LICE_DrawRect = cast(type_of(LICE_DrawRect))plugin_info.GetFunc("LICE_DrawRect")
    LICE_DrawText = cast(type_of(LICE_DrawText))plugin_info.GetFunc("LICE_DrawText")
    LICE_FillCBezier = cast(type_of(LICE_FillCBezier))plugin_info.GetFunc("LICE_FillCBezier")
    LICE_FillCircle = cast(type_of(LICE_FillCircle))plugin_info.GetFunc("LICE_FillCircle")
    LICE_FillConvexPolygon = cast(type_of(LICE_FillConvexPolygon))plugin_info.GetFunc("LICE_FillConvexPolygon")
    LICE_FillRect = cast(type_of(LICE_FillRect))plugin_info.GetFunc("LICE_FillRect")
    LICE_FillTrapezoid = cast(type_of(LICE_FillTrapezoid))plugin_info.GetFunc("LICE_FillTrapezoid")
    LICE_FillTriangle = cast(type_of(LICE_FillTriangle))plugin_info.GetFunc("LICE_FillTriangle")
    LICE_GetPixel = cast(type_of(LICE_GetPixel))plugin_info.GetFunc("LICE_GetPixel")
    LICE_GradRect = cast(type_of(LICE_GradRect))plugin_info.GetFunc("LICE_GradRect")
    LICE_Line = cast(type_of(LICE_Line))plugin_info.GetFunc("LICE_Line")
    LICE_ThickFLine = cast(type_of(LICE_ThickFLine))plugin_info.GetFunc("LICE_ThickFLine")
    LICE_LineInt = cast(type_of(LICE_LineInt))plugin_info.GetFunc("LICE_LineInt")
    LICE_LoadPNG = cast(type_of(LICE_LoadPNG))plugin_info.GetFunc("LICE_LoadPNG")
    LICE_LoadPNGFromResource = cast(type_of(LICE_LoadPNGFromResource))plugin_info.GetFunc("LICE_LoadPNGFromResource")
    LICE_MeasureText = cast(type_of(LICE_MeasureText))plugin_info.GetFunc("LICE_MeasureText")
    LICE_MultiplyAddRect = cast(type_of(LICE_MultiplyAddRect))plugin_info.GetFunc("LICE_MultiplyAddRect")
    LICE_PutPixel = cast(type_of(LICE_PutPixel))plugin_info.GetFunc("LICE_PutPixel")
    LICE_RotatedBlit = cast(type_of(LICE_RotatedBlit))plugin_info.GetFunc("LICE_RotatedBlit")
    LICE_RoundRect = cast(type_of(LICE_RoundRect))plugin_info.GetFunc("LICE_RoundRect")
    LICE_ScaledBlit = cast(type_of(LICE_ScaledBlit))plugin_info.GetFunc("LICE_ScaledBlit")
    LICE_SimpleFill = cast(type_of(LICE_SimpleFill))plugin_info.GetFunc("LICE_SimpleFill")
    LocalizeString = cast(type_of(LocalizeString))plugin_info.GetFunc("LocalizeString")
    Loop_OnArrow = cast(type_of(Loop_OnArrow))plugin_info.GetFunc("Loop_OnArrow")
    Main_OnCommand = cast(type_of(Main_OnCommand))plugin_info.GetFunc("Main_OnCommand")
    Main_OnCommandEx = cast(type_of(Main_OnCommandEx))plugin_info.GetFunc("Main_OnCommandEx")
    Main_openProject = cast(type_of(Main_openProject))plugin_info.GetFunc("Main_openProject")
    Main_SaveProject = cast(type_of(Main_SaveProject))plugin_info.GetFunc("Main_SaveProject")
    Main_UpdateLoopInfo = cast(type_of(Main_UpdateLoopInfo))plugin_info.GetFunc("Main_UpdateLoopInfo")
    MarkProjectDirty = cast(type_of(MarkProjectDirty))plugin_info.GetFunc("MarkProjectDirty")
    MarkTrackItemsDirty = cast(type_of(MarkTrackItemsDirty))plugin_info.GetFunc("MarkTrackItemsDirty")
    Master_GetPlayRate = cast(type_of(Master_GetPlayRate))plugin_info.GetFunc("Master_GetPlayRate")
    Master_GetPlayRateAtTime = cast(type_of(Master_GetPlayRateAtTime))plugin_info.GetFunc("Master_GetPlayRateAtTime")
    Master_GetTempo = cast(type_of(Master_GetTempo))plugin_info.GetFunc("Master_GetTempo")
    Master_NormalizePlayRate = cast(type_of(Master_NormalizePlayRate))plugin_info.GetFunc("Master_NormalizePlayRate")
    Master_NormalizeTempo = cast(type_of(Master_NormalizeTempo))plugin_info.GetFunc("Master_NormalizeTempo")
    MB = cast(type_of(MB))plugin_info.GetFunc("MB")
    MediaItemDescendsFromTrack = cast(type_of(MediaItemDescendsFromTrack))plugin_info.GetFunc("MediaItemDescendsFromTrack")
    MIDI_CountEvts = cast(type_of(MIDI_CountEvts))plugin_info.GetFunc("MIDI_CountEvts")
    MIDI_DeleteCC = cast(type_of(MIDI_DeleteCC))plugin_info.GetFunc("MIDI_DeleteCC")
    MIDI_DeleteEvt = cast(type_of(MIDI_DeleteEvt))plugin_info.GetFunc("MIDI_DeleteEvt")
    MIDI_DeleteNote = cast(type_of(MIDI_DeleteNote))plugin_info.GetFunc("MIDI_DeleteNote")
    MIDI_DeleteTextSysexEvt = cast(type_of(MIDI_DeleteTextSysexEvt))plugin_info.GetFunc("MIDI_DeleteTextSysexEvt")
    MIDI_DisableSort = cast(type_of(MIDI_DisableSort))plugin_info.GetFunc("MIDI_DisableSort")
    MIDI_EnumSelCC = cast(type_of(MIDI_EnumSelCC))plugin_info.GetFunc("MIDI_EnumSelCC")
    MIDI_EnumSelEvts = cast(type_of(MIDI_EnumSelEvts))plugin_info.GetFunc("MIDI_EnumSelEvts")
    MIDI_EnumSelNotes = cast(type_of(MIDI_EnumSelNotes))plugin_info.GetFunc("MIDI_EnumSelNotes")
    MIDI_EnumSelTextSysexEvts = cast(type_of(MIDI_EnumSelTextSysexEvts))plugin_info.GetFunc("MIDI_EnumSelTextSysexEvts")
    MIDI_eventlist_Create = cast(type_of(MIDI_eventlist_Create))plugin_info.GetFunc("MIDI_eventlist_Create")
    MIDI_eventlist_Destroy = cast(type_of(MIDI_eventlist_Destroy))plugin_info.GetFunc("MIDI_eventlist_Destroy")
    MIDI_GetAllEvts = cast(type_of(MIDI_GetAllEvts))plugin_info.GetFunc("MIDI_GetAllEvts")
    MIDI_GetCC = cast(type_of(MIDI_GetCC))plugin_info.GetFunc("MIDI_GetCC")
    MIDI_GetCCShape = cast(type_of(MIDI_GetCCShape))plugin_info.GetFunc("MIDI_GetCCShape")
    MIDI_GetEvt = cast(type_of(MIDI_GetEvt))plugin_info.GetFunc("MIDI_GetEvt")
    MIDI_GetGrid = cast(type_of(MIDI_GetGrid))plugin_info.GetFunc("MIDI_GetGrid")
    MIDI_GetHash = cast(type_of(MIDI_GetHash))plugin_info.GetFunc("MIDI_GetHash")
    MIDI_GetNote = cast(type_of(MIDI_GetNote))plugin_info.GetFunc("MIDI_GetNote")
    MIDI_GetPPQPos_EndOfMeasure = cast(type_of(MIDI_GetPPQPos_EndOfMeasure))plugin_info.GetFunc("MIDI_GetPPQPos_EndOfMeasure")
    MIDI_GetPPQPos_StartOfMeasure = cast(type_of(MIDI_GetPPQPos_StartOfMeasure))plugin_info.GetFunc("MIDI_GetPPQPos_StartOfMeasure")
    MIDI_GetPPQPosFromProjQN = cast(type_of(MIDI_GetPPQPosFromProjQN))plugin_info.GetFunc("MIDI_GetPPQPosFromProjQN")
    MIDI_GetPPQPosFromProjTime = cast(type_of(MIDI_GetPPQPosFromProjTime))plugin_info.GetFunc("MIDI_GetPPQPosFromProjTime")
    MIDI_GetProjQNFromPPQPos = cast(type_of(MIDI_GetProjQNFromPPQPos))plugin_info.GetFunc("MIDI_GetProjQNFromPPQPos")
    MIDI_GetProjTimeFromPPQPos = cast(type_of(MIDI_GetProjTimeFromPPQPos))plugin_info.GetFunc("MIDI_GetProjTimeFromPPQPos")
    MIDI_GetScale = cast(type_of(MIDI_GetScale))plugin_info.GetFunc("MIDI_GetScale")
    MIDI_GetTextSysexEvt = cast(type_of(MIDI_GetTextSysexEvt))plugin_info.GetFunc("MIDI_GetTextSysexEvt")
    MIDI_GetTrackHash = cast(type_of(MIDI_GetTrackHash))plugin_info.GetFunc("MIDI_GetTrackHash")
    MIDI_InsertCC = cast(type_of(MIDI_InsertCC))plugin_info.GetFunc("MIDI_InsertCC")
    MIDI_InsertEvt = cast(type_of(MIDI_InsertEvt))plugin_info.GetFunc("MIDI_InsertEvt")
    MIDI_InsertNote = cast(type_of(MIDI_InsertNote))plugin_info.GetFunc("MIDI_InsertNote")
    MIDI_InsertTextSysexEvt = cast(type_of(MIDI_InsertTextSysexEvt))plugin_info.GetFunc("MIDI_InsertTextSysexEvt")
    midi_reinit = cast(type_of(midi_reinit))plugin_info.GetFunc("midi_reinit")
    MIDI_SelectAll = cast(type_of(MIDI_SelectAll))plugin_info.GetFunc("MIDI_SelectAll")
    MIDI_SetAllEvts = cast(type_of(MIDI_SetAllEvts))plugin_info.GetFunc("MIDI_SetAllEvts")
    MIDI_SetCC = cast(type_of(MIDI_SetCC))plugin_info.GetFunc("MIDI_SetCC")
    MIDI_SetCCShape = cast(type_of(MIDI_SetCCShape))plugin_info.GetFunc("MIDI_SetCCShape")
    MIDI_SetEvt = cast(type_of(MIDI_SetEvt))plugin_info.GetFunc("MIDI_SetEvt")
    MIDI_SetItemExtents = cast(type_of(MIDI_SetItemExtents))plugin_info.GetFunc("MIDI_SetItemExtents")
    MIDI_SetNote = cast(type_of(MIDI_SetNote))plugin_info.GetFunc("MIDI_SetNote")
    MIDI_SetTextSysexEvt = cast(type_of(MIDI_SetTextSysexEvt))plugin_info.GetFunc("MIDI_SetTextSysexEvt")
    MIDI_Sort = cast(type_of(MIDI_Sort))plugin_info.GetFunc("MIDI_Sort")
    MIDIEditor_GetActive = cast(type_of(MIDIEditor_GetActive))plugin_info.GetFunc("MIDIEditor_GetActive")
    MIDIEditor_GetMode = cast(type_of(MIDIEditor_GetMode))plugin_info.GetFunc("MIDIEditor_GetMode")
    MIDIEditor_GetSetting_int = cast(type_of(MIDIEditor_GetSetting_int))plugin_info.GetFunc("MIDIEditor_GetSetting_int")
    MIDIEditor_GetSetting_str = cast(type_of(MIDIEditor_GetSetting_str))plugin_info.GetFunc("MIDIEditor_GetSetting_str")
    MIDIEditor_GetTake = cast(type_of(MIDIEditor_GetTake))plugin_info.GetFunc("MIDIEditor_GetTake")
    MIDIEditor_LastFocused_OnCommand = cast(type_of(MIDIEditor_LastFocused_OnCommand))plugin_info.GetFunc("MIDIEditor_LastFocused_OnCommand")
    MIDIEditor_OnCommand = cast(type_of(MIDIEditor_OnCommand))plugin_info.GetFunc("MIDIEditor_OnCommand")
    MIDIEditor_SetSetting_int = cast(type_of(MIDIEditor_SetSetting_int))plugin_info.GetFunc("MIDIEditor_SetSetting_int")
    mkpanstr = cast(type_of(mkpanstr))plugin_info.GetFunc("mkpanstr")
    mkvolpanstr = cast(type_of(mkvolpanstr))plugin_info.GetFunc("mkvolpanstr")
    mkvolstr = cast(type_of(mkvolstr))plugin_info.GetFunc("mkvolstr")
    MoveEditCursor = cast(type_of(MoveEditCursor))plugin_info.GetFunc("MoveEditCursor")
    MoveMediaItemToTrack = cast(type_of(MoveMediaItemToTrack))plugin_info.GetFunc("MoveMediaItemToTrack")
    MuteAllTracks = cast(type_of(MuteAllTracks))plugin_info.GetFunc("MuteAllTracks")
    my_getViewport = cast(type_of(my_getViewport))plugin_info.GetFunc("my_getViewport")
    NamedCommandLookup = cast(type_of(NamedCommandLookup))plugin_info.GetFunc("NamedCommandLookup")
    OnPauseButton = cast(type_of(OnPauseButton))plugin_info.GetFunc("OnPauseButton")
    OnPauseButtonEx = cast(type_of(OnPauseButtonEx))plugin_info.GetFunc("OnPauseButtonEx")
    OnPlayButton = cast(type_of(OnPlayButton))plugin_info.GetFunc("OnPlayButton")
    OnPlayButtonEx = cast(type_of(OnPlayButtonEx))plugin_info.GetFunc("OnPlayButtonEx")
    OnStopButton = cast(type_of(OnStopButton))plugin_info.GetFunc("OnStopButton")
    OnStopButtonEx = cast(type_of(OnStopButtonEx))plugin_info.GetFunc("OnStopButtonEx")
    OpenColorThemeFile = cast(type_of(OpenColorThemeFile))plugin_info.GetFunc("OpenColorThemeFile")
    OpenMediaExplorer = cast(type_of(OpenMediaExplorer))plugin_info.GetFunc("OpenMediaExplorer")
    OscLocalMessageToHost = cast(type_of(OscLocalMessageToHost))plugin_info.GetFunc("OscLocalMessageToHost")
    parse_timestr = cast(type_of(parse_timestr))plugin_info.GetFunc("parse_timestr")
    parse_timestr_len = cast(type_of(parse_timestr_len))plugin_info.GetFunc("parse_timestr_len")
    parse_timestr_pos = cast(type_of(parse_timestr_pos))plugin_info.GetFunc("parse_timestr_pos")
    parsepanstr = cast(type_of(parsepanstr))plugin_info.GetFunc("parsepanstr")
    PCM_Sink_Create = cast(type_of(PCM_Sink_Create))plugin_info.GetFunc("PCM_Sink_Create")
    PCM_Sink_CreateEx = cast(type_of(PCM_Sink_CreateEx))plugin_info.GetFunc("PCM_Sink_CreateEx")
    PCM_Sink_CreateMIDIFile = cast(type_of(PCM_Sink_CreateMIDIFile))plugin_info.GetFunc("PCM_Sink_CreateMIDIFile")
    PCM_Sink_CreateMIDIFileEx = cast(type_of(PCM_Sink_CreateMIDIFileEx))plugin_info.GetFunc("PCM_Sink_CreateMIDIFileEx")
    PCM_Sink_Enum = cast(type_of(PCM_Sink_Enum))plugin_info.GetFunc("PCM_Sink_Enum")
    PCM_Sink_GetExtension = cast(type_of(PCM_Sink_GetExtension))plugin_info.GetFunc("PCM_Sink_GetExtension")
    PCM_Sink_ShowConfig = cast(type_of(PCM_Sink_ShowConfig))plugin_info.GetFunc("PCM_Sink_ShowConfig")
    PCM_Source_CreateFromFile = cast(type_of(PCM_Source_CreateFromFile))plugin_info.GetFunc("PCM_Source_CreateFromFile")
    PCM_Source_CreateFromFileEx = cast(type_of(PCM_Source_CreateFromFileEx))plugin_info.GetFunc("PCM_Source_CreateFromFileEx")
    PCM_Source_CreateFromSimple = cast(type_of(PCM_Source_CreateFromSimple))plugin_info.GetFunc("PCM_Source_CreateFromSimple")
    PCM_Source_CreateFromType = cast(type_of(PCM_Source_CreateFromType))plugin_info.GetFunc("PCM_Source_CreateFromType")
    PCM_Source_Destroy = cast(type_of(PCM_Source_Destroy))plugin_info.GetFunc("PCM_Source_Destroy")
    PCM_Source_GetPeaks = cast(type_of(PCM_Source_GetPeaks))plugin_info.GetFunc("PCM_Source_GetPeaks")
    PCM_Source_GetSectionInfo = cast(type_of(PCM_Source_GetSectionInfo))plugin_info.GetFunc("PCM_Source_GetSectionInfo")
    PeakBuild_Create = cast(type_of(PeakBuild_Create))plugin_info.GetFunc("PeakBuild_Create")
    PeakBuild_CreateEx = cast(type_of(PeakBuild_CreateEx))plugin_info.GetFunc("PeakBuild_CreateEx")
    PeakGet_Create = cast(type_of(PeakGet_Create))plugin_info.GetFunc("PeakGet_Create")
    PitchShiftSubModeMenu = cast(type_of(PitchShiftSubModeMenu))plugin_info.GetFunc("PitchShiftSubModeMenu")
    PlayPreview = cast(type_of(PlayPreview))plugin_info.GetFunc("PlayPreview")
    PlayPreviewEx = cast(type_of(PlayPreviewEx))plugin_info.GetFunc("PlayPreviewEx")
    PlayTrackPreview = cast(type_of(PlayTrackPreview))plugin_info.GetFunc("PlayTrackPreview")
    PlayTrackPreview2 = cast(type_of(PlayTrackPreview2))plugin_info.GetFunc("PlayTrackPreview2")
    PlayTrackPreview2Ex = cast(type_of(PlayTrackPreview2Ex))plugin_info.GetFunc("PlayTrackPreview2Ex")
    plugin_getapi = cast(type_of(plugin_getapi))plugin_info.GetFunc("plugin_getapi")
    plugin_getFilterList = cast(type_of(plugin_getFilterList))plugin_info.GetFunc("plugin_getFilterList")
    plugin_getImportableProjectFilterList = cast(type_of(plugin_getImportableProjectFilterList))plugin_info.GetFunc("plugin_getImportableProjectFilterList")
    plugin_register = cast(type_of(plugin_register))plugin_info.GetFunc("plugin_register")
    PluginWantsAlwaysRunFx = cast(type_of(PluginWantsAlwaysRunFx))plugin_info.GetFunc("PluginWantsAlwaysRunFx")
    PreventUIRefresh = cast(type_of(PreventUIRefresh))plugin_info.GetFunc("PreventUIRefresh")
    projectconfig_var_addr = cast(type_of(projectconfig_var_addr))plugin_info.GetFunc("projectconfig_var_addr")
    projectconfig_var_getoffs = cast(type_of(projectconfig_var_getoffs))plugin_info.GetFunc("projectconfig_var_getoffs")
    PromptForAction = cast(type_of(PromptForAction))plugin_info.GetFunc("PromptForAction")
    realloc_cmd_ptr = cast(type_of(realloc_cmd_ptr))plugin_info.GetFunc("realloc_cmd_ptr")
    ReaperGetPitchShiftAPI = cast(type_of(ReaperGetPitchShiftAPI))plugin_info.GetFunc("ReaperGetPitchShiftAPI")
    ReaScriptError = cast(type_of(ReaScriptError))plugin_info.GetFunc("ReaScriptError")
    RecursiveCreateDirectory = cast(type_of(RecursiveCreateDirectory))plugin_info.GetFunc("RecursiveCreateDirectory")
    reduce_open_files = cast(type_of(reduce_open_files))plugin_info.GetFunc("reduce_open_files")
    RefreshToolbar = cast(type_of(RefreshToolbar))plugin_info.GetFunc("RefreshToolbar")
    RefreshToolbar2 = cast(type_of(RefreshToolbar2))plugin_info.GetFunc("RefreshToolbar2")
    relative_fn = cast(type_of(relative_fn))plugin_info.GetFunc("relative_fn")
    RemoveTrackSend = cast(type_of(RemoveTrackSend))plugin_info.GetFunc("RemoveTrackSend")
    RenderFileSection = cast(type_of(RenderFileSection))plugin_info.GetFunc("RenderFileSection")
    ReorderSelectedTracks = cast(type_of(ReorderSelectedTracks))plugin_info.GetFunc("ReorderSelectedTracks")
    Resample_EnumModes = cast(type_of(Resample_EnumModes))plugin_info.GetFunc("Resample_EnumModes")
    Resampler_Create = cast(type_of(Resampler_Create))plugin_info.GetFunc("Resampler_Create")
    resolve_fn = cast(type_of(resolve_fn))plugin_info.GetFunc("resolve_fn")
    resolve_fn2 = cast(type_of(resolve_fn2))plugin_info.GetFunc("resolve_fn2")
    ReverseNamedCommandLookup = cast(type_of(ReverseNamedCommandLookup))plugin_info.GetFunc("ReverseNamedCommandLookup")
    ScaleFromEnvelopeMode = cast(type_of(ScaleFromEnvelopeMode))plugin_info.GetFunc("ScaleFromEnvelopeMode")
    ScaleToEnvelopeMode = cast(type_of(ScaleToEnvelopeMode))plugin_info.GetFunc("ScaleToEnvelopeMode")
    screenset_register = cast(type_of(screenset_register))plugin_info.GetFunc("screenset_register")
    screenset_registerNew = cast(type_of(screenset_registerNew))plugin_info.GetFunc("screenset_registerNew")
    screenset_unregister = cast(type_of(screenset_unregister))plugin_info.GetFunc("screenset_unregister")
    screenset_unregisterByParam = cast(type_of(screenset_unregisterByParam))plugin_info.GetFunc("screenset_unregisterByParam")
    screenset_updateLastFocus = cast(type_of(screenset_updateLastFocus))plugin_info.GetFunc("screenset_updateLastFocus")
    SectionFromUniqueID = cast(type_of(SectionFromUniqueID))plugin_info.GetFunc("SectionFromUniqueID")
    SelectAllMediaItems = cast(type_of(SelectAllMediaItems))plugin_info.GetFunc("SelectAllMediaItems")
    SelectProjectInstance = cast(type_of(SelectProjectInstance))plugin_info.GetFunc("SelectProjectInstance")
    SendLocalOscMessage = cast(type_of(SendLocalOscMessage))plugin_info.GetFunc("SendLocalOscMessage")
    SetActiveTake = cast(type_of(SetActiveTake))plugin_info.GetFunc("SetActiveTake")
    SetAutomationMode = cast(type_of(SetAutomationMode))plugin_info.GetFunc("SetAutomationMode")
    SetCurrentBPM = cast(type_of(SetCurrentBPM))plugin_info.GetFunc("SetCurrentBPM")
    SetCursorContext = cast(type_of(SetCursorContext))plugin_info.GetFunc("SetCursorContext")
    SetEditCurPos = cast(type_of(SetEditCurPos))plugin_info.GetFunc("SetEditCurPos")
    SetEditCurPos2 = cast(type_of(SetEditCurPos2))plugin_info.GetFunc("SetEditCurPos2")
    SetEnvelopePoint = cast(type_of(SetEnvelopePoint))plugin_info.GetFunc("SetEnvelopePoint")
    SetEnvelopePointEx = cast(type_of(SetEnvelopePointEx))plugin_info.GetFunc("SetEnvelopePointEx")
    SetEnvelopeStateChunk = cast(type_of(SetEnvelopeStateChunk))plugin_info.GetFunc("SetEnvelopeStateChunk")
    SetExtState = cast(type_of(SetExtState))plugin_info.GetFunc("SetExtState")
    SetGlobalAutomationOverride = cast(type_of(SetGlobalAutomationOverride))plugin_info.GetFunc("SetGlobalAutomationOverride")
    SetItemStateChunk = cast(type_of(SetItemStateChunk))plugin_info.GetFunc("SetItemStateChunk")
    SetMasterTrackVisibility = cast(type_of(SetMasterTrackVisibility))plugin_info.GetFunc("SetMasterTrackVisibility")
    SetMediaItemInfo_Value = cast(type_of(SetMediaItemInfo_Value))plugin_info.GetFunc("SetMediaItemInfo_Value")
    SetMediaItemLength = cast(type_of(SetMediaItemLength))plugin_info.GetFunc("SetMediaItemLength")
    SetMediaItemPosition = cast(type_of(SetMediaItemPosition))plugin_info.GetFunc("SetMediaItemPosition")
    SetMediaItemSelected = cast(type_of(SetMediaItemSelected))plugin_info.GetFunc("SetMediaItemSelected")
    SetMediaItemTake_Source = cast(type_of(SetMediaItemTake_Source))plugin_info.GetFunc("SetMediaItemTake_Source")
    SetMediaItemTakeInfo_Value = cast(type_of(SetMediaItemTakeInfo_Value))plugin_info.GetFunc("SetMediaItemTakeInfo_Value")
    SetMediaTrackInfo_Value = cast(type_of(SetMediaTrackInfo_Value))plugin_info.GetFunc("SetMediaTrackInfo_Value")
    SetMIDIEditorGrid = cast(type_of(SetMIDIEditorGrid))plugin_info.GetFunc("SetMIDIEditorGrid")
    SetMixerScroll = cast(type_of(SetMixerScroll))plugin_info.GetFunc("SetMixerScroll")
    SetMouseModifier = cast(type_of(SetMouseModifier))plugin_info.GetFunc("SetMouseModifier")
    SetOnlyTrackSelected = cast(type_of(SetOnlyTrackSelected))plugin_info.GetFunc("SetOnlyTrackSelected")
    SetProjectGrid = cast(type_of(SetProjectGrid))plugin_info.GetFunc("SetProjectGrid")
    SetProjectMarker = cast(type_of(SetProjectMarker))plugin_info.GetFunc("SetProjectMarker")
    SetProjectMarker2 = cast(type_of(SetProjectMarker2))plugin_info.GetFunc("SetProjectMarker2")
    SetProjectMarker3 = cast(type_of(SetProjectMarker3))plugin_info.GetFunc("SetProjectMarker3")
    SetProjectMarker4 = cast(type_of(SetProjectMarker4))plugin_info.GetFunc("SetProjectMarker4")
    SetProjectMarkerByIndex = cast(type_of(SetProjectMarkerByIndex))plugin_info.GetFunc("SetProjectMarkerByIndex")
    SetProjectMarkerByIndex2 = cast(type_of(SetProjectMarkerByIndex2))plugin_info.GetFunc("SetProjectMarkerByIndex2")
    SetProjExtState = cast(type_of(SetProjExtState))plugin_info.GetFunc("SetProjExtState")
    SetRegionRenderMatrix = cast(type_of(SetRegionRenderMatrix))plugin_info.GetFunc("SetRegionRenderMatrix")
    SetRenderLastError = cast(type_of(SetRenderLastError))plugin_info.GetFunc("SetRenderLastError")
    SetTakeMarker = cast(type_of(SetTakeMarker))plugin_info.GetFunc("SetTakeMarker")
    SetTakeStretchMarker = cast(type_of(SetTakeStretchMarker))plugin_info.GetFunc("SetTakeStretchMarker")
    SetTakeStretchMarkerSlope = cast(type_of(SetTakeStretchMarkerSlope))plugin_info.GetFunc("SetTakeStretchMarkerSlope")
    SetTempoTimeSigMarker = cast(type_of(SetTempoTimeSigMarker))plugin_info.GetFunc("SetTempoTimeSigMarker")
    SetThemeColor = cast(type_of(SetThemeColor))plugin_info.GetFunc("SetThemeColor")
    SetToggleCommandState = cast(type_of(SetToggleCommandState))plugin_info.GetFunc("SetToggleCommandState")
    SetTrackAutomationMode = cast(type_of(SetTrackAutomationMode))plugin_info.GetFunc("SetTrackAutomationMode")
    SetTrackColor = cast(type_of(SetTrackColor))plugin_info.GetFunc("SetTrackColor")
    SetTrackMIDILyrics = cast(type_of(SetTrackMIDILyrics))plugin_info.GetFunc("SetTrackMIDILyrics")
    SetTrackMIDINoteName = cast(type_of(SetTrackMIDINoteName))plugin_info.GetFunc("SetTrackMIDINoteName")
    SetTrackMIDINoteNameEx = cast(type_of(SetTrackMIDINoteNameEx))plugin_info.GetFunc("SetTrackMIDINoteNameEx")
    SetTrackSelected = cast(type_of(SetTrackSelected))plugin_info.GetFunc("SetTrackSelected")
    SetTrackSendInfo_Value = cast(type_of(SetTrackSendInfo_Value))plugin_info.GetFunc("SetTrackSendInfo_Value")
    SetTrackSendUIPan = cast(type_of(SetTrackSendUIPan))plugin_info.GetFunc("SetTrackSendUIPan")
    SetTrackSendUIVol = cast(type_of(SetTrackSendUIVol))plugin_info.GetFunc("SetTrackSendUIVol")
    SetTrackStateChunk = cast(type_of(SetTrackStateChunk))plugin_info.GetFunc("SetTrackStateChunk")
    ShowActionList = cast(type_of(ShowActionList))plugin_info.GetFunc("ShowActionList")
    ShowConsoleMsg = cast(type_of(ShowConsoleMsg))plugin_info.GetFunc("ShowConsoleMsg")
    ShowMessageBox = cast(type_of(ShowMessageBox))plugin_info.GetFunc("ShowMessageBox")
    ShowPopupMenu = cast(type_of(ShowPopupMenu))plugin_info.GetFunc("ShowPopupMenu")
    SLIDER2DB = cast(type_of(SLIDER2DB))plugin_info.GetFunc("SLIDER2DB")
    SnapToGrid = cast(type_of(SnapToGrid))plugin_info.GetFunc("SnapToGrid")
    SoloAllTracks = cast(type_of(SoloAllTracks))plugin_info.GetFunc("SoloAllTracks")
    Splash_GetWnd = cast(type_of(Splash_GetWnd))plugin_info.GetFunc("Splash_GetWnd")
    SplitMediaItem = cast(type_of(SplitMediaItem))plugin_info.GetFunc("SplitMediaItem")
    StopPreview = cast(type_of(StopPreview))plugin_info.GetFunc("StopPreview")
    StopTrackPreview = cast(type_of(StopTrackPreview))plugin_info.GetFunc("StopTrackPreview")
    StopTrackPreview2 = cast(type_of(StopTrackPreview2))plugin_info.GetFunc("StopTrackPreview2")
    stringToGuid = cast(type_of(stringToGuid))plugin_info.GetFunc("stringToGuid")
    StuffMIDIMessage = cast(type_of(StuffMIDIMessage))plugin_info.GetFunc("StuffMIDIMessage")
    TakeFX_AddByName = cast(type_of(TakeFX_AddByName))plugin_info.GetFunc("TakeFX_AddByName")
    TakeFX_CopyToTake = cast(type_of(TakeFX_CopyToTake))plugin_info.GetFunc("TakeFX_CopyToTake")
    TakeFX_CopyToTrack = cast(type_of(TakeFX_CopyToTrack))plugin_info.GetFunc("TakeFX_CopyToTrack")
    TakeFX_Delete = cast(type_of(TakeFX_Delete))plugin_info.GetFunc("TakeFX_Delete")
    TakeFX_EndParamEdit = cast(type_of(TakeFX_EndParamEdit))plugin_info.GetFunc("TakeFX_EndParamEdit")
    TakeFX_FormatParamValue = cast(type_of(TakeFX_FormatParamValue))plugin_info.GetFunc("TakeFX_FormatParamValue")
    TakeFX_FormatParamValueNormalized = cast(type_of(TakeFX_FormatParamValueNormalized))plugin_info.GetFunc("TakeFX_FormatParamValueNormalized")
    TakeFX_GetChainVisible = cast(type_of(TakeFX_GetChainVisible))plugin_info.GetFunc("TakeFX_GetChainVisible")
    TakeFX_GetCount = cast(type_of(TakeFX_GetCount))plugin_info.GetFunc("TakeFX_GetCount")
    TakeFX_GetEnabled = cast(type_of(TakeFX_GetEnabled))plugin_info.GetFunc("TakeFX_GetEnabled")
    TakeFX_GetEnvelope = cast(type_of(TakeFX_GetEnvelope))plugin_info.GetFunc("TakeFX_GetEnvelope")
    TakeFX_GetFloatingWindow = cast(type_of(TakeFX_GetFloatingWindow))plugin_info.GetFunc("TakeFX_GetFloatingWindow")
    TakeFX_GetFormattedParamValue = cast(type_of(TakeFX_GetFormattedParamValue))plugin_info.GetFunc("TakeFX_GetFormattedParamValue")
    TakeFX_GetFXGUID = cast(type_of(TakeFX_GetFXGUID))plugin_info.GetFunc("TakeFX_GetFXGUID")
    TakeFX_GetFXName = cast(type_of(TakeFX_GetFXName))plugin_info.GetFunc("TakeFX_GetFXName")
    TakeFX_GetIOSize = cast(type_of(TakeFX_GetIOSize))plugin_info.GetFunc("TakeFX_GetIOSize")
    TakeFX_GetNamedConfigParm = cast(type_of(TakeFX_GetNamedConfigParm))plugin_info.GetFunc("TakeFX_GetNamedConfigParm")
    TakeFX_GetNumParams = cast(type_of(TakeFX_GetNumParams))plugin_info.GetFunc("TakeFX_GetNumParams")
    TakeFX_GetOffline = cast(type_of(TakeFX_GetOffline))plugin_info.GetFunc("TakeFX_GetOffline")
    TakeFX_GetOpen = cast(type_of(TakeFX_GetOpen))plugin_info.GetFunc("TakeFX_GetOpen")
    TakeFX_GetParam = cast(type_of(TakeFX_GetParam))plugin_info.GetFunc("TakeFX_GetParam")
    TakeFX_GetParameterStepSizes = cast(type_of(TakeFX_GetParameterStepSizes))plugin_info.GetFunc("TakeFX_GetParameterStepSizes")
    TakeFX_GetParamEx = cast(type_of(TakeFX_GetParamEx))plugin_info.GetFunc("TakeFX_GetParamEx")
    TakeFX_GetParamName = cast(type_of(TakeFX_GetParamName))plugin_info.GetFunc("TakeFX_GetParamName")
    TakeFX_GetParamNormalized = cast(type_of(TakeFX_GetParamNormalized))plugin_info.GetFunc("TakeFX_GetParamNormalized")
    TakeFX_GetPinMappings = cast(type_of(TakeFX_GetPinMappings))plugin_info.GetFunc("TakeFX_GetPinMappings")
    TakeFX_GetPreset = cast(type_of(TakeFX_GetPreset))plugin_info.GetFunc("TakeFX_GetPreset")
    TakeFX_GetPresetIndex = cast(type_of(TakeFX_GetPresetIndex))plugin_info.GetFunc("TakeFX_GetPresetIndex")
    TakeFX_GetUserPresetFilename = cast(type_of(TakeFX_GetUserPresetFilename))plugin_info.GetFunc("TakeFX_GetUserPresetFilename")
    TakeFX_NavigatePresets = cast(type_of(TakeFX_NavigatePresets))plugin_info.GetFunc("TakeFX_NavigatePresets")
    TakeFX_SetEnabled = cast(type_of(TakeFX_SetEnabled))plugin_info.GetFunc("TakeFX_SetEnabled")
    TakeFX_SetNamedConfigParm = cast(type_of(TakeFX_SetNamedConfigParm))plugin_info.GetFunc("TakeFX_SetNamedConfigParm")
    TakeFX_SetOffline = cast(type_of(TakeFX_SetOffline))plugin_info.GetFunc("TakeFX_SetOffline")
    TakeFX_SetOpen = cast(type_of(TakeFX_SetOpen))plugin_info.GetFunc("TakeFX_SetOpen")
    TakeFX_SetParam = cast(type_of(TakeFX_SetParam))plugin_info.GetFunc("TakeFX_SetParam")
    TakeFX_SetParamNormalized = cast(type_of(TakeFX_SetParamNormalized))plugin_info.GetFunc("TakeFX_SetParamNormalized")
    TakeFX_SetPinMappings = cast(type_of(TakeFX_SetPinMappings))plugin_info.GetFunc("TakeFX_SetPinMappings")
    TakeFX_SetPreset = cast(type_of(TakeFX_SetPreset))plugin_info.GetFunc("TakeFX_SetPreset")
    TakeFX_SetPresetByIndex = cast(type_of(TakeFX_SetPresetByIndex))plugin_info.GetFunc("TakeFX_SetPresetByIndex")
    TakeFX_Show = cast(type_of(TakeFX_Show))plugin_info.GetFunc("TakeFX_Show")
    TakeIsMIDI = cast(type_of(TakeIsMIDI))plugin_info.GetFunc("TakeIsMIDI")
    ThemeLayout_GetLayout = cast(type_of(ThemeLayout_GetLayout))plugin_info.GetFunc("ThemeLayout_GetLayout")
    ThemeLayout_GetParameter = cast(type_of(ThemeLayout_GetParameter))plugin_info.GetFunc("ThemeLayout_GetParameter")
    ThemeLayout_RefreshAll = cast(type_of(ThemeLayout_RefreshAll))plugin_info.GetFunc("ThemeLayout_RefreshAll")
    ThemeLayout_SetLayout = cast(type_of(ThemeLayout_SetLayout))plugin_info.GetFunc("ThemeLayout_SetLayout")
    ThemeLayout_SetParameter = cast(type_of(ThemeLayout_SetParameter))plugin_info.GetFunc("ThemeLayout_SetParameter")
    time_precise = cast(type_of(time_precise))plugin_info.GetFunc("time_precise")
    TimeMap2_beatsToTime = cast(type_of(TimeMap2_beatsToTime))plugin_info.GetFunc("TimeMap2_beatsToTime")
    TimeMap2_GetDividedBpmAtTime = cast(type_of(TimeMap2_GetDividedBpmAtTime))plugin_info.GetFunc("TimeMap2_GetDividedBpmAtTime")
    TimeMap2_GetNextChangeTime = cast(type_of(TimeMap2_GetNextChangeTime))plugin_info.GetFunc("TimeMap2_GetNextChangeTime")
    TimeMap2_QNToTime = cast(type_of(TimeMap2_QNToTime))plugin_info.GetFunc("TimeMap2_QNToTime")
    TimeMap2_timeToBeats = cast(type_of(TimeMap2_timeToBeats))plugin_info.GetFunc("TimeMap2_timeToBeats")
    TimeMap2_timeToQN = cast(type_of(TimeMap2_timeToQN))plugin_info.GetFunc("TimeMap2_timeToQN")
    TimeMap_curFrameRate = cast(type_of(TimeMap_curFrameRate))plugin_info.GetFunc("TimeMap_curFrameRate")
    TimeMap_GetDividedBpmAtTime = cast(type_of(TimeMap_GetDividedBpmAtTime))plugin_info.GetFunc("TimeMap_GetDividedBpmAtTime")
    TimeMap_GetMeasureInfo = cast(type_of(TimeMap_GetMeasureInfo))plugin_info.GetFunc("TimeMap_GetMeasureInfo")
    TimeMap_GetMetronomePattern = cast(type_of(TimeMap_GetMetronomePattern))plugin_info.GetFunc("TimeMap_GetMetronomePattern")
    TimeMap_GetTimeSigAtTime = cast(type_of(TimeMap_GetTimeSigAtTime))plugin_info.GetFunc("TimeMap_GetTimeSigAtTime")
    TimeMap_QNToMeasures = cast(type_of(TimeMap_QNToMeasures))plugin_info.GetFunc("TimeMap_QNToMeasures")
    TimeMap_QNToTime = cast(type_of(TimeMap_QNToTime))plugin_info.GetFunc("TimeMap_QNToTime")
    TimeMap_QNToTime_abs = cast(type_of(TimeMap_QNToTime_abs))plugin_info.GetFunc("TimeMap_QNToTime_abs")
    TimeMap_timeToQN = cast(type_of(TimeMap_timeToQN))plugin_info.GetFunc("TimeMap_timeToQN")
    TimeMap_timeToQN_abs = cast(type_of(TimeMap_timeToQN_abs))plugin_info.GetFunc("TimeMap_timeToQN_abs")
    ToggleTrackSendUIMute = cast(type_of(ToggleTrackSendUIMute))plugin_info.GetFunc("ToggleTrackSendUIMute")
    Track_GetPeakHoldDB = cast(type_of(Track_GetPeakHoldDB))plugin_info.GetFunc("Track_GetPeakHoldDB")
    Track_GetPeakInfo = cast(type_of(Track_GetPeakInfo))plugin_info.GetFunc("Track_GetPeakInfo")
    TrackCtl_SetToolTip = cast(type_of(TrackCtl_SetToolTip))plugin_info.GetFunc("TrackCtl_SetToolTip")
    TrackFX_AddByName = cast(type_of(TrackFX_AddByName))plugin_info.GetFunc("TrackFX_AddByName")
    TrackFX_CopyToTake = cast(type_of(TrackFX_CopyToTake))plugin_info.GetFunc("TrackFX_CopyToTake")
    TrackFX_CopyToTrack = cast(type_of(TrackFX_CopyToTrack))plugin_info.GetFunc("TrackFX_CopyToTrack")
    TrackFX_Delete = cast(type_of(TrackFX_Delete))plugin_info.GetFunc("TrackFX_Delete")
    TrackFX_EndParamEdit = cast(type_of(TrackFX_EndParamEdit))plugin_info.GetFunc("TrackFX_EndParamEdit")
    TrackFX_FormatParamValue = cast(type_of(TrackFX_FormatParamValue))plugin_info.GetFunc("TrackFX_FormatParamValue")
    TrackFX_FormatParamValueNormalized = cast(type_of(TrackFX_FormatParamValueNormalized))plugin_info.GetFunc("TrackFX_FormatParamValueNormalized")
    TrackFX_GetByName = cast(type_of(TrackFX_GetByName))plugin_info.GetFunc("TrackFX_GetByName")
    TrackFX_GetChainVisible = cast(type_of(TrackFX_GetChainVisible))plugin_info.GetFunc("TrackFX_GetChainVisible")
    TrackFX_GetCount = cast(type_of(TrackFX_GetCount))plugin_info.GetFunc("TrackFX_GetCount")
    TrackFX_GetEnabled = cast(type_of(TrackFX_GetEnabled))plugin_info.GetFunc("TrackFX_GetEnabled")
    TrackFX_GetEQ = cast(type_of(TrackFX_GetEQ))plugin_info.GetFunc("TrackFX_GetEQ")
    TrackFX_GetEQBandEnabled = cast(type_of(TrackFX_GetEQBandEnabled))plugin_info.GetFunc("TrackFX_GetEQBandEnabled")
    TrackFX_GetEQParam = cast(type_of(TrackFX_GetEQParam))plugin_info.GetFunc("TrackFX_GetEQParam")
    TrackFX_GetFloatingWindow = cast(type_of(TrackFX_GetFloatingWindow))plugin_info.GetFunc("TrackFX_GetFloatingWindow")
    TrackFX_GetFormattedParamValue = cast(type_of(TrackFX_GetFormattedParamValue))plugin_info.GetFunc("TrackFX_GetFormattedParamValue")
    TrackFX_GetFXGUID = cast(type_of(TrackFX_GetFXGUID))plugin_info.GetFunc("TrackFX_GetFXGUID")
    TrackFX_GetFXName = cast(type_of(TrackFX_GetFXName))plugin_info.GetFunc("TrackFX_GetFXName")
    TrackFX_GetInstrument = cast(type_of(TrackFX_GetInstrument))plugin_info.GetFunc("TrackFX_GetInstrument")
    TrackFX_GetIOSize = cast(type_of(TrackFX_GetIOSize))plugin_info.GetFunc("TrackFX_GetIOSize")
    TrackFX_GetNamedConfigParm = cast(type_of(TrackFX_GetNamedConfigParm))plugin_info.GetFunc("TrackFX_GetNamedConfigParm")
    TrackFX_GetNumParams = cast(type_of(TrackFX_GetNumParams))plugin_info.GetFunc("TrackFX_GetNumParams")
    TrackFX_GetOffline = cast(type_of(TrackFX_GetOffline))plugin_info.GetFunc("TrackFX_GetOffline")
    TrackFX_GetOpen = cast(type_of(TrackFX_GetOpen))plugin_info.GetFunc("TrackFX_GetOpen")
    TrackFX_GetParam = cast(type_of(TrackFX_GetParam))plugin_info.GetFunc("TrackFX_GetParam")
    TrackFX_GetParameterStepSizes = cast(type_of(TrackFX_GetParameterStepSizes))plugin_info.GetFunc("TrackFX_GetParameterStepSizes")
    TrackFX_GetParamEx = cast(type_of(TrackFX_GetParamEx))plugin_info.GetFunc("TrackFX_GetParamEx")
    TrackFX_GetParamName = cast(type_of(TrackFX_GetParamName))plugin_info.GetFunc("TrackFX_GetParamName")
    TrackFX_GetParamNormalized = cast(type_of(TrackFX_GetParamNormalized))plugin_info.GetFunc("TrackFX_GetParamNormalized")
    TrackFX_GetPinMappings = cast(type_of(TrackFX_GetPinMappings))plugin_info.GetFunc("TrackFX_GetPinMappings")
    TrackFX_GetPreset = cast(type_of(TrackFX_GetPreset))plugin_info.GetFunc("TrackFX_GetPreset")
    TrackFX_GetPresetIndex = cast(type_of(TrackFX_GetPresetIndex))plugin_info.GetFunc("TrackFX_GetPresetIndex")
    TrackFX_GetRecChainVisible = cast(type_of(TrackFX_GetRecChainVisible))plugin_info.GetFunc("TrackFX_GetRecChainVisible")
    TrackFX_GetRecCount = cast(type_of(TrackFX_GetRecCount))plugin_info.GetFunc("TrackFX_GetRecCount")
    TrackFX_GetUserPresetFilename = cast(type_of(TrackFX_GetUserPresetFilename))plugin_info.GetFunc("TrackFX_GetUserPresetFilename")
    TrackFX_NavigatePresets = cast(type_of(TrackFX_NavigatePresets))plugin_info.GetFunc("TrackFX_NavigatePresets")
    TrackFX_SetEnabled = cast(type_of(TrackFX_SetEnabled))plugin_info.GetFunc("TrackFX_SetEnabled")
    TrackFX_SetEQBandEnabled = cast(type_of(TrackFX_SetEQBandEnabled))plugin_info.GetFunc("TrackFX_SetEQBandEnabled")
    TrackFX_SetEQParam = cast(type_of(TrackFX_SetEQParam))plugin_info.GetFunc("TrackFX_SetEQParam")
    TrackFX_SetNamedConfigParm = cast(type_of(TrackFX_SetNamedConfigParm))plugin_info.GetFunc("TrackFX_SetNamedConfigParm")
    TrackFX_SetOffline = cast(type_of(TrackFX_SetOffline))plugin_info.GetFunc("TrackFX_SetOffline")
    TrackFX_SetOpen = cast(type_of(TrackFX_SetOpen))plugin_info.GetFunc("TrackFX_SetOpen")
    TrackFX_SetParam = cast(type_of(TrackFX_SetParam))plugin_info.GetFunc("TrackFX_SetParam")
    TrackFX_SetParamNormalized = cast(type_of(TrackFX_SetParamNormalized))plugin_info.GetFunc("TrackFX_SetParamNormalized")
    TrackFX_SetPinMappings = cast(type_of(TrackFX_SetPinMappings))plugin_info.GetFunc("TrackFX_SetPinMappings")
    TrackFX_SetPreset = cast(type_of(TrackFX_SetPreset))plugin_info.GetFunc("TrackFX_SetPreset")
    TrackFX_SetPresetByIndex = cast(type_of(TrackFX_SetPresetByIndex))plugin_info.GetFunc("TrackFX_SetPresetByIndex")
    TrackFX_Show = cast(type_of(TrackFX_Show))plugin_info.GetFunc("TrackFX_Show")
    TrackList_AdjustWindows = cast(type_of(TrackList_AdjustWindows))plugin_info.GetFunc("TrackList_AdjustWindows")
    TrackList_UpdateAllExternalSurfaces = cast(type_of(TrackList_UpdateAllExternalSurfaces))plugin_info.GetFunc("TrackList_UpdateAllExternalSurfaces")
    Undo_BeginBlock = cast(type_of(Undo_BeginBlock))plugin_info.GetFunc("Undo_BeginBlock")
    Undo_BeginBlock2 = cast(type_of(Undo_BeginBlock2))plugin_info.GetFunc("Undo_BeginBlock2")
    Undo_CanRedo2 = cast(type_of(Undo_CanRedo2))plugin_info.GetFunc("Undo_CanRedo2")
    Undo_CanUndo2 = cast(type_of(Undo_CanUndo2))plugin_info.GetFunc("Undo_CanUndo2")
    Undo_DoRedo2 = cast(type_of(Undo_DoRedo2))plugin_info.GetFunc("Undo_DoRedo2")
    Undo_DoUndo2 = cast(type_of(Undo_DoUndo2))plugin_info.GetFunc("Undo_DoUndo2")
    Undo_EndBlock = cast(type_of(Undo_EndBlock))plugin_info.GetFunc("Undo_EndBlock")
    Undo_EndBlock2 = cast(type_of(Undo_EndBlock2))plugin_info.GetFunc("Undo_EndBlock2")
    Undo_OnStateChange = cast(type_of(Undo_OnStateChange))plugin_info.GetFunc("Undo_OnStateChange")
    Undo_OnStateChange2 = cast(type_of(Undo_OnStateChange2))plugin_info.GetFunc("Undo_OnStateChange2")
    Undo_OnStateChange_Item = cast(type_of(Undo_OnStateChange_Item))plugin_info.GetFunc("Undo_OnStateChange_Item")
    Undo_OnStateChangeEx = cast(type_of(Undo_OnStateChangeEx))plugin_info.GetFunc("Undo_OnStateChangeEx")
    Undo_OnStateChangeEx2 = cast(type_of(Undo_OnStateChangeEx2))plugin_info.GetFunc("Undo_OnStateChangeEx2")
    update_disk_counters = cast(type_of(update_disk_counters))plugin_info.GetFunc("update_disk_counters")
    UpdateArrange = cast(type_of(UpdateArrange))plugin_info.GetFunc("UpdateArrange")
    UpdateItemInProject = cast(type_of(UpdateItemInProject))plugin_info.GetFunc("UpdateItemInProject")
    UpdateTimeline = cast(type_of(UpdateTimeline))plugin_info.GetFunc("UpdateTimeline")
    ValidatePtr = cast(type_of(ValidatePtr))plugin_info.GetFunc("ValidatePtr")
    ValidatePtr2 = cast(type_of(ValidatePtr2))plugin_info.GetFunc("ValidatePtr2")
    ViewPrefs = cast(type_of(ViewPrefs))plugin_info.GetFunc("ViewPrefs")
    WDL_VirtualWnd_ScaledBlitBG = cast(type_of(WDL_VirtualWnd_ScaledBlitBG))plugin_info.GetFunc("WDL_VirtualWnd_ScaledBlitBG")
}

//==========================================================================
// Reaper API Function Pointers
//==========================================================================

AddCustomizableMenu: proc "c" (menuidstr: cstring, menuname: cstring, kbdsecname: cstring, addtomainmenu: bool) -> bool
AddExtensionsMainMenu: proc "c" () -> bool
AddMediaItemToTrack: proc "c" (tr: ^MediaTrack) -> ^MediaItem
AddProjectMarker: proc "c" (proj: ^ReaProject, isrgn: bool, pos: f64, rgnend: f64, name: cstring, wantidx: c.int) -> c.int
AddProjectMarker2: proc "c" (proj: ^ReaProject, isrgn: bool, pos: f64, rgnend: f64, name: cstring, wantidx: c.int, color: c.int) -> c.int
AddRemoveReaScript: proc "c" (add: bool, sectionID: c.int, scriptfn: cstring, commit: bool) -> c.int
AddTakeToMediaItem: proc "c" (item: ^MediaItem) -> ^MediaItem_Take
AddTempoTimeSigMarker: proc "c" (proj: ^ReaProject, timepos: f64, bpm: f64, timesig_num: c.int, timesig_denom: c.int, lineartempochange: bool) -> bool
adjustZoom: proc "c" (amt: f64, forceset: c.int, doupd: bool, centermode: c.int)
AnyTrackSolo: proc "c" (proj: ^ReaProject) -> bool
APIExists: proc "c" (function_name: cstring) -> bool
APITest: proc "c" ()
ApplyNudge: proc "c" (project: ^ReaProject, nudgeflag: c.int, nudgewhat: c.int, nudgeunits: c.int, value: f64, reverse: bool, copies: c.int) -> bool
ArmCommand: proc "c" (cmd: c.int, sectionname: cstring)
Audio_Init: proc "c" ()
Audio_IsPreBuffer: proc "c" () -> c.int
Audio_IsRunning: proc "c" () -> c.int
Audio_Quit: proc "c" ()
Audio_RegHardwareHook: proc "c" (isAdd: bool, reg: ^audio_hook_register_t) -> c.int
AudioAccessorStateChanged: proc "c" (accessor: ^AudioAccessor) -> bool
AudioAccessorUpdate: proc "c" (accessor: ^AudioAccessor)
AudioAccessorValidateState: proc "c" (accessor: ^AudioAccessor) -> bool
BypassFxAllTracks: proc "c" (bypass: c.int)
CalculatePeaks: proc "c" (srcBlock: ^PCM_source_transfer_t, pksBlock: ^PCM_source_peaktransfer_t) -> c.int
CalculatePeaksFloatSrcPtr: proc "c" (srcBlock: ^PCM_source_transfer_t, pksBlock: ^PCM_source_peaktransfer_t) -> c.int
ClearAllRecArmed: proc "c" ()
ClearConsole: proc "c" ()
ClearPeakCache: proc "c" ()
ColorFromNative: proc "c" (col: c.int, rOut: ^c.int, gOut: ^c.int, bOut: ^c.int)
ColorToNative: proc "c" (r: c.int, g: c.int, b: c.int) -> c.int
CountActionShortcuts: proc "c" (section: ^KbdSectionInfo, cmdID: c.int) -> c.int
CountAutomationItems: proc "c" (env: ^TrackEnvelope) -> c.int
CountEnvelopePoints: proc "c" (envelope: ^TrackEnvelope) -> c.int
CountEnvelopePointsEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int) -> c.int
CountMediaItems: proc "c" (proj: ^ReaProject) -> c.int
CountProjectMarkers: proc "c" (proj: ^ReaProject, num_markersOut: ^c.int, num_regionsOut: ^c.int) -> c.int
CountSelectedMediaItems: proc "c" (proj: ^ReaProject) -> c.int
CountSelectedTracks: proc "c" (proj: ^ReaProject) -> c.int
CountSelectedTracks2: proc "c" (proj: ^ReaProject, wantmaster: bool) -> c.int
CountTakeEnvelopes: proc "c" (take: ^MediaItem_Take) -> c.int
CountTakes: proc "c" (item: ^MediaItem) -> c.int
CountTCPFXParms: proc "c" (project: ^ReaProject, track: ^MediaTrack) -> c.int
CountTempoTimeSigMarkers: proc "c" (proj: ^ReaProject) -> c.int
CountTrackEnvelopes: proc "c" (track: ^MediaTrack) -> c.int
CountTrackMediaItems: proc "c" (track: ^MediaTrack) -> c.int
CountTracks: proc "c" (projOptional: ^ReaProject) -> c.int
CreateLocalOscHandler: proc "c" (obj: rawptr, callback: rawptr) -> rawptr
CreateMIDIInput: proc "c" (dev: c.int) -> ^midi_Input
CreateMIDIOutput: proc "c" (dev: c.int, streamMode: bool, msoffset100: ^c.int) -> ^midi_Output
CreateNewMIDIItemInProj: proc "c" (track: ^MediaTrack, starttime: f64, endtime: f64, qnInOptional: ^bool) -> ^MediaItem
CreateTakeAudioAccessor: proc "c" (take: ^MediaItem_Take) -> ^AudioAccessor
CreateTrackAudioAccessor: proc "c" (track: ^MediaTrack) -> ^AudioAccessor
CreateTrackSend: proc "c" (tr: ^MediaTrack, desttrInOptional: ^MediaTrack) -> c.int
CSurf_FlushUndo: proc "c" (force: bool)
CSurf_GetTouchState: proc "c" (trackid: ^MediaTrack, isPan: c.int) -> bool
CSurf_GoEnd: proc "c" ()
CSurf_GoStart: proc "c" ()
CSurf_NumTracks: proc "c" (mcpView: bool) -> c.int
CSurf_OnArrow: proc "c" (whichdir: c.int, wantzoom: bool)
CSurf_OnFwd: proc "c" (seekplay: c.int)
CSurf_OnFXChange: proc "c" (trackid: ^MediaTrack, en: c.int) -> bool
CSurf_OnInputMonitorChange: proc "c" (trackid: ^MediaTrack, monitor: c.int) -> c.int
CSurf_OnInputMonitorChangeEx: proc "c" (trackid: ^MediaTrack, monitor: c.int, allowgang: bool) -> c.int
CSurf_OnMuteChange: proc "c" (trackid: ^MediaTrack, mute: c.int) -> bool
CSurf_OnMuteChangeEx: proc "c" (trackid: ^MediaTrack, mute: c.int, allowgang: bool) -> bool
CSurf_OnOscControlMessage: proc "c" (msg: cstring, arg: ^f32)
CSurf_OnPanChange: proc "c" (trackid: ^MediaTrack, pan: f64, relative: bool) -> f64
CSurf_OnPanChangeEx: proc "c" (trackid: ^MediaTrack, pan: f64, relative: bool, allowGang: bool) -> f64
CSurf_OnPause: proc "c" ()
CSurf_OnPlay: proc "c" ()
CSurf_OnPlayRateChange: proc "c" (playrate: f64)
CSurf_OnRecArmChange: proc "c" (trackid: ^MediaTrack, recarm: c.int) -> bool
CSurf_OnRecArmChangeEx: proc "c" (trackid: ^MediaTrack, recarm: c.int, allowgang: bool) -> bool
CSurf_OnRecord: proc "c" ()
CSurf_OnRecvPanChange: proc "c" (trackid: ^MediaTrack, recv_index: c.int, pan: f64, relative: bool) -> f64
CSurf_OnRecvVolumeChange: proc "c" (trackid: ^MediaTrack, recv_index: c.int, volume: f64, relative: bool) -> f64
CSurf_OnRew: proc "c" (seekplay: c.int)
CSurf_OnRewFwd: proc "c" (seekplay: c.int, dir: c.int)
CSurf_OnScroll: proc "c" (xdir: c.int, ydir: c.int)
CSurf_OnSelectedChange: proc "c" (trackid: ^MediaTrack, selected: c.int) -> bool
CSurf_OnSendPanChange: proc "c" (trackid: ^MediaTrack, send_index: c.int, pan: f64, relative: bool) -> f64
CSurf_OnSendVolumeChange: proc "c" (trackid: ^MediaTrack, send_index: c.int, volume: f64, relative: bool) -> f64
CSurf_OnSoloChange: proc "c" (trackid: ^MediaTrack, solo: c.int) -> bool
CSurf_OnSoloChangeEx: proc "c" (trackid: ^MediaTrack, solo: c.int, allowgang: bool) -> bool
CSurf_OnStop: proc "c" ()
CSurf_OnTempoChange: proc "c" (bpm: f64)
CSurf_OnTrackSelection: proc "c" (trackid: ^MediaTrack)
CSurf_OnVolumeChange: proc "c" (trackid: ^MediaTrack, volume: f64, relative: bool) -> f64
CSurf_OnVolumeChangeEx: proc "c" (trackid: ^MediaTrack, volume: f64, relative: bool, allowGang: bool) -> f64
CSurf_OnWidthChange: proc "c" (trackid: ^MediaTrack, width: f64, relative: bool) -> f64
CSurf_OnWidthChangeEx: proc "c" (trackid: ^MediaTrack, width: f64, relative: bool, allowGang: bool) -> f64
CSurf_OnZoom: proc "c" (xdir: c.int, ydir: c.int)
CSurf_ResetAllCachedVolPanStates: proc "c" ()
CSurf_ScrubAmt: proc "c" (amt: f64)
CSurf_SetAutoMode: proc "c" (mode: c.int, ignoresurf: ^IReaperControlSurface)
CSurf_SetPlayState: proc "c" (play: bool, pause: bool, rec: bool, ignoresurf: ^IReaperControlSurface)
CSurf_SetRepeatState: proc "c" (rep: bool, ignoresurf: ^IReaperControlSurface)
CSurf_SetSurfaceMute: proc "c" (trackid: ^MediaTrack, mute: bool, ignoresurf: ^IReaperControlSurface)
CSurf_SetSurfacePan: proc "c" (trackid: ^MediaTrack, pan: f64, ignoresurf: ^IReaperControlSurface)
CSurf_SetSurfaceRecArm: proc "c" (trackid: ^MediaTrack, recarm: bool, ignoresurf: ^IReaperControlSurface)
CSurf_SetSurfaceSelected: proc "c" (trackid: ^MediaTrack, selected: bool, ignoresurf: ^IReaperControlSurface)
CSurf_SetSurfaceSolo: proc "c" (trackid: ^MediaTrack, solo: bool, ignoresurf: ^IReaperControlSurface)
CSurf_SetSurfaceVolume: proc "c" (trackid: ^MediaTrack, volume: f64, ignoresurf: ^IReaperControlSurface)
CSurf_SetTrackListChange: proc "c" ()
CSurf_TrackFromID: proc "c" (idx: c.int, mcpView: bool) -> ^MediaTrack
CSurf_TrackToID: proc "c" (track: ^MediaTrack, mcpView: bool) -> c.int
DB2SLIDER: proc "c" (x: f64) -> f64
DeleteActionShortcut: proc "c" (section: ^KbdSectionInfo, cmdID: c.int, shortcutidx: c.int) -> bool
DeleteEnvelopePointEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int, ptidx: c.int) -> bool
DeleteEnvelopePointRange: proc "c" (envelope: ^TrackEnvelope, time_start: f64, time_end: f64) -> bool
DeleteEnvelopePointRangeEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int, time_start: f64, time_end: f64) -> bool
DeleteExtState: proc "c" (section: cstring, key: cstring, persist: bool)
DeleteProjectMarker: proc "c" (proj: ^ReaProject, markrgnindexnumber: c.int, isrgn: bool) -> bool
DeleteProjectMarkerByIndex: proc "c" (proj: ^ReaProject, markrgnidx: c.int) -> bool
DeleteTakeMarker: proc "c" (take: ^MediaItem_Take, idx: c.int) -> bool
DeleteTakeStretchMarkers: proc "c" (take: ^MediaItem_Take, idx: c.int, countInOptional: ^c.int) -> c.int
DeleteTempoTimeSigMarker: proc "c" (project: ^ReaProject, markerindex: c.int) -> bool
DeleteTrack: proc "c" (tr: ^MediaTrack)
DeleteTrackMediaItem: proc "c" (tr: ^MediaTrack, it: ^MediaItem) -> bool
DestroyAudioAccessor: proc "c" (accessor: ^AudioAccessor)
DestroyLocalOscHandler: proc "c" (local_osc_handler: rawptr)
DoActionShortcutDialog: proc "c" (hwnd: HWND, section: ^KbdSectionInfo, cmdID: c.int, shortcutidx: c.int) -> bool
Dock_UpdateDockID: proc "c" (ident_str: cstring, whichDock: c.int)
DockGetPosition: proc "c" (whichDock: c.int) -> c.int
DockIsChildOfDock: proc "c" (hwnd: HWND, isFloatingDockerOut: ^bool) -> c.int
DockWindowActivate: proc "c" (hwnd: HWND)
DockWindowAdd: proc "c" (hwnd: HWND, name: cstring, pos: c.int, allowShow: bool)
DockWindowAddEx: proc "c" (hwnd: HWND, name: cstring, identstr: cstring, allowShow: bool)
DockWindowRefresh: proc "c" ()
DockWindowRefreshForHWND: proc "c" (hwnd: HWND)
DockWindowRemove: proc "c" (hwnd: HWND)
DuplicateCustomizableMenu: proc "c" (srcmenu: rawptr, destmenu: rawptr) -> bool
EditTempoTimeSigMarker: proc "c" (project: ^ReaProject, markerindex: c.int) -> bool
EnsureNotCompletelyOffscreen: proc "c" (rInOut: ^RECT)
EnumerateFiles: proc "c" (path: cstring, fileindex: c.int) -> cstring
EnumerateSubdirectories: proc "c" (path: cstring, subdirindex: c.int) -> cstring
EnumPitchShiftModes: proc "c" (mode: c.int, strOut: ^cstring) -> bool
EnumPitchShiftSubModes: proc "c" (mode: c.int, submode: c.int) -> cstring
EnumProjectMarkers: proc "c" (idx: c.int, isrgnOut: ^bool, posOut: ^f64, rgnendOut: ^f64, nameOut: ^cstring, markrgnindexnumberOut: ^c.int) -> c.int
EnumProjectMarkers2: proc "c" (proj: ^ReaProject, idx: c.int, isrgnOut: ^bool, posOut: ^f64, rgnendOut: ^f64, nameOut: ^cstring, markrgnindexnumberOut: ^c.int) -> c.int
EnumProjectMarkers3: proc "c" (proj: ^ReaProject, idx: c.int, isrgnOut: ^bool, posOut: ^f64, rgnendOut: ^f64, nameOut: ^cstring, markrgnindexnumberOut: ^c.int, colorOut: ^c.int) -> c.int
EnumProjects: proc "c" (idx: c.int, projfnOutOptional: cstring, projfnOutOptional_sz: c.int) -> ^ReaProject
EnumProjExtState: proc "c" (proj: ^ReaProject, extname: cstring, idx: c.int, keyOutOptional: cstring, keyOutOptional_sz: c.int, valOutOptional: cstring, valOutOptional_sz: c.int) -> bool
EnumRegionRenderMatrix: proc "c" (proj: ^ReaProject, regionindex: c.int, rendertrack: c.int) -> ^MediaTrack
EnumTrackMIDIProgramNames: proc "c" (track: c.int, programNumber: c.int, programName: cstring, programName_sz: c.int) -> bool
EnumTrackMIDIProgramNamesEx: proc "c" (proj: ^ReaProject, track: ^MediaTrack, programNumber: c.int, programName: cstring, programName_sz: c.int) -> bool
Envelope_Evaluate: proc "c" (envelope: ^TrackEnvelope, time: f64, samplerate: f64, samplesRequested: c.int, valueOutOptional: ^f64, dVdSOutOptional: ^f64, ddVdSOutOptional: ^f64, dddVdSOutOptional: ^f64) -> c.int
Envelope_FormatValue: proc "c" (env: ^TrackEnvelope, value: f64, bufOut: cstring, bufOut_sz: c.int)
Envelope_GetParentTake: proc "c" (env: ^TrackEnvelope, indexOutOptional: ^c.int, index2OutOptional: ^c.int) -> ^MediaItem_Take
Envelope_GetParentTrack: proc "c" (env: ^TrackEnvelope, indexOutOptional: ^c.int, index2OutOptional: ^c.int) -> ^MediaTrack
Envelope_SortPoints: proc "c" (envelope: ^TrackEnvelope) -> bool
Envelope_SortPointsEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int) -> bool
ExecProcess: proc "c" (cmdline: cstring, timeoutmsec: c.int) -> cstring
file_exists: proc "c" (path: cstring) -> bool
FindTempoTimeSigMarker: proc "c" (project: ^ReaProject, time: f64) -> c.int
format_timestr: proc "c" (tpos: f64, buf: cstring, buf_sz: c.int)
format_timestr_len: proc "c" (tpos: f64, buf: cstring, buf_sz: c.int, offset: f64, modeoverride: c.int)
format_timestr_pos: proc "c" (tpos: f64, buf: cstring, buf_sz: c.int, modeoverride: c.int)
FreeHeapPtr: proc "c" (ptr: rawptr)
genGuid: proc "c" (g: ^GUID)
get_config_var: proc "c" (name: cstring, szOut: ^c.int) -> rawptr
get_config_var_string: proc "c" (name: cstring, bufOut: cstring, bufOut_sz: c.int) -> bool
get_ini_file: proc "c" () -> cstring
get_midi_config_var: proc "c" (name: cstring, szOut: ^c.int) -> rawptr
GetActionShortcutDesc: proc "c" (section: ^KbdSectionInfo, cmdID: c.int, shortcutidx: c.int, desc: cstring, desclen: c.int) -> bool
GetActiveTake: proc "c" (item: ^MediaItem) -> ^MediaItem_Take
GetAllProjectPlayStates: proc "c" (ignoreProject: ^ReaProject) -> c.int
GetAppVersion: proc "c" () -> cstring
GetArmedCommand: proc "c" (secOut: cstring, secOut_sz: c.int) -> c.int
GetAudioAccessorEndTime: proc "c" (accessor: ^AudioAccessor) -> f64
GetAudioAccessorHash: proc "c" (accessor: ^AudioAccessor, hashNeed128: cstring)
GetAudioAccessorSamples: proc "c" (accessor: ^AudioAccessor, samplerate: c.int, numchannels: c.int, starttime_sec: f64, numsamplesperchannel: c.int, samplebuffer: ^f64) -> c.int
GetAudioAccessorStartTime: proc "c" (accessor: ^AudioAccessor) -> f64
GetAudioDeviceInfo: proc "c" (attribute: cstring, desc: cstring, desc_sz: c.int) -> bool
GetColorTheme: proc "c" (idx: c.int, defval: c.int) -> INT_PTR
GetColorThemeStruct: proc "c" (szOut: ^c.int) -> rawptr
GetConfigWantsDock: proc "c" (ident_str: cstring) -> c.int
GetContextMenu: proc "c" (idx: c.int) -> HMENU
GetCurrentProjectInLoadSave: proc "c" () -> ^ReaProject
GetCursorContext: proc "c" () -> c.int
GetCursorContext2: proc "c" (want_last_valid: bool) -> c.int
GetCursorPosition: proc "c" () -> f64
GetCursorPositionEx: proc "c" (proj: ^ReaProject) -> f64
GetDisplayedMediaItemColor: proc "c" (item: ^MediaItem) -> c.int
GetDisplayedMediaItemColor2: proc "c" (item: ^MediaItem, take: ^MediaItem_Take) -> c.int
GetEnvelopeInfo_Value: proc "c" (tr: ^TrackEnvelope, parmname: cstring) -> f64
GetEnvelopeName: proc "c" (env: ^TrackEnvelope, bufOut: cstring, bufOut_sz: c.int) -> bool
GetEnvelopePoint: proc "c" (envelope: ^TrackEnvelope, ptidx: c.int, timeOutOptional: ^f64, valueOutOptional: ^f64, shapeOutOptional: ^c.int, tensionOutOptional: ^f64, selectedOutOptional: ^bool) -> bool
GetEnvelopePointByTime: proc "c" (envelope: ^TrackEnvelope, time: f64) -> c.int
GetEnvelopePointByTimeEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int, time: f64) -> c.int
GetEnvelopePointEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int, ptidx: c.int, timeOutOptional: ^f64, valueOutOptional: ^f64, shapeOutOptional: ^c.int, tensionOutOptional: ^f64, selectedOutOptional: ^bool) -> bool
GetEnvelopeScalingMode: proc "c" (env: ^TrackEnvelope) -> c.int
GetEnvelopeStateChunk: proc "c" (env: ^TrackEnvelope, strNeedBig: cstring, strNeedBig_sz: c.int, isundoOptional: bool) -> bool
GetExePath: proc "c" () -> cstring
GetExtState: proc "c" (section: cstring, key: cstring) -> cstring
GetFocusedFX: proc "c" (tracknumberOut: ^c.int, itemnumberOut: ^c.int, fxnumberOut: ^c.int) -> c.int
GetFocusedFX2: proc "c" (tracknumberOut: ^c.int, itemnumberOut: ^c.int, fxnumberOut: ^c.int) -> c.int
GetFreeDiskSpaceForRecordPath: proc "c" (proj: ^ReaProject, pathidx: c.int) -> c.int
GetFXEnvelope: proc "c" (track: ^MediaTrack, fxindex: c.int, parameterindex: c.int, create: bool) -> ^TrackEnvelope
GetGlobalAutomationOverride: proc "c" () -> c.int
GetHZoomLevel: proc "c" () -> f64
GetIconThemePointer: proc "c" (name: cstring) -> rawptr
GetIconThemePointerForDPI: proc "c" (name: cstring, dpisc: c.int) -> rawptr
GetIconThemeStruct: proc "c" (szOut: ^c.int) -> rawptr
GetInputChannelName: proc "c" (channelIndex: c.int) -> cstring
GetInputOutputLatency: proc "c" (inputlatencyOut: ^c.int, outputLatencyOut: ^c.int)
GetItemEditingTime2: proc "c" (which_itemOut: ^PCM_source, flagsOut: ^c.int) -> f64
GetItemFromPoint: proc "c" (screen_x: c.int, screen_y: c.int, allow_locked: bool, takeOutOptional: ^^MediaItem_Take) -> ^MediaItem
GetItemProjectContext: proc "c" (item: ^MediaItem) -> ^ReaProject
GetItemStateChunk: proc "c" (item: ^MediaItem, strNeedBig: cstring, strNeedBig_sz: c.int, isundoOptional: bool) -> bool
GetLastColorThemeFile: proc "c" () -> cstring
GetLastMarkerAndCurRegion: proc "c" (proj: ^ReaProject, time: f64, markeridxOut: ^c.int, regionidxOut: ^c.int)
GetLastTouchedFX: proc "c" (tracknumberOut: ^c.int, fxnumberOut: ^c.int, paramnumberOut: ^c.int) -> bool
GetLastTouchedTrack: proc "c" () -> ^MediaTrack
GetMainHwnd: proc "c" () -> HWND
GetMasterMuteSoloFlags: proc "c" () -> c.int
GetMasterTrack: proc "c" (proj: ^ReaProject) -> ^MediaTrack
GetMasterTrackVisibility: proc "c" () -> c.int
GetMaxMidiInputs: proc "c" () -> c.int
GetMaxMidiOutputs: proc "c" () -> c.int
GetMediaFileMetadata: proc "c" (mediaSource: ^PCM_source, identifier: cstring, bufOutNeedBig: cstring, bufOutNeedBig_sz: c.int) -> c.int
GetMediaItem: proc "c" (proj: ^ReaProject, itemidx: c.int) -> ^MediaItem
GetMediaItemInfo_Value: proc "c" (item: ^MediaItem, parmname: cstring) -> f64
GetMediaItemNumTakes: proc "c" (item: ^MediaItem) -> c.int
GetMediaItemTake: proc "c" (item: ^MediaItem, tk: c.int) -> ^MediaItem_Take
GetMediaItemTake_Item: proc "c" (take: ^MediaItem_Take) -> ^MediaItem
GetMediaItemTake_Peaks: proc "c" (take: ^MediaItem_Take, peakrate: f64, starttime: f64, numchannels: c.int, numsamplesperchannel: c.int, want_extra_type: c.int, buf: ^f64) -> c.int
GetMediaItemTake_Source: proc "c" (take: ^MediaItem_Take) -> ^PCM_source
GetMediaItemTake_Track: proc "c" (take: ^MediaItem_Take) -> ^MediaTrack
GetMediaItemTakeByGUID: proc "c" (project: ^ReaProject, guid: ^GUID) -> ^MediaItem_Take
GetMediaItemTakeInfo_Value: proc "c" (take: ^MediaItem_Take, parmname: cstring) -> f64
GetMediaItemTrack: proc "c" (item: ^MediaItem) -> ^MediaTrack
GetMediaSourceFileName: proc "c" (source: ^PCM_source, filenamebuf: cstring, filenamebuf_sz: c.int)
GetMediaSourceLength: proc "c" (source: ^PCM_source, lengthIsQNOut: ^bool) -> f64
GetMediaSourceNumChannels: proc "c" (source: ^PCM_source) -> c.int
GetMediaSourceParent: proc "c" (src: ^PCM_source) -> ^PCM_source
GetMediaSourceSampleRate: proc "c" (source: ^PCM_source) -> c.int
GetMediaSourceType: proc "c" (source: ^PCM_source, typebuf: cstring, typebuf_sz: c.int)
GetMediaTrackInfo_Value: proc "c" (tr: ^MediaTrack, parmname: cstring) -> f64
GetMIDIInputName: proc "c" (dev: c.int, nameout: cstring, nameout_sz: c.int) -> bool
GetMIDIOutputName: proc "c" (dev: c.int, nameout: cstring, nameout_sz: c.int) -> bool
GetMixerScroll: proc "c" () -> ^MediaTrack
GetMouseModifier: proc "c" (ctx: cstring, modifier_flag: c.int, action: cstring, action_sz: c.int)
GetMousePosition: proc "c" (xOut: ^c.int, yOut: ^c.int)
GetNumAudioInputs: proc "c" () -> c.int
GetNumAudioOutputs: proc "c" () -> c.int
GetNumMIDIInputs: proc "c" () -> c.int
GetNumMIDIOutputs: proc "c" () -> c.int
GetNumTakeMarkers: proc "c" (take: ^MediaItem_Take) -> c.int
GetNumTracks: proc "c" () -> c.int
GetOS: proc "c" () -> cstring
GetOutputChannelName: proc "c" (channelIndex: c.int) -> cstring
GetOutputLatency: proc "c" () -> f64
GetParentTrack: proc "c" (track: ^MediaTrack) -> ^MediaTrack
GetPeakFileName: proc "c" (fn: cstring, buf: cstring, buf_sz: c.int)
GetPeakFileNameEx: proc "c" (fn: cstring, buf: cstring, buf_sz: c.int, forWrite: bool)
GetPeakFileNameEx2: proc "c" (fn: cstring, buf: cstring, buf_sz: c.int, forWrite: bool, peaksfileextension: cstring)
GetPeaksBitmap: proc "c" (pks: ^PCM_source_peaktransfer_t, maxamp: f64, w: c.int, h: c.int, bmp: ^LICE_IBitmap) -> rawptr
GetPlayPosition: proc "c" () -> f64
GetPlayPosition2: proc "c" () -> f64
GetPlayPosition2Ex: proc "c" (proj: ^ReaProject) -> f64
GetPlayPositionEx: proc "c" (proj: ^ReaProject) -> f64
GetPlayState: proc "c" () -> c.int
GetPlayStateEx: proc "c" (proj: ^ReaProject) -> c.int
GetPreferredDiskReadMode: proc "c" (mode: ^c.int, nb: ^c.int, bs: ^c.int)
GetPreferredDiskReadModePeak: proc "c" (mode: ^c.int, nb: ^c.int, bs: ^c.int)
GetPreferredDiskWriteMode: proc "c" (mode: ^c.int, nb: ^c.int, bs: ^c.int)
GetProjectLength: proc "c" (proj: ^ReaProject) -> f64
GetProjectName: proc "c" (proj: ^ReaProject, buf: cstring, buf_sz: c.int)
GetProjectPath: proc "c" (buf: cstring, buf_sz: c.int)
GetProjectPathEx: proc "c" (proj: ^ReaProject, buf: cstring, buf_sz: c.int)
GetProjectStateChangeCount: proc "c" (proj: ^ReaProject) -> c.int
GetProjectTimeOffset: proc "c" (proj: ^ReaProject, rndframe: bool) -> f64
GetProjectTimeSignature: proc "c" (bpmOut: ^f64, bpiOut: ^f64)
GetProjectTimeSignature2: proc "c" (proj: ^ReaProject, bpmOut: ^f64, bpiOut: ^f64)
GetProjExtState: proc "c" (proj: ^ReaProject, extname: cstring, key: cstring, valOutNeedBig: cstring, valOutNeedBig_sz: c.int) -> c.int
GetResourcePath: proc "c" () -> cstring
GetSelectedEnvelope: proc "c" (proj: ^ReaProject) -> ^TrackEnvelope
GetSelectedMediaItem: proc "c" (proj: ^ReaProject, selitem: c.int) -> ^MediaItem
GetSelectedTrack: proc "c" (proj: ^ReaProject, seltrackidx: c.int) -> ^MediaTrack
GetSelectedTrack2: proc "c" (proj: ^ReaProject, seltrackidx: c.int, wantmaster: bool) -> ^MediaTrack
GetSelectedTrackEnvelope: proc "c" (proj: ^ReaProject) -> ^TrackEnvelope
GetSet_ArrangeView2: proc "c" (proj: ^ReaProject, isSet: bool, screen_x_start: c.int, screen_x_end: c.int, start_timeOut: ^f64, end_timeOut: ^f64)
GetSet_LoopTimeRange: proc "c" (isSet: bool, isLoop: bool, startOut: ^f64, endOut: ^f64, allowautoseek: bool)
GetSet_LoopTimeRange2: proc "c" (proj: ^ReaProject, isSet: bool, isLoop: bool, startOut: ^f64, endOut: ^f64, allowautoseek: bool)
GetSetAutomationItemInfo: proc "c" (env: ^TrackEnvelope, autoitem_idx: c.int, desc: cstring, value: f64, is_set: bool) -> f64
GetSetAutomationItemInfo_String: proc "c" (env: ^TrackEnvelope, autoitem_idx: c.int, desc: cstring, valuestrNeedBig: cstring, is_set: bool) -> bool
GetSetEnvelopeInfo_String: proc "c" (env: ^TrackEnvelope, parmname: cstring, stringNeedBig: cstring, setNewValue: bool) -> bool
GetSetEnvelopeState: proc "c" (env: ^TrackEnvelope, str: cstring, str_sz: c.int) -> bool
GetSetEnvelopeState2: proc "c" (env: ^TrackEnvelope, str: cstring, str_sz: c.int, isundo: bool) -> bool
GetSetItemState: proc "c" (item: ^MediaItem, str: cstring, str_sz: c.int) -> bool
GetSetItemState2: proc "c" (item: ^MediaItem, str: cstring, str_sz: c.int, isundo: bool) -> bool
GetSetMediaItemInfo: proc "c" (item: ^MediaItem, parmname: cstring, setNewValue: rawptr) -> rawptr
GetSetMediaItemInfo_String: proc "c" (item: ^MediaItem, parmname: cstring, stringNeedBig: cstring, setNewValue: bool) -> bool
GetSetMediaItemTakeInfo: proc "c" (tk: ^MediaItem_Take, parmname: cstring, setNewValue: rawptr) -> rawptr
GetSetMediaItemTakeInfo_String: proc "c" (tk: ^MediaItem_Take, parmname: cstring, stringNeedBig: cstring, setNewValue: bool) -> bool
GetSetMediaTrackInfo: proc "c" (tr: ^MediaTrack, parmname: cstring, setNewValue: rawptr) -> rawptr
GetSetMediaTrackInfo_String: proc "c" (tr: ^MediaTrack, parmname: cstring, stringNeedBig: cstring, setNewValue: bool) -> bool
GetSetObjectState: proc "c" (obj: rawptr, str: cstring) -> cstring
GetSetObjectState2: proc "c" (obj: rawptr, str: cstring, isundo: bool) -> cstring
GetSetProjectAuthor: proc "c" (proj: ^ReaProject, set: bool, author: cstring, author_sz: c.int)
GetSetProjectGrid: proc "c" (project: ^ReaProject, set: bool, divisionInOutOptional: ^f64, swingmodeInOutOptional: ^c.int, swingamtInOutOptional: ^f64) -> c.int
GetSetProjectInfo: proc "c" (project: ^ReaProject, desc: cstring, value: f64, is_set: bool) -> f64
GetSetProjectInfo_String: proc "c" (project: ^ReaProject, desc: cstring, valuestrNeedBig: cstring, is_set: bool) -> bool
GetSetProjectNotes: proc "c" (proj: ^ReaProject, set: bool, notesNeedBig: cstring, notesNeedBig_sz: c.int)
GetSetRepeat: proc "c" (val: c.int) -> c.int
GetSetRepeatEx: proc "c" (proj: ^ReaProject, val: c.int) -> c.int
GetSetTrackGroupMembership: proc "c" (tr: ^MediaTrack, groupname: cstring, setmask: c.uint, setvalue: c.uint) -> c.uint
GetSetTrackGroupMembershipHigh: proc "c" (tr: ^MediaTrack, groupname: cstring, setmask: c.uint, setvalue: c.uint) -> c.uint
GetSetTrackMIDISupportFile: proc "c" (proj: ^ReaProject, track: ^MediaTrack, which: c.int, filename: cstring) -> cstring
GetSetTrackSendInfo: proc "c" (tr: ^MediaTrack, category: c.int, sendidx: c.int, parmname: cstring, setNewValue: rawptr) -> rawptr
GetSetTrackSendInfo_String: proc "c" (tr: ^MediaTrack, category: c.int, sendidx: c.int, parmname: cstring, stringNeedBig: cstring, setNewValue: bool) -> bool
GetSetTrackState: proc "c" (track: ^MediaTrack, str: cstring, str_sz: c.int) -> bool
GetSetTrackState2: proc "c" (track: ^MediaTrack, str: cstring, str_sz: c.int, isundo: bool) -> bool
GetSubProjectFromSource: proc "c" (src: ^PCM_source) -> ^ReaProject
GetTake: proc "c" (item: ^MediaItem, takeidx: c.int) -> ^MediaItem_Take
GetTakeEnvelope: proc "c" (take: ^MediaItem_Take, envidx: c.int) -> ^TrackEnvelope
GetTakeEnvelopeByName: proc "c" (take: ^MediaItem_Take, envname: cstring) -> ^TrackEnvelope
GetTakeMarker: proc "c" (take: ^MediaItem_Take, idx: c.int, nameOut: cstring, nameOut_sz: c.int, colorOutOptional: ^c.int) -> f64
GetTakeName: proc "c" (take: ^MediaItem_Take) -> cstring
GetTakeNumStretchMarkers: proc "c" (take: ^MediaItem_Take) -> c.int
GetTakeStretchMarker: proc "c" (take: ^MediaItem_Take, idx: c.int, posOut: ^f64, srcposOutOptional: ^f64) -> c.int
GetTakeStretchMarkerSlope: proc "c" (take: ^MediaItem_Take, idx: c.int) -> f64
GetTCPFXParm: proc "c" (project: ^ReaProject, track: ^MediaTrack, index: c.int, fxindexOut: ^c.int, parmidxOut: ^c.int) -> bool
GetTempoMatchPlayRate: proc "c" (source: ^PCM_source, srcscale: f64, position: f64, mult: f64, rateOut: ^f64, targetlenOut: ^f64) -> bool
GetTempoTimeSigMarker: proc "c" (proj: ^ReaProject, ptidx: c.int, timeposOut: ^f64, measureposOut: ^c.int, beatposOut: ^f64, bpmOut: ^f64, timesig_numOut: ^c.int, timesig_denomOut: ^c.int, lineartempoOut: ^bool) -> bool
GetThemeColor: proc "c" (ini_key: cstring, flagsOptional: c.int) -> c.int
GetToggleCommandState: proc "c" (command_id: c.int) -> c.int
GetToggleCommandState2: proc "c" (section: ^KbdSectionInfo, command_id: c.int) -> c.int
GetToggleCommandStateEx: proc "c" (section_id: c.int, command_id: c.int) -> c.int
GetToggleCommandStateThroughHooks: proc "c" (section: ^KbdSectionInfo, command_id: c.int) -> c.int
GetTooltipWindow: proc "c" () -> HWND
GetTrack: proc "c" (proj: ^ReaProject, trackidx: c.int) -> ^MediaTrack
GetTrackAutomationMode: proc "c" (tr: ^MediaTrack) -> c.int
GetTrackColor: proc "c" (track: ^MediaTrack) -> c.int
GetTrackDepth: proc "c" (track: ^MediaTrack) -> c.int
GetTrackEnvelope: proc "c" (track: ^MediaTrack, envidx: c.int) -> ^TrackEnvelope
GetTrackEnvelopeByChunkName: proc "c" (tr: ^MediaTrack, cfgchunkname: cstring) -> ^TrackEnvelope
GetTrackEnvelopeByName: proc "c" (track: ^MediaTrack, envname: cstring) -> ^TrackEnvelope
GetTrackFromPoint: proc "c" (screen_x: c.int, screen_y: c.int, infoOutOptional: ^c.int) -> ^MediaTrack
GetTrackGUID: proc "c" (tr: ^MediaTrack) -> ^GUID
GetTrackInfo: proc "c" (track: INT_PTR, flags: ^c.int) -> cstring
GetTrackMediaItem: proc "c" (tr: ^MediaTrack, itemidx: c.int) -> ^MediaItem
GetTrackMIDILyrics: proc "c" (track: ^MediaTrack, flag: c.int, bufWantNeedBig: cstring, bufWantNeedBig_sz: ^c.int) -> bool
GetTrackMIDINoteName: proc "c" (track: c.int, pitch: c.int, chan: c.int) -> cstring
GetTrackMIDINoteNameEx: proc "c" (proj: ^ReaProject, track: ^MediaTrack, pitch: c.int, chan: c.int) -> cstring
GetTrackMIDINoteRange: proc "c" (proj: ^ReaProject, track: ^MediaTrack, note_loOut: ^c.int, note_hiOut: ^c.int)
GetTrackName: proc "c" (track: ^MediaTrack, bufOut: cstring, bufOut_sz: c.int) -> bool
GetTrackNumMediaItems: proc "c" (tr: ^MediaTrack) -> c.int
GetTrackNumSends: proc "c" (tr: ^MediaTrack, category: c.int) -> c.int
GetTrackReceiveName: proc "c" (track: ^MediaTrack, recv_index: c.int, buf: cstring, buf_sz: c.int) -> bool
GetTrackReceiveUIMute: proc "c" (track: ^MediaTrack, recv_index: c.int, muteOut: ^bool) -> bool
GetTrackReceiveUIVolPan: proc "c" (track: ^MediaTrack, recv_index: c.int, volumeOut: ^f64, panOut: ^f64) -> bool
GetTrackSendInfo_Value: proc "c" (tr: ^MediaTrack, category: c.int, sendidx: c.int, parmname: cstring) -> f64
GetTrackSendName: proc "c" (track: ^MediaTrack, send_index: c.int, buf: cstring, buf_sz: c.int) -> bool
GetTrackSendUIMute: proc "c" (track: ^MediaTrack, send_index: c.int, muteOut: ^bool) -> bool
GetTrackSendUIVolPan: proc "c" (track: ^MediaTrack, send_index: c.int, volumeOut: ^f64, panOut: ^f64) -> bool
GetTrackState: proc "c" (track: ^MediaTrack, flagsOut: ^c.int) -> cstring
GetTrackStateChunk: proc "c" (track: ^MediaTrack, strNeedBig: cstring, strNeedBig_sz: c.int, isundoOptional: bool) -> bool
GetTrackUIMute: proc "c" (track: ^MediaTrack, muteOut: ^bool) -> bool
GetTrackUIPan: proc "c" (track: ^MediaTrack, pan1Out: ^f64, pan2Out: ^f64, panmodeOut: ^c.int) -> bool
GetTrackUIVolPan: proc "c" (track: ^MediaTrack, volumeOut: ^f64, panOut: ^f64) -> bool
GetUnderrunTime: proc "c" (audio_xrunOutOptional: ^c.uint, media_xrunOutOptional: ^c.uint, curtimeOutOptional: ^c.uint)
GetUserFileNameForRead: proc "c" (filenameNeed4096: cstring, title: cstring, defext: cstring) -> bool
GetUserInputs: proc "c" (title: cstring, num_inputs: c.int, captions_csv: cstring, retvals_csv: cstring, retvals_csv_sz: c.int) -> bool
GoToMarker: proc "c" (proj: ^ReaProject, marker_index: c.int, use_timeline_order: bool)
GoToRegion: proc "c" (proj: ^ReaProject, region_index: c.int, use_timeline_order: bool)
GR_SelectColor: proc "c" (hwnd: HWND, colorOut: ^c.int) -> c.int
GSC_mainwnd: proc "c" (t: c.int) -> c.int
guidToString: proc "c" (g: ^GUID, destNeed64: [^]byte)
HasExtState: proc "c" (section: cstring, key: cstring) -> bool
HasTrackMIDIPrograms: proc "c" (track: c.int) -> cstring
HasTrackMIDIProgramsEx: proc "c" (proj: ^ReaProject, track: ^MediaTrack) -> cstring
Help_Set: proc "c" (helpstring: cstring, is_temporary_help: bool)
HiresPeaksFromSource: proc "c" (src: ^PCM_source, block: ^PCM_source_peaktransfer_t)
image_resolve_fn: proc "c" (input: cstring, output: cstring, out_sz: c.int)
InsertAutomationItem: proc "c" (env: ^TrackEnvelope, pool_id: c.int, position: f64, length: f64) -> c.int
InsertEnvelopePoint: proc "c" (envelope: ^TrackEnvelope, time: f64, value: f64, shape: c.int, tension: f64, selected: bool, noSortInOptional: ^bool) -> bool
InsertEnvelopePointEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int, time: f64, value: f64, shape: c.int, tension: f64, selected: bool, noSortInOptional: ^bool) -> bool
InsertMedia: proc "c" (file: cstring, mode: c.int) -> c.int
InsertMediaSection: proc "c" (file: cstring, mode: c.int, startpct: f64, endpct: f64, pitchshift: f64) -> c.int
InsertTrackAtIndex: proc "c" (idx: c.int, wantDefaults: bool)
IsInRealTimeAudio: proc "c" () -> c.int
IsItemTakeActiveForPlayback: proc "c" (item: ^MediaItem, take: ^MediaItem_Take) -> bool
IsMediaExtension: proc "c" (ext: cstring, wantOthers: bool) -> bool
IsMediaItemSelected: proc "c" (item: ^MediaItem) -> bool
IsProjectDirty: proc "c" (proj: ^ReaProject) -> c.int
IsREAPER: proc "c" () -> bool
IsTrackSelected: proc "c" (track: ^MediaTrack) -> bool
IsTrackVisible: proc "c" (track: ^MediaTrack, mixer: bool) -> bool
joystick_create: proc "c" (guid: ^GUID) -> ^joystick_device
joystick_destroy: proc "c" (device: ^joystick_device)
joystick_enum: proc "c" (index: c.int, namestrOutOptional: ^cstring) -> cstring
joystick_getaxis: proc "c" (dev: ^joystick_device, axis: c.int) -> f64
joystick_getbuttonmask: proc "c" (dev: ^joystick_device) -> c.uint
joystick_getinfo: proc "c" (dev: ^joystick_device, axesOutOptional: ^c.int, povsOutOptional: ^c.int) -> c.int
joystick_getpov: proc "c" (dev: ^joystick_device, pov: c.int) -> f64
joystick_update: proc "c" (dev: ^joystick_device) -> bool
kbd_enumerateActions: proc "c" (section: ^KbdSectionInfo, idx: c.int, nameOut: ^cstring) -> c.int
kbd_formatKeyName: proc "c" (ac: ^ACCEL, s: cstring)
kbd_getCommandName: proc "c" (cmd: c.int, s: cstring, section: ^KbdSectionInfo)
kbd_getTextFromCmd: proc "c" (cmd: DWORD, section: ^KbdSectionInfo) -> cstring
KBD_OnMainActionEx: proc "c" (cmd: c.int, val: c.int, valhw: c.int, relmode: c.int, hwnd: HWND, proj: ^ReaProject) -> c.int
kbd_OnMidiEvent: proc "c" (evt: ^MIDI_event_t, dev_index: c.int)
kbd_OnMidiList: proc "c" (list: ^MIDI_eventlist, dev_index: c.int)
kbd_ProcessActionsMenu: proc "c" (menu: HMENU, section: ^KbdSectionInfo)
kbd_processMidiEventActionEx: proc "c" (evt: ^MIDI_event_t, section: ^KbdSectionInfo, hwndCtx: HWND) -> bool
kbd_reprocessMenu: proc "c" (menu: HMENU, section: ^KbdSectionInfo)
kbd_RunCommandThroughHooks: proc "c" (section: ^KbdSectionInfo, actionCommandID: ^c.int, val: ^c.int, valhw: ^c.int, relmode: ^c.int, hwnd: HWND) -> bool
kbd_translateAccelerator: proc "c" (hwnd: HWND, msg: ^MSG, section: ^KbdSectionInfo) -> c.int
kbd_translateMouse: proc "c" (winmsg: rawptr, midimsg: ^u8) -> bool
LICE__Destroy: proc "c" (bm: ^LICE_IBitmap)
LICE__DestroyFont: proc "c" (font: ^LICE_IFont)
LICE__DrawText: proc "c" (font: ^LICE_IFont, bm: ^LICE_IBitmap, str: cstring, strcnt: c.int, rect: ^RECT, dtFlags: UINT) -> c.int
LICE__GetBits: proc "c" (bm: ^LICE_IBitmap) -> rawptr
LICE__GetDC: proc "c" (bm: ^LICE_IBitmap) -> HDC
LICE__GetHeight: proc "c" (bm: ^LICE_IBitmap) -> c.int
LICE__GetRowSpan: proc "c" (bm: ^LICE_IBitmap) -> c.int
LICE__GetWidth: proc "c" (bm: ^LICE_IBitmap) -> c.int
LICE__IsFlipped: proc "c" (bm: ^LICE_IBitmap) -> bool
LICE__resize: proc "c" (bm: ^LICE_IBitmap, w: c.int, h: c.int) -> bool
LICE__SetBkColor: proc "c" (font: ^LICE_IFont, color: LICE_pixel) -> LICE_pixel
LICE__SetFromHFont: proc "c" (font: ^LICE_IFont, hfont: HFONT, flags: c.int)
LICE__SetTextColor: proc "c" (font: ^LICE_IFont, color: LICE_pixel) -> LICE_pixel
LICE__SetTextCombineMode: proc "c" (ifont: ^LICE_IFont, mode: c.int, alpha: f32)
LICE_Arc: proc "c" (dest: ^LICE_IBitmap, cx: f32, cy: f32, r: f32, minAngle: f32, maxAngle: f32, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool)
LICE_Blit: proc "c" (dest: ^LICE_IBitmap, src: ^LICE_IBitmap, dstx: c.int, dsty: c.int, srcx: c.int, srcy: c.int, srcw: c.int, srch: c.int, alpha: f32, mode: c.int)
LICE_Blur: proc "c" (dest: ^LICE_IBitmap, src: ^LICE_IBitmap, dstx: c.int, dsty: c.int, srcx: c.int, srcy: c.int, srcw: c.int, srch: c.int)
LICE_BorderedRect: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, w: c.int, h: c.int, bgcolor: LICE_pixel, fgcolor: LICE_pixel, alpha: f32, mode: c.int)
LICE_Circle: proc "c" (dest: ^LICE_IBitmap, cx: f32, cy: f32, r: f32, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool)
LICE_Clear: proc "c" (dest: ^LICE_IBitmap, color: LICE_pixel)
LICE_ClearRect: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, w: c.int, h: c.int, mask: LICE_pixel, orbits: LICE_pixel)
LICE_ClipLine: proc "c" (pX1Out: ^c.int, pY1Out: ^c.int, pX2Out: ^c.int, pY2Out: ^c.int, xLo: c.int, yLo: c.int, xHi: c.int, yHi: c.int) -> bool
LICE_Copy: proc "c" (dest: ^LICE_IBitmap, src: ^LICE_IBitmap)
LICE_CreateBitmap: proc "c" (mode: c.int, w: c.int, h: c.int) -> ^LICE_IBitmap
LICE_CreateFont: proc "c" () -> ^LICE_IFont
LICE_DrawCBezier: proc "c" (dest: ^LICE_IBitmap, xstart: f64, ystart: f64, xctl1: f64, yctl1: f64, xctl2: f64, yctl2: f64, xend: f64, yend: f64, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool, tol: f64)
LICE_DrawChar: proc "c" (bm: ^LICE_IBitmap, x: c.int, y: c.int, c_: u8, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_DrawGlyph: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, color: LICE_pixel, alphas: ^LICE_pixel_chan, glyph_w: c.int, glyph_h: c.int, alpha: f32, mode: c.int)
LICE_DrawRect: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, w: c.int, h: c.int, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_DrawText: proc "c" (bm: ^LICE_IBitmap, x: c.int, y: c.int, string: cstring, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_FillCBezier: proc "c" (dest: ^LICE_IBitmap, xstart: f64, ystart: f64, xctl1: f64, yctl1: f64, xctl2: f64, yctl2: f64, xend: f64, yend: f64, yfill: c.int, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool, tol: f64)
LICE_FillCircle: proc "c" (dest: ^LICE_IBitmap, cx: f32, cy: f32, r: f32, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool)
LICE_FillConvexPolygon: proc "c" (dest: ^LICE_IBitmap, x: ^c.int, y: ^c.int, npoints: c.int, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_FillRect: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, w: c.int, h: c.int, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_FillTrapezoid: proc "c" (dest: ^LICE_IBitmap, x1a: c.int, x1b: c.int, y1: c.int, x2a: c.int, x2b: c.int, y2: c.int, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_FillTriangle: proc "c" (dest: ^LICE_IBitmap, x1: c.int, y1: c.int, x2: c.int, y2: c.int, x3: c.int, y3: c.int, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_GetPixel: proc "c" (bm: ^LICE_IBitmap, x: c.int, y: c.int) -> LICE_pixel
LICE_GradRect: proc "c" (dest: ^LICE_IBitmap, dstx: c.int, dsty: c.int, dstw: c.int, dsth: c.int, ir: f32, ig: f32, ib: f32, ia: f32, drdx: f32, dgdx: f32, dbdx: f32, dadx: f32, drdy: f32, dgdy: f32, dbdy: f32, dady: f32, mode: c.int)
LICE_Line: proc "c" (dest: ^LICE_IBitmap, x1: f32, y1: f32, x2: f32, y2: f32, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool)
LICE_ThickFLine: proc "c" (dest: ^LICE_IBitmap, x1, y1, x2, y2: f64, color: LICE_pixel, alpha: f32, mode, wid: c.int)
LICE_LineInt: proc "c" (dest: ^LICE_IBitmap, x1: c.int, y1: c.int, x2: c.int, y2: c.int, color: LICE_pixel, alpha: f32, mode: c.int, aa: bool)
LICE_LoadPNG: proc "c" (filename: cstring, bmp: ^LICE_IBitmap) -> ^LICE_IBitmap
LICE_LoadPNGFromResource: proc "c" (hInst: HINSTANCE, resid: cstring, bmp: ^LICE_IBitmap) -> ^LICE_IBitmap
LICE_MeasureText: proc "c" (string: cstring, w: ^c.int, h: ^c.int)
LICE_MultiplyAddRect: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, w: c.int, h: c.int, rsc: f32, gsc: f32, bsc: f32, asc: f32, radd: f32, gadd: f32, badd: f32, aadd: f32)
LICE_PutPixel: proc "c" (bm: ^LICE_IBitmap, x: c.int, y: c.int, color: LICE_pixel, alpha: f32, mode: c.int)
LICE_RotatedBlit: proc "c" (dest: ^LICE_IBitmap, src: ^LICE_IBitmap, dstx: c.int, dsty: c.int, dstw: c.int, dsth: c.int, srcx: f32, srcy: f32, srcw: f32, srch: f32, angle: f32, cliptosourcerect: bool, alpha: f32, mode: c.int, rotxcent: f32, rotycent: f32)
LICE_RoundRect: proc "c" (drawbm: ^LICE_IBitmap, xpos: f32, ypos: f32, w: f32, h: f32, cornerradius: c.int, col: LICE_pixel, alpha: f32, mode: c.int, aa: bool)
LICE_ScaledBlit: proc "c" (dest: ^LICE_IBitmap, src: ^LICE_IBitmap, dstx: c.int, dsty: c.int, dstw: c.int, dsth: c.int, srcx: f32, srcy: f32, srcw: f32, srch: f32, alpha: f32, mode: c.int)
LICE_SimpleFill: proc "c" (dest: ^LICE_IBitmap, x: c.int, y: c.int, newcolor: LICE_pixel, comparemask: LICE_pixel, keepmask: LICE_pixel)
LocalizeString: proc "c" (src_string: cstring, section: cstring, flagsOptional: c.int) -> cstring
Loop_OnArrow: proc "c" (project: ^ReaProject, direction: c.int) -> bool
Main_OnCommand: proc "c" (command: c.int, flag: c.int)
Main_OnCommandEx: proc "c" (command: c.int, flag: c.int, proj: ^ReaProject)
Main_openProject: proc "c" (name: cstring)
Main_SaveProject: proc "c" (proj: ^ReaProject, forceSaveAsInOptional: bool)
Main_UpdateLoopInfo: proc "c" (ignoremask: c.int)
MarkProjectDirty: proc "c" (proj: ^ReaProject)
MarkTrackItemsDirty: proc "c" (track: ^MediaTrack, item: ^MediaItem)
Master_GetPlayRate: proc "c" (project: ^ReaProject) -> f64
Master_GetPlayRateAtTime: proc "c" (time_s: f64, proj: ^ReaProject) -> f64
Master_GetTempo: proc "c" () -> f64
Master_NormalizePlayRate: proc "c" (playrate: f64, isnormalized: bool) -> f64
Master_NormalizeTempo: proc "c" (bpm: f64, isnormalized: bool) -> f64
MB: proc "c" (msg: cstring, title: cstring, type: c.int) -> c.int
MediaItemDescendsFromTrack: proc "c" (item: ^MediaItem, track: ^MediaTrack) -> c.int
MIDI_CountEvts: proc "c" (take: ^MediaItem_Take, notecntOut: ^c.int, ccevtcntOut: ^c.int, textsyxevtcntOut: ^c.int) -> c.int
MIDI_DeleteCC: proc "c" (take: ^MediaItem_Take, ccidx: c.int) -> bool
MIDI_DeleteEvt: proc "c" (take: ^MediaItem_Take, evtidx: c.int) -> bool
MIDI_DeleteNote: proc "c" (take: ^MediaItem_Take, noteidx: c.int) -> bool
MIDI_DeleteTextSysexEvt: proc "c" (take: ^MediaItem_Take, textsyxevtidx: c.int) -> bool
MIDI_DisableSort: proc "c" (take: ^MediaItem_Take)
MIDI_EnumSelCC: proc "c" (take: ^MediaItem_Take, ccidx: c.int) -> c.int
MIDI_EnumSelEvts: proc "c" (take: ^MediaItem_Take, evtidx: c.int) -> c.int
MIDI_EnumSelNotes: proc "c" (take: ^MediaItem_Take, noteidx: c.int) -> c.int
MIDI_EnumSelTextSysexEvts: proc "c" (take: ^MediaItem_Take, textsyxidx: c.int) -> c.int
MIDI_eventlist_Create: proc "c" () -> ^MIDI_eventlist
MIDI_eventlist_Destroy: proc "c" (evtlist: ^MIDI_eventlist)
MIDI_GetAllEvts: proc "c" (take: ^MediaItem_Take, bufNeedBig: cstring, bufNeedBig_sz: ^c.int) -> bool
MIDI_GetCC: proc "c" (take: ^MediaItem_Take, ccidx: c.int, selectedOut: ^bool, mutedOut: ^bool, ppqposOut: ^f64, chanmsgOut: ^c.int, chanOut: ^c.int, msg2Out: ^c.int, msg3Out: ^c.int) -> bool
MIDI_GetCCShape: proc "c" (take: ^MediaItem_Take, ccidx: c.int, shapeOut: ^c.int, beztensionOut: ^f64) -> bool
MIDI_GetEvt: proc "c" (take: ^MediaItem_Take, evtidx: c.int, selectedOut: ^bool, mutedOut: ^bool, ppqposOut: ^f64, msg: cstring, msg_sz: ^c.int) -> bool
MIDI_GetGrid: proc "c" (take: ^MediaItem_Take, swingOutOptional: ^f64, noteLenOutOptional: ^f64) -> f64
MIDI_GetHash: proc "c" (take: ^MediaItem_Take, notesonly: bool, hash: cstring, hash_sz: c.int) -> bool
MIDI_GetNote: proc "c" (take: ^MediaItem_Take, noteidx: c.int, selectedOut: ^bool, mutedOut: ^bool, startppqposOut: ^f64, endppqposOut: ^f64, chanOut: ^c.int, pitchOut: ^c.int, velOut: ^c.int) -> bool
MIDI_GetPPQPos_EndOfMeasure: proc "c" (take: ^MediaItem_Take, ppqpos: f64) -> f64
MIDI_GetPPQPos_StartOfMeasure: proc "c" (take: ^MediaItem_Take, ppqpos: f64) -> f64
MIDI_GetPPQPosFromProjQN: proc "c" (take: ^MediaItem_Take, projqn: f64) -> f64
MIDI_GetPPQPosFromProjTime: proc "c" (take: ^MediaItem_Take, projtime: f64) -> f64
MIDI_GetProjQNFromPPQPos: proc "c" (take: ^MediaItem_Take, ppqpos: f64) -> f64
MIDI_GetProjTimeFromPPQPos: proc "c" (take: ^MediaItem_Take, ppqpos: f64) -> f64
MIDI_GetScale: proc "c" (take: ^MediaItem_Take, rootOut: ^c.int, scaleOut: ^c.int, name: cstring, name_sz: c.int) -> bool
MIDI_GetTextSysexEvt: proc "c" (take: ^MediaItem_Take, textsyxevtidx: c.int, selectedOutOptional: ^bool, mutedOutOptional: ^bool, ppqposOutOptional: ^f64, typeOutOptional: ^c.int, msgOptional: cstring, msgOptional_sz: ^c.int) -> bool
MIDI_GetTrackHash: proc "c" (track: ^MediaTrack, notesonly: bool, hash: cstring, hash_sz: c.int) -> bool
MIDI_InsertCC: proc "c" (take: ^MediaItem_Take, selected: bool, muted: bool, ppqpos: f64, chanmsg: c.int, chan: c.int, msg2: c.int, msg3: c.int) -> bool
MIDI_InsertEvt: proc "c" (take: ^MediaItem_Take, selected: bool, muted: bool, ppqpos: f64, bytestr: cstring, bytestr_sz: c.int) -> bool
MIDI_InsertNote: proc "c" (take: ^MediaItem_Take, selected: bool, muted: bool, startppqpos: f64, endppqpos: f64, chan: c.int, pitch: c.int, vel: c.int, noSortInOptional: ^bool) -> bool
MIDI_InsertTextSysexEvt: proc "c" (take: ^MediaItem_Take, selected: bool, muted: bool, ppqpos: f64, type: c.int, bytestr: cstring, bytestr_sz: c.int) -> bool
midi_reinit: proc "c" ()
MIDI_SelectAll: proc "c" (take: ^MediaItem_Take, select: bool)
MIDI_SetAllEvts: proc "c" (take: ^MediaItem_Take, buf: cstring, buf_sz: c.int) -> bool
MIDI_SetCC: proc "c" (take: ^MediaItem_Take, ccidx: c.int, selectedInOptional: ^bool, mutedInOptional: ^bool, ppqposInOptional: ^f64, chanmsgInOptional: ^c.int, chanInOptional: ^c.int, msg2InOptional: ^c.int, msg3InOptional: ^c.int, noSortInOptional: ^bool) -> bool
MIDI_SetCCShape: proc "c" (take: ^MediaItem_Take, ccidx: c.int, shape: c.int, beztension: f64, noSortInOptional: ^bool) -> bool
MIDI_SetEvt: proc "c" (take: ^MediaItem_Take, evtidx: c.int, selectedInOptional: ^bool, mutedInOptional: ^bool, ppqposInOptional: ^f64, msgOptional: cstring, msgOptional_sz: c.int, noSortInOptional: ^bool) -> bool
MIDI_SetItemExtents: proc "c" (item: ^MediaItem, startQN: f64, endQN: f64) -> bool
MIDI_SetNote: proc "c" (take: ^MediaItem_Take, noteidx: c.int, selectedInOptional: ^bool, mutedInOptional: ^bool, startppqposInOptional: ^f64, endppqposInOptional: ^f64, chanInOptional: ^c.int, pitchInOptional: ^c.int, velInOptional: ^c.int, noSortInOptional: ^bool) -> bool
MIDI_SetTextSysexEvt: proc "c" (take: ^MediaItem_Take, textsyxevtidx: c.int, selectedInOptional: ^bool, mutedInOptional: ^bool, ppqposInOptional: ^f64, typeInOptional: ^c.int, msgOptional: cstring, msgOptional_sz: c.int, noSortInOptional: ^bool) -> bool
MIDI_Sort: proc "c" (take: ^MediaItem_Take)
MIDIEditor_GetActive: proc "c" () -> HWND
MIDIEditor_GetMode: proc "c" (midieditor: HWND) -> c.int
MIDIEditor_GetSetting_int: proc "c" (midieditor: HWND, setting_desc: cstring) -> c.int
MIDIEditor_GetSetting_str: proc "c" (midieditor: HWND, setting_desc: cstring, buf: cstring, buf_sz: c.int) -> bool
MIDIEditor_GetTake: proc "c" (midieditor: HWND) -> ^MediaItem_Take
MIDIEditor_LastFocused_OnCommand: proc "c" (command_id: c.int, islistviewcommand: bool) -> bool
MIDIEditor_OnCommand: proc "c" (midieditor: HWND, command_id: c.int) -> bool
MIDIEditor_SetSetting_int: proc "c" (midieditor: HWND, setting_desc: cstring, setting: c.int) -> bool
mkpanstr: proc "c" (strNeed64: cstring, pan: f64)
mkvolpanstr: proc "c" (strNeed64: cstring, vol: f64, pan: f64)
mkvolstr: proc "c" (strNeed64: cstring, vol: f64)
MoveEditCursor: proc "c" (adjamt: f64, dosel: bool)
MoveMediaItemToTrack: proc "c" (item: ^MediaItem, desttr: ^MediaTrack) -> bool
MuteAllTracks: proc "c" (mute: bool)
my_getViewport: proc "c" (r: ^RECT, sr: ^RECT, wantWorkArea: bool)
NamedCommandLookup: proc "c" (command_name: cstring) -> c.int
OnPauseButton: proc "c" ()
OnPauseButtonEx: proc "c" (proj: ^ReaProject)
OnPlayButton: proc "c" ()
OnPlayButtonEx: proc "c" (proj: ^ReaProject)
OnStopButton: proc "c" ()
OnStopButtonEx: proc "c" (proj: ^ReaProject)
OpenColorThemeFile: proc "c" (fn: cstring) -> bool
OpenMediaExplorer: proc "c" (mediafn: cstring, play: bool) -> HWND
OscLocalMessageToHost: proc "c" (message: cstring, valueInOptional: ^f64)
parse_timestr: proc "c" (buf: cstring) -> f64
parse_timestr_len: proc "c" (buf: cstring, offset: f64, modeoverride: c.int) -> f64
parse_timestr_pos: proc "c" (buf: cstring, modeoverride: c.int) -> f64
parsepanstr: proc "c" (str: cstring) -> f64
PCM_Sink_Create: proc "c" (filename: cstring, cfg: cstring, cfg_sz: c.int, nch: c.int, srate: c.int, buildpeaks: bool) -> ^PCM_sink
PCM_Sink_CreateEx: proc "c" (proj: ^ReaProject, filename: cstring, cfg: cstring, cfg_sz: c.int, nch: c.int, srate: c.int, buildpeaks: bool) -> ^PCM_sink
PCM_Sink_CreateMIDIFile: proc "c" (filename: cstring, cfg: cstring, cfg_sz: c.int, bpm: f64, div: c.int) -> ^PCM_sink
PCM_Sink_CreateMIDIFileEx: proc "c" (proj: ^ReaProject, filename: cstring, cfg: cstring, cfg_sz: c.int, bpm: f64, div: c.int) -> ^PCM_sink
PCM_Sink_Enum: proc "c" (idx: c.int, descstrOut: ^cstring) -> c.uint
PCM_Sink_GetExtension: proc "c" (data: cstring, data_sz: c.int) -> cstring
PCM_Sink_ShowConfig: proc "c" (cfg: cstring, cfg_sz: c.int, hwndParent: HWND) -> HWND
PCM_Source_CreateFromFile: proc "c" (filename: cstring) -> ^PCM_source
PCM_Source_CreateFromFileEx: proc "c" (filename: cstring, forcenoMidiImp: bool) -> ^PCM_source
PCM_Source_CreateFromSimple: proc "c" (dec: ^ISimpleMediaDecoder, fn: cstring) -> ^PCM_source
PCM_Source_CreateFromType: proc "c" (sourcetype: cstring) -> ^PCM_source
PCM_Source_Destroy: proc "c" (src: ^PCM_source)
PCM_Source_GetPeaks: proc "c" (src: ^PCM_source, peakrate: f64, starttime: f64, numchannels: c.int, numsamplesperchannel: c.int, want_extra_type: c.int, buf: ^f64) -> c.int
PCM_Source_GetSectionInfo: proc "c" (src: ^PCM_source, offsOut: ^f64, lenOut: ^f64, revOut: ^bool) -> bool
PeakBuild_Create: proc "c" (src: ^PCM_source, fn: cstring, srate: c.int, nch: c.int) -> ^REAPER_PeakBuild_Interface
PeakBuild_CreateEx: proc "c" (src: ^PCM_source, fn: cstring, srate: c.int, nch: c.int, flags: c.int) -> ^REAPER_PeakBuild_Interface
PeakGet_Create: proc "c" (fn: cstring, srate: c.int, nch: c.int) -> ^REAPER_PeakGet_Interface
PitchShiftSubModeMenu: proc "c" (hwnd: HWND, x: c.int, y: c.int, mode: c.int, submode_sel: c.int) -> c.int
PlayPreview: proc "c" (preview: ^preview_register_t) -> c.int
PlayPreviewEx: proc "c" (preview: ^preview_register_t, bufflags: c.int, measure_align: f64) -> c.int
PlayTrackPreview: proc "c" (preview: ^preview_register_t) -> c.int
PlayTrackPreview2: proc "c" (proj: ^ReaProject, preview: ^preview_register_t) -> c.int
PlayTrackPreview2Ex: proc "c" (proj: ^ReaProject, preview: ^preview_register_t, flags: c.int, measure_align: f64) -> c.int
plugin_getapi: proc "c" (name: cstring) -> rawptr
plugin_getFilterList: proc "c" () -> cstring
plugin_getImportableProjectFilterList: proc "c" () -> cstring
plugin_register: proc "c" (name: cstring, infostruct: rawptr) -> c.int
PluginWantsAlwaysRunFx: proc "c" (amt: c.int)
PreventUIRefresh: proc "c" (prevent_count: c.int)
projectconfig_var_addr: proc "c" (proj: ^ReaProject, idx: c.int) -> rawptr
projectconfig_var_getoffs: proc "c" (name: cstring, szOut: ^c.int) -> c.int
PromptForAction: proc "c" (session_mode: c.int, init_id: c.int, section_id: c.int) -> c.int
realloc_cmd_ptr: proc "c" (ptr: ^cstring, ptr_size: ^c.int, new_size: c.int) -> bool
ReaperGetPitchShiftAPI: proc "c" (version: c.int) -> ^IReaperPitchShift
ReaScriptError: proc "c" (errmsg: cstring)
RecursiveCreateDirectory: proc "c" (path: cstring, ignored: c.size_t) -> c.int
reduce_open_files: proc "c" (flags: c.int) -> c.int
RefreshToolbar: proc "c" (command_id: c.int)
RefreshToolbar2: proc "c" (section_id: c.int, command_id: c.int)
relative_fn: proc "c" (input: cstring, output: cstring, out_sz: c.int)
RemoveTrackSend: proc "c" (tr: ^MediaTrack, category: c.int, sendidx: c.int) -> bool
RenderFileSection: proc "c" (source_filename: cstring, target_filename: cstring, start_percent: f64, end_percent: f64, playrate: f64) -> bool
ReorderSelectedTracks: proc "c" (beforeTrackIdx: c.int, makePrevFolder: c.int) -> bool
Resample_EnumModes: proc "c" (mode: c.int) -> cstring
Resampler_Create: proc "c" () -> ^REAPER_Resample_Interface
resolve_fn: proc "c" (input: cstring, output: cstring, out_sz: c.int)
resolve_fn2: proc "c" (input: cstring, output: cstring, out_sz: c.int, checkSubDirOptional: cstring)
ReverseNamedCommandLookup: proc "c" (command_id: c.int) -> cstring
ScaleFromEnvelopeMode: proc "c" (scaling_mode: c.int, val: f64) -> f64
ScaleToEnvelopeMode: proc "c" (scaling_mode: c.int, val: f64) -> f64
screenset_register: proc "c" (id: cstring, callbackFunc: rawptr, param: rawptr)
screenset_registerNew: proc "c" (id: cstring, callbackFunc: screensetNewCallbackFunc, param: rawptr)
screenset_unregister: proc "c" (id: cstring)
screenset_unregisterByParam: proc "c" (param: rawptr)
screenset_updateLastFocus: proc "c" (prevWin: HWND)
SectionFromUniqueID: proc "c" (uniqueID: c.int) -> ^KbdSectionInfo
SelectAllMediaItems: proc "c" (proj: ^ReaProject, selected: bool)
SelectProjectInstance: proc "c" (proj: ^ReaProject)
SendLocalOscMessage: proc "c" (local_osc_handler: rawptr, msg: cstring, msglen: c.int)
SetActiveTake: proc "c" (take: ^MediaItem_Take)
SetAutomationMode: proc "c" (mode: c.int, onlySel: bool)
SetCurrentBPM: proc "c" (__proj: ^ReaProject, bpm: f64, wantUndo: bool)
SetCursorContext: proc "c" (mode: c.int, envInOptional: ^TrackEnvelope)
SetEditCurPos: proc "c" (time: f64, moveview: bool, seekplay: bool)
SetEditCurPos2: proc "c" (proj: ^ReaProject, time: f64, moveview: bool, seekplay: bool)
SetEnvelopePoint: proc "c" (envelope: ^TrackEnvelope, ptidx: c.int, timeInOptional: ^f64, valueInOptional: ^f64, shapeInOptional: ^c.int, tensionInOptional: ^f64, selectedInOptional: ^bool, noSortInOptional: ^bool) -> bool
SetEnvelopePointEx: proc "c" (envelope: ^TrackEnvelope, autoitem_idx: c.int, ptidx: c.int, timeInOptional: ^f64, valueInOptional: ^f64, shapeInOptional: ^c.int, tensionInOptional: ^f64, selectedInOptional: ^bool, noSortInOptional: ^bool) -> bool
SetEnvelopeStateChunk: proc "c" (env: ^TrackEnvelope, str: cstring, isundoOptional: bool) -> bool
SetExtState: proc "c" (section: cstring, key: cstring, value: cstring, persist: bool)
SetGlobalAutomationOverride: proc "c" (mode: c.int)
SetItemStateChunk: proc "c" (item: ^MediaItem, str: cstring, isundoOptional: bool) -> bool
SetMasterTrackVisibility: proc "c" (flag: c.int) -> c.int
SetMediaItemInfo_Value: proc "c" (item: ^MediaItem, parmname: cstring, newvalue: f64) -> bool
SetMediaItemLength: proc "c" (item: ^MediaItem, length: f64, refreshUI: bool) -> bool
SetMediaItemPosition: proc "c" (item: ^MediaItem, position: f64, refreshUI: bool) -> bool
SetMediaItemSelected: proc "c" (item: ^MediaItem, selected: bool)
SetMediaItemTake_Source: proc "c" (take: ^MediaItem_Take, source: ^PCM_source) -> bool
SetMediaItemTakeInfo_Value: proc "c" (take: ^MediaItem_Take, parmname: cstring, newvalue: f64) -> bool
SetMediaTrackInfo_Value: proc "c" (tr: ^MediaTrack, parmname: cstring, newvalue: f64) -> bool
SetMIDIEditorGrid: proc "c" (project: ^ReaProject, division: f64)
SetMixerScroll: proc "c" (leftmosttrack: ^MediaTrack) -> ^MediaTrack
SetMouseModifier: proc "c" (ctx: cstring, modifier_flag: c.int, action: cstring)
SetOnlyTrackSelected: proc "c" (track: ^MediaTrack)
SetProjectGrid: proc "c" (project: ^ReaProject, division: f64)
SetProjectMarker: proc "c" (markrgnindexnumber: c.int, isrgn: bool, pos: f64, rgnend: f64, name: cstring) -> bool
SetProjectMarker2: proc "c" (proj: ^ReaProject, markrgnindexnumber: c.int, isrgn: bool, pos: f64, rgnend: f64, name: cstring) -> bool
SetProjectMarker3: proc "c" (proj: ^ReaProject, markrgnindexnumber: c.int, isrgn: bool, pos: f64, rgnend: f64, name: cstring, color: c.int) -> bool
SetProjectMarker4: proc "c" (proj: ^ReaProject, markrgnindexnumber: c.int, isrgn: bool, pos: f64, rgnend: f64, name: cstring, color: c.int, flags: c.int) -> bool
SetProjectMarkerByIndex: proc "c" (proj: ^ReaProject, markrgnidx: c.int, isrgn: bool, pos: f64, rgnend: f64, IDnumber: c.int, name: cstring, color: c.int) -> bool
SetProjectMarkerByIndex2: proc "c" (proj: ^ReaProject, markrgnidx: c.int, isrgn: bool, pos: f64, rgnend: f64, IDnumber: c.int, name: cstring, color: c.int, flags: c.int) -> bool
SetProjExtState: proc "c" (proj: ^ReaProject, extname: cstring, key: cstring, value: cstring) -> c.int
SetRegionRenderMatrix: proc "c" (proj: ^ReaProject, regionindex: c.int, track: ^MediaTrack, addorremove: c.int)
SetRenderLastError: proc "c" (errorstr: cstring)
SetTakeMarker: proc "c" (take: ^MediaItem_Take, idx: c.int, nameIn: cstring, srcposInOptional: ^f64, colorInOptional: ^c.int) -> c.int
SetTakeStretchMarker: proc "c" (take: ^MediaItem_Take, idx: c.int, pos: f64, srcposInOptional: ^f64) -> c.int
SetTakeStretchMarkerSlope: proc "c" (take: ^MediaItem_Take, idx: c.int, slope: f64) -> bool
SetTempoTimeSigMarker: proc "c" (proj: ^ReaProject, ptidx: c.int, timepos: f64, measurepos: c.int, beatpos: f64, bpm: f64, timesig_num: c.int, timesig_denom: c.int, lineartempo: bool) -> bool
SetThemeColor: proc "c" (ini_key: cstring, color: c.int, flagsOptional: c.int) -> c.int
SetToggleCommandState: proc "c" (section_id: c.int, command_id: c.int, state: c.int) -> bool
SetTrackAutomationMode: proc "c" (tr: ^MediaTrack, mode: c.int)
SetTrackColor: proc "c" (track: ^MediaTrack, color: c.int)
SetTrackMIDILyrics: proc "c" (track: ^MediaTrack, flag: c.int, str: cstring) -> bool
SetTrackMIDINoteName: proc "c" (track: c.int, pitch: c.int, chan: c.int, name: cstring) -> bool
SetTrackMIDINoteNameEx: proc "c" (proj: ^ReaProject, track: ^MediaTrack, pitch: c.int, chan: c.int, name: cstring) -> bool
SetTrackSelected: proc "c" (track: ^MediaTrack, selected: bool)
SetTrackSendInfo_Value: proc "c" (tr: ^MediaTrack, category: c.int, sendidx: c.int, parmname: cstring, newvalue: f64) -> bool
SetTrackSendUIPan: proc "c" (track: ^MediaTrack, send_idx: c.int, pan: f64, isend: c.int) -> bool
SetTrackSendUIVol: proc "c" (track: ^MediaTrack, send_idx: c.int, vol: f64, isend: c.int) -> bool
SetTrackStateChunk: proc "c" (track: ^MediaTrack, str: cstring, isundoOptional: bool) -> bool
ShowActionList: proc "c" (caller: ^KbdSectionInfo, callerWnd: HWND)
ShowConsoleMsg: proc "c" (msg: cstring)
ShowMessageBox: proc "c" (msg: cstring, title: cstring, type: c.int) -> c.int
ShowPopupMenu: proc "c" (name: cstring, x: c.int, y: c.int, hwndParentOptional: HWND, ctxOptional: rawptr, ctx2Optional: c.int, ctx3Optional: c.int)
SLIDER2DB: proc "c" (y: f64) -> f64
SnapToGrid: proc "c" (project: ^ReaProject, time_pos: f64) -> f64
SoloAllTracks: proc "c" (solo: c.int)
Splash_GetWnd: proc "c" () -> HWND
SplitMediaItem: proc "c" (item: ^MediaItem, position: f64) -> ^MediaItem
StopPreview: proc "c" (preview: ^preview_register_t) -> c.int
StopTrackPreview: proc "c" (preview: ^preview_register_t) -> c.int
StopTrackPreview2: proc "c" (proj: rawptr, preview: ^preview_register_t) -> c.int
stringToGuid: proc "c" (str: cstring, g: ^GUID)
StuffMIDIMessage: proc "c" (mode: c.int, msg1: c.int, msg2: c.int, msg3: c.int)
TakeFX_AddByName: proc "c" (take: ^MediaItem_Take, fxname: cstring, instantiate: c.int) -> c.int
TakeFX_CopyToTake: proc "c" (src_take: ^MediaItem_Take, src_fx: c.int, dest_take: ^MediaItem_Take, dest_fx: c.int, is_move: bool)
TakeFX_CopyToTrack: proc "c" (src_take: ^MediaItem_Take, src_fx: c.int, dest_track: ^MediaTrack, dest_fx: c.int, is_move: bool)
TakeFX_Delete: proc "c" (take: ^MediaItem_Take, fx: c.int) -> bool
TakeFX_EndParamEdit: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int) -> bool
TakeFX_FormatParamValue: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, val: f64, buf: cstring, buf_sz: c.int) -> bool
TakeFX_FormatParamValueNormalized: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, value: f64, buf: cstring, buf_sz: c.int) -> bool
TakeFX_GetChainVisible: proc "c" (take: ^MediaItem_Take) -> c.int
TakeFX_GetCount: proc "c" (take: ^MediaItem_Take) -> c.int
TakeFX_GetEnabled: proc "c" (take: ^MediaItem_Take, fx: c.int) -> bool
TakeFX_GetEnvelope: proc "c" (take: ^MediaItem_Take, fxindex: c.int, parameterindex: c.int, create: bool) -> ^TrackEnvelope
TakeFX_GetFloatingWindow: proc "c" (take: ^MediaItem_Take, index: c.int) -> HWND
TakeFX_GetFormattedParamValue: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, buf: cstring, buf_sz: c.int) -> bool
TakeFX_GetFXGUID: proc "c" (take: ^MediaItem_Take, fx: c.int) -> ^GUID
TakeFX_GetFXName: proc "c" (take: ^MediaItem_Take, fx: c.int, buf: cstring, buf_sz: c.int) -> bool
TakeFX_GetIOSize: proc "c" (take: ^MediaItem_Take, fx: c.int, inputPinsOutOptional: ^c.int, outputPinsOutOptional: ^c.int) -> c.int
TakeFX_GetNamedConfigParm: proc "c" (take: ^MediaItem_Take, fx: c.int, parmname: cstring, bufOut: cstring, bufOut_sz: c.int) -> bool
TakeFX_GetNumParams: proc "c" (take: ^MediaItem_Take, fx: c.int) -> c.int
TakeFX_GetOffline: proc "c" (take: ^MediaItem_Take, fx: c.int) -> bool
TakeFX_GetOpen: proc "c" (take: ^MediaItem_Take, fx: c.int) -> bool
TakeFX_GetParam: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, minvalOut: ^f64, maxvalOut: ^f64) -> f64
TakeFX_GetParameterStepSizes: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, stepOut: ^f64, smallstepOut: ^f64, largestepOut: ^f64, istoggleOut: ^bool) -> bool
TakeFX_GetParamEx: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, minvalOut: ^f64, maxvalOut: ^f64, midvalOut: ^f64) -> f64
TakeFX_GetParamName: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, buf: cstring, buf_sz: c.int) -> bool
TakeFX_GetParamNormalized: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int) -> f64
TakeFX_GetPinMappings: proc "c" (tr: ^MediaItem_Take, fx: c.int, isoutput: c.int, pin: c.int, high32OutOptional: ^c.int) -> c.int
TakeFX_GetPreset: proc "c" (take: ^MediaItem_Take, fx: c.int, presetname: cstring, presetname_sz: c.int) -> bool
TakeFX_GetPresetIndex: proc "c" (take: ^MediaItem_Take, fx: c.int,numberOfPresetsOut: ^c.int) -> c.int
TakeFX_GetUserPresetFilename: proc "c" (take: ^MediaItem_Take, fx: c.int, fn: cstring, fn_sz: c.int)
TakeFX_NavigatePresets: proc "c" (take: ^MediaItem_Take, fx: c.int, presetmove: c.int) -> bool
TakeFX_SetEnabled: proc "c" (take: ^MediaItem_Take, fx: c.int, enabled: bool)
TakeFX_SetNamedConfigParm: proc "c" (take: ^MediaItem_Take, fx: c.int, parmname: cstring, value: cstring) -> bool
TakeFX_SetOffline: proc "c" (take: ^MediaItem_Take, fx: c.int, offline: bool)
TakeFX_SetOpen: proc "c" (take: ^MediaItem_Take, fx: c.int, open: bool)
TakeFX_SetParam: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, val: f64) -> bool
TakeFX_SetParamNormalized: proc "c" (take: ^MediaItem_Take, fx: c.int, param: c.int, value: f64) -> bool
TakeFX_SetPinMappings: proc "c" (tr: ^MediaItem_Take, fx: c.int, isoutput: c.int, pin: c.int, low32bits: c.int, hi32bits: c.int) -> bool
TakeFX_SetPreset: proc "c" (take: ^MediaItem_Take, fx: c.int, presetname: cstring) -> bool
TakeFX_SetPresetByIndex: proc "c" (take: ^MediaItem_Take, fx: c.int, idx: c.int) -> bool
TakeFX_Show: proc "c" (take: ^MediaItem_Take, index: c.int, showFlag: c.int)
TakeIsMIDI: proc "c" (take: ^MediaItem_Take) -> bool
ThemeLayout_GetLayout: proc "c" (section: cstring, idx: c.int, nameOut: cstring, nameOut_sz: c.int) -> bool
ThemeLayout_GetParameter: proc "c" (wp: c.int, descOutOptional: ^cstring, valueOutOptional: ^c.int, defValueOutOptional: ^c.int, minValueOutOptional: ^c.int, maxValueOutOptional: ^c.int) -> cstring
ThemeLayout_RefreshAll: proc "c" ()
ThemeLayout_SetLayout: proc "c" (section: cstring, layout: cstring) -> bool
ThemeLayout_SetParameter: proc "c" (wp: c.int, value: c.int, persist: bool) -> bool
time_precise: proc "c" () -> f64
TimeMap2_beatsToTime: proc "c" (proj: ^ReaProject, tpos: f64, measuresInOptional: ^c.int) -> f64
TimeMap2_GetDividedBpmAtTime: proc "c" (proj: ^ReaProject, time: f64) -> f64
TimeMap2_GetNextChangeTime: proc "c" (proj: ^ReaProject, time: f64) -> f64
TimeMap2_QNToTime: proc "c" (proj: ^ReaProject, qn: f64) -> f64
TimeMap2_timeToBeats: proc "c" (proj: ^ReaProject, tpos: f64, measuresOutOptional: ^c.int, cmlOutOptional: ^c.int, fullbeatsOutOptional: ^f64, cdenomOutOptional: ^c.int) -> f64
TimeMap2_timeToQN: proc "c" (proj: ^ReaProject, tpos: f64) -> f64
TimeMap_curFrameRate: proc "c" (proj: ^ReaProject, dropFrameOutOptional: ^bool) -> f64
TimeMap_GetDividedBpmAtTime: proc "c" (time: f64) -> f64
TimeMap_GetMeasureInfo: proc "c" (proj: ^ReaProject, measure: c.int, qn_startOut: ^f64, qn_endOut: ^f64, timesig_numOut: ^c.int, timesig_denomOut: ^c.int, tempoOut: ^f64) -> f64
TimeMap_GetMetronomePattern: proc "c" (proj: ^ReaProject, time: f64, pattern: cstring, pattern_sz: c.int) -> c.int
TimeMap_GetTimeSigAtTime: proc "c" (proj: ^ReaProject, time: f64, timesig_numOut: ^c.int, timesig_denomOut: ^c.int, tempoOut: ^f64)
TimeMap_QNToMeasures: proc "c" (proj: ^ReaProject, qn: f64, qnMeasureStartOutOptional: ^f64, qnMeasureEndOutOptional: ^f64) -> c.int
TimeMap_QNToTime: proc "c" (qn: f64) -> f64
TimeMap_QNToTime_abs: proc "c" (proj: ^ReaProject, qn: f64) -> f64
TimeMap_timeToQN: proc "c" (tpos: f64) -> f64
TimeMap_timeToQN_abs: proc "c" (proj: ^ReaProject, tpos: f64) -> f64
ToggleTrackSendUIMute: proc "c" (track: ^MediaTrack, send_idx: c.int) -> bool
Track_GetPeakHoldDB: proc "c" (track: ^MediaTrack, channel: c.int, clear: bool) -> f64
Track_GetPeakInfo: proc "c" (track: ^MediaTrack, channel: c.int) -> f64
TrackCtl_SetToolTip: proc "c" (fmt: cstring, xpos: c.int, ypos: c.int, topmost: bool)
TrackFX_AddByName: proc "c" (track: ^MediaTrack, fxname: cstring, recFX: bool, instantiate: c.int) -> c.int
TrackFX_CopyToTake: proc "c" (src_track: ^MediaTrack, src_fx: c.int, dest_take: ^MediaItem_Take, dest_fx: c.int, is_move: bool)
TrackFX_CopyToTrack: proc "c" (src_track: ^MediaTrack, src_fx: c.int, dest_track: ^MediaTrack, dest_fx: c.int, is_move: bool)
TrackFX_Delete: proc "c" (track: ^MediaTrack, fx: c.int) -> bool
TrackFX_EndParamEdit: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int) -> bool
TrackFX_FormatParamValue: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, val: f64, buf: cstring, buf_sz: c.int) -> bool
TrackFX_FormatParamValueNormalized: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, value: f64, buf: cstring, buf_sz: c.int) -> bool
TrackFX_GetByName: proc "c" (track: ^MediaTrack, fxname: cstring, instantiate: bool) -> c.int
TrackFX_GetChainVisible: proc "c" (track: ^MediaTrack) -> c.int
TrackFX_GetCount: proc "c" (track: ^MediaTrack) -> c.int
TrackFX_GetEnabled: proc "c" (track: ^MediaTrack, fx: c.int) -> bool
TrackFX_GetEQ: proc "c" (track: ^MediaTrack, instantiate: bool) -> c.int
TrackFX_GetEQBandEnabled: proc "c" (track: ^MediaTrack, fxidx: c.int, bandtype: c.int, bandidx: c.int) -> bool
TrackFX_GetEQParam: proc "c" (track: ^MediaTrack, fxidx: c.int, paramidx: c.int, bandtypeOut: ^c.int, bandidxOut: ^c.int, paramtypeOut: ^c.int, normvalOut: ^f64) -> bool
TrackFX_GetFloatingWindow: proc "c" (track: ^MediaTrack, index: c.int) -> HWND
TrackFX_GetFormattedParamValue: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, buf: cstring, buf_sz: c.int) -> bool
TrackFX_GetFXGUID: proc "c" (track: ^MediaTrack, fx: c.int) -> ^GUID
TrackFX_GetFXName: proc "c" (track: ^MediaTrack, fx: c.int, buf: cstring, buf_sz: c.int) -> bool
TrackFX_GetInstrument: proc "c" (track: ^MediaTrack) -> c.int
TrackFX_GetIOSize: proc "c" (track: ^MediaTrack, fx: c.int, inputPinsOutOptional: ^c.int, outputPinsOutOptional: ^c.int) -> c.int
TrackFX_GetNamedConfigParm: proc "c" (track: ^MediaTrack, fx: c.int, parmname: cstring, bufOut: cstring, bufOut_sz: c.int) -> bool
TrackFX_GetNumParams: proc "c" (track: ^MediaTrack, fx: c.int) -> c.int
TrackFX_GetOffline: proc "c" (track: ^MediaTrack, fx: c.int) -> bool
TrackFX_GetOpen: proc "c" (track: ^MediaTrack, fx: c.int) -> bool
TrackFX_GetParam: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, minvalOut: ^f64, maxvalOut: ^f64) -> f64
TrackFX_GetParameterStepSizes: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, stepOut: ^f64, smallstepOut: ^f64, largestepOut: ^f64, istoggleOut: ^bool) -> bool
TrackFX_GetParamEx: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, minvalOut: ^f64, maxvalOut: ^f64, midvalOut: ^f64) -> f64
TrackFX_GetParamName: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, buf: cstring, buf_sz: c.int) -> bool
TrackFX_GetParamNormalized: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int) -> f64
TrackFX_GetPinMappings: proc "c" (tr: ^MediaTrack, fx: c.int, isoutput: c.int, pin: c.int, high32OutOptional: ^c.int) -> c.int
TrackFX_GetPreset: proc "c" (track: ^MediaTrack, fx: c.int, presetname: cstring, presetname_sz: c.int) -> bool
TrackFX_GetPresetIndex: proc "c" (track: ^MediaTrack, fx: c.int, numberOfPresetsOut: ^c.int) -> c.int
TrackFX_GetRecChainVisible: proc "c" (track: ^MediaTrack) -> c.int
TrackFX_GetRecCount: proc "c" (track: ^MediaTrack) -> c.int
TrackFX_GetUserPresetFilename: proc "c" (track: ^MediaTrack, fx: c.int, fn: cstring, fn_sz: c.int)
TrackFX_NavigatePresets: proc "c" (track: ^MediaTrack, fx: c.int, presetmove: c.int) -> bool
TrackFX_SetEnabled: proc "c" (track: ^MediaTrack, fx: c.int, enabled: bool)
TrackFX_SetEQBandEnabled: proc "c" (track: ^MediaTrack, fxidx: c.int, bandtype: c.int, bandidx: c.int, enable: bool) -> bool
TrackFX_SetEQParam: proc "c" (track: ^MediaTrack, fxidx: c.int, bandtype: c.int, bandidx: c.int, paramtype: c.int, val: f64, isnorm: bool) -> bool
TrackFX_SetNamedConfigParm: proc "c" (track: ^MediaTrack, fx: c.int, parmname: cstring, value: cstring) -> bool
TrackFX_SetOffline: proc "c" (track: ^MediaTrack, fx: c.int, offline: bool)
TrackFX_SetOpen: proc "c" (track: ^MediaTrack, fx: c.int, open: bool)
TrackFX_SetParam: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, val: f64) -> bool
TrackFX_SetParamNormalized: proc "c" (track: ^MediaTrack, fx: c.int, param: c.int, value: f64) -> bool
TrackFX_SetPinMappings: proc "c" (tr: ^MediaTrack, fx: c.int, isoutput: c.int, pin: c.int, low32bits: c.int, hi32bits: c.int) -> bool
TrackFX_SetPreset: proc "c" (track: ^MediaTrack, fx: c.int, presetname: cstring) -> bool
TrackFX_SetPresetByIndex: proc "c" (track: ^MediaTrack, fx: c.int, idx: c.int) -> bool
TrackFX_Show: proc "c" (track: ^MediaTrack, index: c.int, showFlag: c.int)
TrackList_AdjustWindows: proc "c" (isMinor: bool)
TrackList_UpdateAllExternalSurfaces: proc "c" ()
Undo_BeginBlock: proc "c" ()
Undo_BeginBlock2: proc "c" (proj: ^ReaProject)
Undo_CanRedo2: proc "c" (proj: ^ReaProject) -> cstring
Undo_CanUndo2: proc "c" (proj: ^ReaProject) -> cstring
Undo_DoRedo2: proc "c" (proj: ^ReaProject) -> c.int
Undo_DoUndo2: proc "c" (proj: ^ReaProject) -> c.int
Undo_EndBlock: proc "c" (descchange: cstring, extraflags: c.int)
Undo_EndBlock2: proc "c" (proj: ^ReaProject, descchange: cstring, extraflags: c.int)
Undo_OnStateChange: proc "c" (descchange: cstring)
Undo_OnStateChange2: proc "c" (proj: ^ReaProject, descchange: cstring)
Undo_OnStateChange_Item: proc "c" (proj: ^ReaProject, name: cstring, item: ^MediaItem)
Undo_OnStateChangeEx: proc "c" (descchange: cstring, whichStates: c.int, trackparm: c.int)
Undo_OnStateChangeEx2: proc "c" (proj: ^ReaProject, descchange: cstring, whichStates: c.int, trackparm: c.int)
update_disk_counters: proc "c" (readamt: c.int, writeamt: c.int)
UpdateArrange: proc "c" ()
UpdateItemInProject: proc "c" (item: ^MediaItem)
UpdateTimeline: proc "c" ()
ValidatePtr: proc "c" (pointer: rawptr, ctypename: cstring) -> bool
ValidatePtr2: proc "c" (proj: ^ReaProject, pointer: rawptr, ctypename: cstring) -> bool
ViewPrefs: proc "c" (page: c.int, pageByName: cstring)
WDL_VirtualWnd_ScaledBlitBG: proc "c" (dest: ^LICE_IBitmap, src: ^WDL_VirtualWnd_BGCfg, destx: c.int, desty: c.int, destw: c.int, desth: c.int, clipx: c.int, clipy: c.int, clipw: c.int, cliph: c.int, alpha: f32, mode: c.int) -> bool
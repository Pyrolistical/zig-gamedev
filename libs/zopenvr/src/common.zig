const std = @import("std");

pub const InitError = error{
    None,
    Unknown,
    InitInstallationNotFound,
    InitInstallationCorrupt,
    InitVRClientDLLNotFound,
    InitFileNotFound,
    InitFactoryNotFound,
    InitInterfaceNotFound,
    InitInvalidInterface,
    InitUserConfigDirectoryInvalid,
    InitHmdNotFound,
    InitNotInitialized,
    InitPathRegistryNotFound,
    InitNoConfigPath,
    InitNoLogPath,
    InitPathRegistryNotWritable,
    InitAppInfoInitFailed,
    InitRetry,
    InitInitCanceledByUser,
    InitAnotherAppLaunching,
    InitSettingsInitFailed,
    InitShuttingDown,
    InitTooManyObjects,
    InitNoServerForBackgroundApp,
    InitNotSupportedWithCompositor,
    InitNotAvailableToUtilityApps,
    InitInternal,
    InitHmdDriverIdIsNone,
    InitHmdNotFoundPresenceFailed,
    InitVRMonitorNotFound,
    InitVRMonitorStartupFailed,
    InitLowPowerWatchdogNotSupported,
    InitInvalidApplicationType,
    InitNotAvailableToWatchdogApps,
    InitWatchdogDisabledInSettings,
    InitVRDashboardNotFound,
    InitVRDashboardStartupFailed,
    InitVRHomeNotFound,
    InitVRHomeStartupFailed,
    InitRebootingBusy,
    InitFirmwareUpdateBusy,
    InitFirmwareRecoveryBusy,
    InitUSBServiceBusy,
    InitVRWebHelperStartupFailed,
    InitTrackerManagerInitFailed,
    InitAlreadyRunning,
    InitFailedForVrMonitor,
    InitPropertyManagerInitFailed,
    InitWebServerFailed,
    InitIllegalTypeTransition,
    InitMismatchedRuntimes,
    InitInvalidProcessId,
    InitVRServiceStartupFailed,
    InitPrismNeedsNewDrivers,
    InitPrismStartupTimedOut,
    InitCouldNotStartPrism,
    InitPrismClientInitFailed,
    InitPrismClientStartFailed,
    InitPrismExitedUnexpectedly,
    InitBadLuid,
    InitNoServerForAppContainer,
    InitDuplicateBootstrapper,
    InitVRDashboardServicePending,
    InitVRDashboardServiceTimeout,
    InitVRDashboardServiceStopped,
    InitVRDashboardAlreadyStarted,
    InitVRDashboardCopyFailed,
    InitVRDashboardTokenFailure,
    InitVRDashboardEnvironmentFailure,
    InitVRDashboardPathFailure,
    DriverFailed,
    DriverUnknown,
    DriverHmdUnknown,
    DriverNotLoaded,
    DriverRuntimeOutOfDate,
    DriverHmdInUse,
    DriverNotCalibrated,
    DriverCalibrationInvalid,
    DriverHmdDisplayNotFound,
    DriverTrackedDeviceInterfaceUnknown,
    DriverHmdDriverIdOutOfBounds,
    DriverHmdDisplayMirrored,
    DriverHmdDisplayNotFoundLaptop,
    DriverPeerDriverNotInstalled,
    DriverWirelessHmdNotConnected,
    IPCServerInitFailed,
    IPCConnectFailed,
    IPCSharedStateInitFailed,
    IPCCompositorInitFailed,
    IPCMutexInitFailed,
    IPCFailed,
    IPCCompositorConnectFailed,
    IPCCompositorInvalidConnectResponse,
    IPCConnectFailedAfterMultipleAttempts,
    IPCConnectFailedAfterTargetExited,
    IPCNamespaceUnavailable,
    CompositorFailed,
    CompositorD3D11HardwareRequired,
    CompositorFirmwareRequiresUpdate,
    CompositorOverlayInitFailed,
    CompositorScreenshotsInitFailed,
    CompositorUnableToCreateDevice,
    CompositorSharedStateIsNull,
    CompositorNotificationManagerIsNull,
    CompositorResourceManagerClientIsNull,
    CompositorMessageOverlaySharedStateInitFailure,
    CompositorPropertiesInterfaceIsNull,
    CompositorCreateFullscreenWindowFailed,
    CompositorSettingsInterfaceIsNull,
    CompositorFailedToShowWindow,
    CompositorDistortInterfaceIsNull,
    CompositorDisplayFrequencyFailure,
    CompositorRendererInitializationFailed,
    CompositorDXGIFactoryInterfaceIsNull,
    CompositorDXGIFactoryCreateFailed,
    CompositorDXGIFactoryQueryFailed,
    CompositorInvalidAdapterDesktop,
    CompositorInvalidHmdAttachment,
    CompositorInvalidOutputDesktop,
    CompositorInvalidDeviceProvided,
    CompositorD3D11RendererInitializationFailed,
    CompositorFailedToFindDisplayMode,
    CompositorFailedToCreateSwapChain,
    CompositorFailedToGetBackBuffer,
    CompositorFailedToCreateRenderTarget,
    CompositorFailedToCreateDXGI2SwapChain,
    CompositorFailedtoGetDXGI2BackBuffer,
    CompositorFailedToCreateDXGI2RenderTarget,
    CompositorFailedToGetDXGIDeviceInterface,
    CompositorSelectDisplayMode,
    CompositorFailedToCreateNvAPIRenderTargets,
    CompositorNvAPISetDisplayMode,
    CompositorFailedToCreateDirectModeDisplay,
    CompositorInvalidHmdPropertyContainer,
    CompositorUpdateDisplayFrequency,
    CompositorCreateRasterizerState,
    CompositorCreateWireframeRasterizerState,
    CompositorCreateSamplerState,
    CompositorCreateClampToBorderSamplerState,
    CompositorCreateAnisoSamplerState,
    CompositorCreateOverlaySamplerState,
    CompositorCreatePanoramaSamplerState,
    CompositorCreateFontSamplerState,
    CompositorCreateNoBlendState,
    CompositorCreateBlendState,
    CompositorCreateAlphaBlendState,
    CompositorCreateBlendStateMaskR,
    CompositorCreateBlendStateMaskG,
    CompositorCreateBlendStateMaskB,
    CompositorCreateDepthStencilState,
    CompositorCreateDepthStencilStateNoWrite,
    CompositorCreateDepthStencilStateNoDepth,
    CompositorCreateFlushTexture,
    CompositorCreateDistortionSurfaces,
    CompositorCreateConstantBuffer,
    CompositorCreateHmdPoseConstantBuffer,
    CompositorCreateHmdPoseStagingConstantBuffer,
    CompositorCreateSharedFrameInfoConstantBuffer,
    CompositorCreateOverlayConstantBuffer,
    CompositorCreateSceneTextureIndexConstantBuffer,
    CompositorCreateReadableSceneTextureIndexConstantBuffer,
    CompositorCreateLayerGraphicsTextureIndexConstantBuffer,
    CompositorCreateLayerComputeTextureIndexConstantBuffer,
    CompositorCreateLayerComputeSceneTextureIndexConstantBuffer,
    CompositorCreateComputeHmdPoseConstantBuffer,
    CompositorCreateGeomConstantBuffer,
    CompositorCreatePanelMaskConstantBuffer,
    CompositorCreatePixelSimUBO,
    CompositorCreateMSAARenderTextures,
    CompositorCreateResolveRenderTextures,
    CompositorCreateComputeResolveRenderTextures,
    CompositorCreateDriverDirectModeResolveTextures,
    CompositorOpenDriverDirectModeResolveTextures,
    CompositorCreateFallbackSyncTexture,
    CompositorShareFallbackSyncTexture,
    CompositorCreateOverlayIndexBuffer,
    CompositorCreateOverlayVertexBuffer,
    CompositorCreateTextVertexBuffer,
    CompositorCreateTextIndexBuffer,
    CompositorCreateMirrorTextures,
    CompositorCreateLastFrameRenderTexture,
    CompositorCreateMirrorOverlay,
    CompositorFailedToCreateVirtualDisplayBackbuffer,
    CompositorDisplayModeNotSupported,
    CompositorCreateOverlayInvalidCall,
    CompositorCreateOverlayAlreadyInitialized,
    CompositorFailedToCreateMailbox,
    CompositorWindowInterfaceIsNull,
    CompositorSystemLayerCreateInstance,
    CompositorSystemLayerCreateSession,
    CompositorCreateInverseDistortUVs,
    CompositorCreateBackbufferDepth,
    CompositorCannotDRMLeaseDisplay,
    CompositorCannotConnectToDisplayServer,
    CompositorGnomeNoDRMLeasing,
    CompositorFailedToInitializeEncoder,
    CompositorCreateBlurTexture,
    VendorSpecificUnableToConnectToOculusRuntime,
    VendorSpecificWindowsNotInDevMode,
    VendorSpecificOculusLinkNotEnabled,
    VendorSpecificHmdFoundCantOpenDevice,
    VendorSpecificHmdFoundUnableToRequestConfigStart,
    VendorSpecificHmdFoundNoStoredConfig,
    VendorSpecificHmdFoundConfigTooBig,
    VendorSpecificHmdFoundConfigTooSmall,
    VendorSpecificHmdFoundUnableToInitZLib,
    VendorSpecificHmdFoundCantReadFirmwareVersion,
    VendorSpecificHmdFoundUnableToSendUserDataStart,
    VendorSpecificHmdFoundUnableToGetUserDataStart,
    VendorSpecificHmdFoundUnableToGetUserDataNext,
    VendorSpecificHmdFoundUserDataAddressRange,
    VendorSpecificHmdFoundUserDataError,
    VendorSpecificHmdFoundConfigFailedSanityCheck,
    VendorSpecificOculusRuntimeBadInstall,
    VendorSpecificHmdFoundUnexpectedConfiguration1,
    SteamInstallationNotFound,
    LastError,
};

pub const InitErrorCode = enum(i32) {
    none = 0,
    unknown = 1,
    init_installation_not_found = 100,
    init_installation_corrupt = 101,
    init_vr_client_dll_not_found = 102,
    init_file_not_found = 103,
    init_factory_not_found = 104,
    init_interface_not_found = 105,
    init_invalid_interface = 106,
    init_user_config_directory_invalid = 107,
    init_hmd_not_found = 108,
    init_not_initialized = 109,
    init_path_registry_not_found = 110,
    init_no_config_path = 111,
    init_no_log_path = 112,
    init_path_registry_not_writable = 113,
    init_app_info_init_failed = 114,
    init_retry = 115,
    init_init_canceled_by_user = 116,
    init_another_app_launching = 117,
    init_settings_init_failed = 118,
    init_shutting_down = 119,
    init_too_many_objects = 120,
    init_no_server_for_background_app = 121,
    init_not_supported_with_compositor = 122,
    init_not_available_to_utility_apps = 123,
    init_internal = 124,
    init_hmd_driver_id_is_none = 125,
    init_hmd_not_found_presence_failed = 126,
    init_vr_monitor_not_found = 127,
    init_vr_monitor_startup_failed = 128,
    init_low_power_watchdog_not_supported = 129,
    init_invalid_application_type = 130,
    init_not_available_to_watchdog_apps = 131,
    init_watchdog_disabled_in_settings = 132,
    init_vr_dashboard_not_found = 133,
    init_vr_dashboard_startup_failed = 134,
    init_vr_home_not_found = 135,
    init_vr_home_startup_failed = 136,
    init_rebooting_busy = 137,
    init_firmware_update_busy = 138,
    init_firmware_recovery_busy = 139,
    init_usb_service_busy = 140,
    init_vr_web_helper_startup_failed = 141,
    init_tracker_manager_init_failed = 142,
    init_already_running = 143,
    init_failed_for_vr_monitor = 144,
    init_property_manager_init_failed = 145,
    init_web_server_failed = 146,
    init_illegal_type_transition = 147,
    init_mismatched_runtimes = 148,
    init_invalid_process_id = 149,
    init_vr_service_startup_failed = 150,
    init_prism_needs_new_drivers = 151,
    init_prism_startup_timed_out = 152,
    init_could_not_start_prism = 153,
    init_prism_client_init_failed = 154,
    init_prism_client_start_failed = 155,
    init_prism_exited_unexpectedly = 156,
    init_bad_luid = 157,
    init_no_server_for_app_container = 158,
    init_duplicate_bootstrapper = 159,
    init_vr_dashboard_service_pending = 160,
    init_vr_dashboard_service_timeout = 161,
    init_vr_dashboard_service_stopped = 162,
    init_vr_dashboard_already_started = 163,
    init_vr_dashboard_copy_failed = 164,
    init_vr_dashboard_token_failure = 165,
    init_vr_dashboard_environment_failure = 166,
    init_vr_dashboard_path_failure = 167,
    driver_failed = 200,
    driver_unknown = 201,
    driver_hmd_unknown = 202,
    driver_not_loaded = 203,
    driver_runtime_out_of_date = 204,
    driver_hmd_in_use = 205,
    driver_not_calibrated = 206,
    driver_calibration_invalid = 207,
    driver_hmd_display_not_found = 208,
    driver_tracked_device_interface_unknown = 209,
    driver_hmd_driver_id_out_of_bounds = 211,
    driver_hmd_display_mirrored = 212,
    driver_hmd_display_not_found_laptop = 213,
    driver_peer_driver_not_installed = 214,
    driver_wireless_hmd_not_connected = 215,
    ipc_server_init_failed = 300,
    ipc_connect_failed = 301,
    ipc_shared_state_init_failed = 302,
    ipc_compositor_init_failed = 303,
    ipc_mutex_init_failed = 304,
    ipc_failed = 305,
    ipc_compositor_connect_failed = 306,
    ipc_compositor_invalid_connect_response = 307,
    ipc_connect_failed_after_multiple_attempts = 308,
    ipc_connect_failed_after_target_exited = 309,
    ipc_namespace_unavailable = 310,
    compositor_failed = 400,
    compositor_d3d11_hardware_required = 401,
    compositor_firmware_requires_update = 402,
    compositor_overlay_init_failed = 403,
    compositor_screenshots_init_failed = 404,
    compositor_unable_to_create_device = 405,
    compositor_shared_state_is_null = 406,
    compositor_notification_manager_is_null = 407,
    compositor_resource_manager_client_is_null = 408,
    compositor_message_overlay_shared_state_init_failure = 409,
    compositor_properties_interface_is_null = 410,
    compositor_create_fullscreen_window_failed = 411,
    compositor_settings_interface_is_null = 412,
    compositor_failed_to_show_window = 413,
    compositor_distort_interface_is_null = 414,
    compositor_display_frequency_failure = 415,
    compositor_renderer_initialization_failed = 416,
    compositor_dxgi_factory_interface_is_null = 417,
    compositor_dxgi_factory_create_failed = 418,
    compositor_dxgi_factory_query_failed = 419,
    compositor_invalid_adapter_desktop = 420,
    compositor_invalid_hmd_attachment = 421,
    compositor_invalid_output_desktop = 422,
    compositor_invalid_device_provided = 423,
    compositor_d3d11_renderer_initialization_failed = 424,
    compositor_failed_to_find_display_mode = 425,
    compositor_failed_to_create_swap_chain = 426,
    compositor_failed_to_get_back_buffer = 427,
    compositor_failed_to_create_render_target = 428,
    compositor_failed_to_create_dxgi2_swap_chain = 429,
    compositor_failedto_get_dxgi2_back_buffer = 430,
    compositor_failed_to_create_dxgi2_render_target = 431,
    compositor_failed_to_get_dxgi_device_interface = 432,
    compositor_select_display_mode = 433,
    compositor_failed_to_create_nv_api_render_targets = 434,
    compositor_nv_api_set_display_mode = 435,
    compositor_failed_to_create_direct_mode_display = 436,
    compositor_invalid_hmd_property_container = 437,
    compositor_update_display_frequency = 438,
    compositor_create_rasterizer_state = 439,
    compositor_create_wireframe_rasterizer_state = 440,
    compositor_create_sampler_state = 441,
    compositor_create_clamp_to_border_sampler_state = 442,
    compositor_create_aniso_sampler_state = 443,
    compositor_create_overlay_sampler_state = 444,
    compositor_create_panorama_sampler_state = 445,
    compositor_create_font_sampler_state = 446,
    compositor_create_no_blend_state = 447,
    compositor_create_blend_state = 448,
    compositor_create_alpha_blend_state = 449,
    compositor_create_blend_state_mask_r = 450,
    compositor_create_blend_state_mask_g = 451,
    compositor_create_blend_state_mask_b = 452,
    compositor_create_depth_stencil_state = 453,
    compositor_create_depth_stencil_state_no_write = 454,
    compositor_create_depth_stencil_state_no_depth = 455,
    compositor_create_flush_texture = 456,
    compositor_create_distortion_surfaces = 457,
    compositor_create_constant_buffer = 458,
    compositor_create_hmd_pose_constant_buffer = 459,
    compositor_create_hmd_pose_staging_constant_buffer = 460,
    compositor_create_shared_frame_info_constant_buffer = 461,
    compositor_create_overlay_constant_buffer = 462,
    compositor_create_scene_texture_index_constant_buffer = 463,
    compositor_create_readable_scene_texture_index_constant_buffer = 464,
    compositor_create_layer_graphics_texture_index_constant_buffer = 465,
    compositor_create_layer_compute_texture_index_constant_buffer = 466,
    compositor_create_layer_compute_scene_texture_index_constant_buffer = 467,
    compositor_create_compute_hmd_pose_constant_buffer = 468,
    compositor_create_geom_constant_buffer = 469,
    compositor_create_panel_mask_constant_buffer = 470,
    compositor_create_pixel_sim_ubo = 471,
    compositor_create_msaa_render_textures = 472,
    compositor_create_resolve_render_textures = 473,
    compositor_create_compute_resolve_render_textures = 474,
    compositor_create_driver_direct_mode_resolve_textures = 475,
    compositor_open_driver_direct_mode_resolve_textures = 476,
    compositor_create_fallback_sync_texture = 477,
    compositor_share_fallback_sync_texture = 478,
    compositor_create_overlay_index_buffer = 479,
    compositor_create_overlay_vertex_buffer = 480,
    compositor_create_text_vertex_buffer = 481,
    compositor_create_text_index_buffer = 482,
    compositor_create_mirror_textures = 483,
    compositor_create_last_frame_render_texture = 484,
    compositor_create_mirror_overlay = 485,
    compositor_failed_to_create_virtual_display_backbuffer = 486,
    compositor_display_mode_not_supported = 487,
    compositor_create_overlay_invalid_call = 488,
    compositor_create_overlay_already_initialized = 489,
    compositor_failed_to_create_mailbox = 490,
    compositor_window_interface_is_null = 491,
    compositor_system_layer_create_instance = 492,
    compositor_system_layer_create_session = 493,
    compositor_create_inverse_distort_u_vs = 494,
    compositor_create_backbuffer_depth = 495,
    compositor_cannot_drm_lease_display = 496,
    compositor_cannot_connect_to_display_server = 497,
    compositor_gnome_no_drm_leasing = 498,
    compositor_failed_to_initialize_encoder = 499,
    compositor_create_blur_texture = 500,
    vendor_specific_unable_to_connect_to_oculus_runtime = 1000,
    vendor_specific_windows_not_in_dev_mode = 1001,
    vendor_specific_oculus_link_not_enabled = 1002,
    vendor_specific_hmd_found_cant_open_device = 1101,
    vendor_specific_hmd_found_unable_to_request_config_start = 1102,
    vendor_specific_hmd_found_no_stored_config = 1103,
    vendor_specific_hmd_found_config_too_big = 1104,
    vendor_specific_hmd_found_config_too_small = 1105,
    vendor_specific_hmd_found_unable_to_init_z_lib = 1106,
    vendor_specific_hmd_found_cant_read_firmware_version = 1107,
    vendor_specific_hmd_found_unable_to_send_user_data_start = 1108,
    vendor_specific_hmd_found_unable_to_get_user_data_start = 1109,
    vendor_specific_hmd_found_unable_to_get_user_data_next = 1110,
    vendor_specific_hmd_found_user_data_address_range = 1111,
    vendor_specific_hmd_found_user_data_error = 1112,
    vendor_specific_hmd_found_config_failed_sanity_check = 1113,
    vendor_specific_oculus_runtime_bad_install = 1114,
    vendor_specific_hmd_found_unexpected_configuration_1 = 1115,
    steam_installation_not_found = 2000,
    last_error = 2001,

    pub fn maybe(init_error: InitErrorCode) InitError!void {
        return switch (init_error) {
            .none => {},
            .unknown => InitError.Unknown,
            .init_installation_not_found => InitError.InitInstallationNotFound,
            .init_installation_corrupt => InitError.InitInstallationCorrupt,
            .init_vr_client_dll_not_found => InitError.InitVRClientDLLNotFound,
            .init_file_not_found => InitError.InitFileNotFound,
            .init_factory_not_found => InitError.InitFactoryNotFound,
            .init_interface_not_found => InitError.InitInterfaceNotFound,
            .init_invalid_interface => InitError.InitInvalidInterface,
            .init_user_config_directory_invalid => InitError.InitUserConfigDirectoryInvalid,
            .init_hmd_not_found => InitError.InitHmdNotFound,
            .init_not_initialized => InitError.InitNotInitialized,
            .init_path_registry_not_found => InitError.InitPathRegistryNotFound,
            .init_no_config_path => InitError.InitNoConfigPath,
            .init_no_log_path => InitError.InitNoLogPath,
            .init_path_registry_not_writable => InitError.InitPathRegistryNotWritable,
            .init_app_info_init_failed => InitError.InitAppInfoInitFailed,
            .init_retry => InitError.InitRetry,
            .init_init_canceled_by_user => InitError.InitInitCanceledByUser,
            .init_another_app_launching => InitError.InitAnotherAppLaunching,
            .init_settings_init_failed => InitError.InitSettingsInitFailed,
            .init_shutting_down => InitError.InitShuttingDown,
            .init_too_many_objects => InitError.InitTooManyObjects,
            .init_no_server_for_background_app => InitError.InitNoServerForBackgroundApp,
            .init_not_supported_with_compositor => InitError.InitNotSupportedWithCompositor,
            .init_not_available_to_utility_apps => InitError.InitNotAvailableToUtilityApps,
            .init_internal => InitError.InitInternal,
            .init_hmd_driver_id_is_none => InitError.InitHmdDriverIdIsNone,
            .init_hmd_not_found_presence_failed => InitError.InitHmdNotFoundPresenceFailed,
            .init_vr_monitor_not_found => InitError.InitVRMonitorNotFound,
            .init_vr_monitor_startup_failed => InitError.InitVRMonitorStartupFailed,
            .init_low_power_watchdog_not_supported => InitError.InitLowPowerWatchdogNotSupported,
            .init_invalid_application_type => InitError.InitInvalidApplicationType,
            .init_not_available_to_watchdog_apps => InitError.InitNotAvailableToWatchdogApps,
            .init_watchdog_disabled_in_settings => InitError.InitWatchdogDisabledInSettings,
            .init_vr_dashboard_not_found => InitError.InitVRDashboardNotFound,
            .init_vr_dashboard_startup_failed => InitError.InitVRDashboardStartupFailed,
            .init_vr_home_not_found => InitError.InitVRHomeNotFound,
            .init_vr_home_startup_failed => InitError.InitVRHomeStartupFailed,
            .init_rebooting_busy => InitError.InitRebootingBusy,
            .init_firmware_update_busy => InitError.InitFirmwareUpdateBusy,
            .init_firmware_recovery_busy => InitError.InitFirmwareRecoveryBusy,
            .init_usb_service_busy => InitError.InitUSBServiceBusy,
            .init_vr_web_helper_startup_failed => InitError.InitVRWebHelperStartupFailed,
            .init_tracker_manager_init_failed => InitError.InitTrackerManagerInitFailed,
            .init_already_running => InitError.InitAlreadyRunning,
            .init_failed_for_vr_monitor => InitError.InitFailedForVrMonitor,
            .init_property_manager_init_failed => InitError.InitPropertyManagerInitFailed,
            .init_web_server_failed => InitError.InitWebServerFailed,
            .init_illegal_type_transition => InitError.InitIllegalTypeTransition,
            .init_mismatched_runtimes => InitError.InitMismatchedRuntimes,
            .init_invalid_process_id => InitError.InitInvalidProcessId,
            .init_vr_service_startup_failed => InitError.InitVRServiceStartupFailed,
            .init_prism_needs_new_drivers => InitError.InitPrismNeedsNewDrivers,
            .init_prism_startup_timed_out => InitError.InitPrismStartupTimedOut,
            .init_could_not_start_prism => InitError.InitCouldNotStartPrism,
            .init_prism_client_init_failed => InitError.InitPrismClientInitFailed,
            .init_prism_client_start_failed => InitError.InitPrismClientStartFailed,
            .init_prism_exited_unexpectedly => InitError.InitPrismExitedUnexpectedly,
            .init_bad_luid => InitError.InitBadLuid,
            .init_no_server_for_app_container => InitError.InitNoServerForAppContainer,
            .init_duplicate_bootstrapper => InitError.InitDuplicateBootstrapper,
            .init_vr_dashboard_service_pending => InitError.InitVRDashboardServicePending,
            .init_vr_dashboard_service_timeout => InitError.InitVRDashboardServiceTimeout,
            .init_vr_dashboard_service_stopped => InitError.InitVRDashboardServiceStopped,
            .init_vr_dashboard_already_started => InitError.InitVRDashboardAlreadyStarted,
            .init_vr_dashboard_copy_failed => InitError.InitVRDashboardCopyFailed,
            .init_vr_dashboard_token_failure => InitError.InitVRDashboardTokenFailure,
            .init_vr_dashboard_environment_failure => InitError.InitVRDashboardEnvironmentFailure,
            .init_vr_dashboard_path_failure => InitError.InitVRDashboardPathFailure,
            .driver_failed => InitError.DriverFailed,
            .driver_unknown => InitError.DriverUnknown,
            .driver_hmd_unknown => InitError.DriverHmdUnknown,
            .driver_not_loaded => InitError.DriverNotLoaded,
            .driver_runtime_out_of_date => InitError.DriverRuntimeOutOfDate,
            .driver_hmd_in_use => InitError.DriverHmdInUse,
            .driver_not_calibrated => InitError.DriverNotCalibrated,
            .driver_calibration_invalid => InitError.DriverCalibrationInvalid,
            .driver_hmd_display_not_found => InitError.DriverHmdDisplayNotFound,
            .driver_tracked_device_interface_unknown => InitError.DriverTrackedDeviceInterfaceUnknown,
            .driver_hmd_driver_id_out_of_bounds => InitError.DriverHmdDriverIdOutOfBounds,
            .driver_hmd_display_mirrored => InitError.DriverHmdDisplayMirrored,
            .driver_hmd_display_not_found_laptop => InitError.DriverHmdDisplayNotFoundLaptop,
            .driver_peer_driver_not_installed => InitError.DriverPeerDriverNotInstalled,
            .driver_wireless_hmd_not_connected => InitError.DriverWirelessHmdNotConnected,
            .ipc_server_init_failed => InitError.IPCServerInitFailed,
            .ipc_connect_failed => InitError.IPCConnectFailed,
            .ipc_shared_state_init_failed => InitError.IPCSharedStateInitFailed,
            .ipc_compositor_init_failed => InitError.IPCCompositorInitFailed,
            .ipc_mutex_init_failed => InitError.IPCMutexInitFailed,
            .ipc_failed => InitError.IPCFailed,
            .ipc_compositor_connect_failed => InitError.IPCCompositorConnectFailed,
            .ipc_compositor_invalid_connect_response => InitError.IPCCompositorInvalidConnectResponse,
            .ipc_connect_failed_after_multiple_attempts => InitError.IPCConnectFailedAfterMultipleAttempts,
            .ipc_connect_failed_after_target_exited => InitError.IPCConnectFailedAfterTargetExited,
            .ipc_namespace_unavailable => InitError.IPCNamespaceUnavailable,
            .compositor_failed => InitError.CompositorFailed,
            .compositor_d3d11_hardware_required => InitError.CompositorD3D11HardwareRequired,
            .compositor_firmware_requires_update => InitError.CompositorFirmwareRequiresUpdate,
            .compositor_overlay_init_failed => InitError.CompositorOverlayInitFailed,
            .compositor_screenshots_init_failed => InitError.CompositorScreenshotsInitFailed,
            .compositor_unable_to_create_device => InitError.CompositorUnableToCreateDevice,
            .compositor_shared_state_is_null => InitError.CompositorSharedStateIsNull,
            .compositor_notification_manager_is_null => InitError.CompositorNotificationManagerIsNull,
            .compositor_resource_manager_client_is_null => InitError.CompositorResourceManagerClientIsNull,
            .compositor_message_overlay_shared_state_init_failure => InitError.CompositorMessageOverlaySharedStateInitFailure,
            .compositor_properties_interface_is_null => InitError.CompositorPropertiesInterfaceIsNull,
            .compositor_create_fullscreen_window_failed => InitError.CompositorCreateFullscreenWindowFailed,
            .compositor_settings_interface_is_null => InitError.CompositorSettingsInterfaceIsNull,
            .compositor_failed_to_show_window => InitError.CompositorFailedToShowWindow,
            .compositor_distort_interface_is_null => InitError.CompositorDistortInterfaceIsNull,
            .compositor_display_frequency_failure => InitError.CompositorDisplayFrequencyFailure,
            .compositor_renderer_initialization_failed => InitError.CompositorRendererInitializationFailed,
            .compositor_dxgi_factory_interface_is_null => InitError.CompositorDXGIFactoryInterfaceIsNull,
            .compositor_dxgi_factory_create_failed => InitError.CompositorDXGIFactoryCreateFailed,
            .compositor_dxgi_factory_query_failed => InitError.CompositorDXGIFactoryQueryFailed,
            .compositor_invalid_adapter_desktop => InitError.CompositorInvalidAdapterDesktop,
            .compositor_invalid_hmd_attachment => InitError.CompositorInvalidHmdAttachment,
            .compositor_invalid_output_desktop => InitError.CompositorInvalidOutputDesktop,
            .compositor_invalid_device_provided => InitError.CompositorInvalidDeviceProvided,
            .compositor_d3d11_renderer_initialization_failed => InitError.CompositorD3D11RendererInitializationFailed,
            .compositor_failed_to_find_display_mode => InitError.CompositorFailedToFindDisplayMode,
            .compositor_failed_to_create_swap_chain => InitError.CompositorFailedToCreateSwapChain,
            .compositor_failed_to_get_back_buffer => InitError.CompositorFailedToGetBackBuffer,
            .compositor_failed_to_create_render_target => InitError.CompositorFailedToCreateRenderTarget,
            .compositor_failed_to_create_dxgi2_swap_chain => InitError.CompositorFailedToCreateDXGI2SwapChain,
            .compositor_failedto_get_dxgi2_back_buffer => InitError.CompositorFailedtoGetDXGI2BackBuffer,
            .compositor_failed_to_create_dxgi2_render_target => InitError.CompositorFailedToCreateDXGI2RenderTarget,
            .compositor_failed_to_get_dxgi_device_interface => InitError.CompositorFailedToGetDXGIDeviceInterface,
            .compositor_select_display_mode => InitError.CompositorSelectDisplayMode,
            .compositor_failed_to_create_nv_api_render_targets => InitError.CompositorFailedToCreateNvAPIRenderTargets,
            .compositor_nv_api_set_display_mode => InitError.CompositorNvAPISetDisplayMode,
            .compositor_failed_to_create_direct_mode_display => InitError.CompositorFailedToCreateDirectModeDisplay,
            .compositor_invalid_hmd_property_container => InitError.CompositorInvalidHmdPropertyContainer,
            .compositor_update_display_frequency => InitError.CompositorUpdateDisplayFrequency,
            .compositor_create_rasterizer_state => InitError.CompositorCreateRasterizerState,
            .compositor_create_wireframe_rasterizer_state => InitError.CompositorCreateWireframeRasterizerState,
            .compositor_create_sampler_state => InitError.CompositorCreateSamplerState,
            .compositor_create_clamp_to_border_sampler_state => InitError.CompositorCreateClampToBorderSamplerState,
            .compositor_create_aniso_sampler_state => InitError.CompositorCreateAnisoSamplerState,
            .compositor_create_overlay_sampler_state => InitError.CompositorCreateOverlaySamplerState,
            .compositor_create_panorama_sampler_state => InitError.CompositorCreatePanoramaSamplerState,
            .compositor_create_font_sampler_state => InitError.CompositorCreateFontSamplerState,
            .compositor_create_no_blend_state => InitError.CompositorCreateNoBlendState,
            .compositor_create_blend_state => InitError.CompositorCreateBlendState,
            .compositor_create_alpha_blend_state => InitError.CompositorCreateAlphaBlendState,
            .compositor_create_blend_state_mask_r => InitError.CompositorCreateBlendStateMaskR,
            .compositor_create_blend_state_mask_g => InitError.CompositorCreateBlendStateMaskG,
            .compositor_create_blend_state_mask_b => InitError.CompositorCreateBlendStateMaskB,
            .compositor_create_depth_stencil_state => InitError.CompositorCreateDepthStencilState,
            .compositor_create_depth_stencil_state_no_write => InitError.CompositorCreateDepthStencilStateNoWrite,
            .compositor_create_depth_stencil_state_no_depth => InitError.CompositorCreateDepthStencilStateNoDepth,
            .compositor_create_flush_texture => InitError.CompositorCreateFlushTexture,
            .compositor_create_distortion_surfaces => InitError.CompositorCreateDistortionSurfaces,
            .compositor_create_constant_buffer => InitError.CompositorCreateConstantBuffer,
            .compositor_create_hmd_pose_constant_buffer => InitError.CompositorCreateHmdPoseConstantBuffer,
            .compositor_create_hmd_pose_staging_constant_buffer => InitError.CompositorCreateHmdPoseStagingConstantBuffer,
            .compositor_create_shared_frame_info_constant_buffer => InitError.CompositorCreateSharedFrameInfoConstantBuffer,
            .compositor_create_overlay_constant_buffer => InitError.CompositorCreateOverlayConstantBuffer,
            .compositor_create_scene_texture_index_constant_buffer => InitError.CompositorCreateSceneTextureIndexConstantBuffer,
            .compositor_create_readable_scene_texture_index_constant_buffer => InitError.CompositorCreateReadableSceneTextureIndexConstantBuffer,
            .compositor_create_layer_graphics_texture_index_constant_buffer => InitError.CompositorCreateLayerGraphicsTextureIndexConstantBuffer,
            .compositor_create_layer_compute_texture_index_constant_buffer => InitError.CompositorCreateLayerComputeTextureIndexConstantBuffer,
            .compositor_create_layer_compute_scene_texture_index_constant_buffer => InitError.CompositorCreateLayerComputeSceneTextureIndexConstantBuffer,
            .compositor_create_compute_hmd_pose_constant_buffer => InitError.CompositorCreateComputeHmdPoseConstantBuffer,
            .compositor_create_geom_constant_buffer => InitError.CompositorCreateGeomConstantBuffer,
            .compositor_create_panel_mask_constant_buffer => InitError.CompositorCreatePanelMaskConstantBuffer,
            .compositor_create_pixel_sim_ubo => InitError.CompositorCreatePixelSimUBO,
            .compositor_create_msaa_render_textures => InitError.CompositorCreateMSAARenderTextures,
            .compositor_create_resolve_render_textures => InitError.CompositorCreateResolveRenderTextures,
            .compositor_create_compute_resolve_render_textures => InitError.CompositorCreateComputeResolveRenderTextures,
            .compositor_create_driver_direct_mode_resolve_textures => InitError.CompositorCreateDriverDirectModeResolveTextures,
            .compositor_open_driver_direct_mode_resolve_textures => InitError.CompositorOpenDriverDirectModeResolveTextures,
            .compositor_create_fallback_sync_texture => InitError.CompositorCreateFallbackSyncTexture,
            .compositor_share_fallback_sync_texture => InitError.CompositorShareFallbackSyncTexture,
            .compositor_create_overlay_index_buffer => InitError.CompositorCreateOverlayIndexBuffer,
            .compositor_create_overlay_vertex_buffer => InitError.CompositorCreateOverlayVertexBuffer,
            .compositor_create_text_vertex_buffer => InitError.CompositorCreateTextVertexBuffer,
            .compositor_create_text_index_buffer => InitError.CompositorCreateTextIndexBuffer,
            .compositor_create_mirror_textures => InitError.CompositorCreateMirrorTextures,
            .compositor_create_last_frame_render_texture => InitError.CompositorCreateLastFrameRenderTexture,
            .compositor_create_mirror_overlay => InitError.CompositorCreateMirrorOverlay,
            .compositor_failed_to_create_virtual_display_backbuffer => InitError.CompositorFailedToCreateVirtualDisplayBackbuffer,
            .compositor_display_mode_not_supported => InitError.CompositorDisplayModeNotSupported,
            .compositor_create_overlay_invalid_call => InitError.CompositorCreateOverlayInvalidCall,
            .compositor_create_overlay_already_initialized => InitError.CompositorCreateOverlayAlreadyInitialized,
            .compositor_failed_to_create_mailbox => InitError.CompositorFailedToCreateMailbox,
            .compositor_window_interface_is_null => InitError.CompositorWindowInterfaceIsNull,
            .compositor_system_layer_create_instance => InitError.CompositorSystemLayerCreateInstance,
            .compositor_system_layer_create_session => InitError.CompositorSystemLayerCreateSession,
            .compositor_create_inverse_distort_u_vs => InitError.CompositorCreateInverseDistortUVs,
            .compositor_create_backbuffer_depth => InitError.CompositorCreateBackbufferDepth,
            .compositor_cannot_drm_lease_display => InitError.CompositorCannotDRMLeaseDisplay,
            .compositor_cannot_connect_to_display_server => InitError.CompositorCannotConnectToDisplayServer,
            .compositor_gnome_no_drm_leasing => InitError.CompositorGnomeNoDRMLeasing,
            .compositor_failed_to_initialize_encoder => InitError.CompositorFailedToInitializeEncoder,
            .compositor_create_blur_texture => InitError.CompositorCreateBlurTexture,
            .vendor_specific_unable_to_connect_to_oculus_runtime => InitError.VendorSpecificUnableToConnectToOculusRuntime,
            .vendor_specific_windows_not_in_dev_mode => InitError.VendorSpecificWindowsNotInDevMode,
            .vendor_specific_oculus_link_not_enabled => InitError.VendorSpecificOculusLinkNotEnabled,
            .vendor_specific_hmd_found_cant_open_device => InitError.VendorSpecificHmdFoundCantOpenDevice,
            .vendor_specific_hmd_found_unable_to_request_config_start => InitError.VendorSpecificHmdFoundUnableToRequestConfigStart,
            .vendor_specific_hmd_found_no_stored_config => InitError.VendorSpecificHmdFoundNoStoredConfig,
            .vendor_specific_hmd_found_config_too_big => InitError.VendorSpecificHmdFoundConfigTooBig,
            .vendor_specific_hmd_found_config_too_small => InitError.VendorSpecificHmdFoundConfigTooSmall,
            .vendor_specific_hmd_found_unable_to_init_z_lib => InitError.VendorSpecificHmdFoundUnableToInitZLib,
            .vendor_specific_hmd_found_cant_read_firmware_version => InitError.VendorSpecificHmdFoundCantReadFirmwareVersion,
            .vendor_specific_hmd_found_unable_to_send_user_data_start => InitError.VendorSpecificHmdFoundUnableToSendUserDataStart,
            .vendor_specific_hmd_found_unable_to_get_user_data_start => InitError.VendorSpecificHmdFoundUnableToGetUserDataStart,
            .vendor_specific_hmd_found_unable_to_get_user_data_next => InitError.VendorSpecificHmdFoundUnableToGetUserDataNext,
            .vendor_specific_hmd_found_user_data_address_range => InitError.VendorSpecificHmdFoundUserDataAddressRange,
            .vendor_specific_hmd_found_user_data_error => InitError.VendorSpecificHmdFoundUserDataError,
            .vendor_specific_hmd_found_config_failed_sanity_check => InitError.VendorSpecificHmdFoundConfigFailedSanityCheck,
            .vendor_specific_oculus_runtime_bad_install => InitError.VendorSpecificOculusRuntimeBadInstall,
            .vendor_specific_hmd_found_unexpected_configuration_1 => InitError.VendorSpecificHmdFoundUnexpectedConfiguration1,
            .steam_installation_not_found => InitError.SteamInstallationNotFound,
            .last_error => InitError.LastError,
        };
    }

    pub fn asSymbol(init_error: InitErrorCode) [:0]const u8 {
        return std.mem.span(VR_GetVRInitErrorAsSymbol(init_error));
    }
    pub fn asEnglishDescription(init_error: InitErrorCode) [:0]const u8 {
        return std.mem.span(VR_GetVRInitErrorAsEnglishDescription(init_error));
    }
};

extern fn VR_GetVRInitErrorAsSymbol(InitErrorCode) callconv(.C) [*c]u8;
extern fn VR_GetVRInitErrorAsEnglishDescription(InitErrorCode) callconv(.C) [*c]u8;

test "init error have english descriptions" {
    try std.testing.expectEqualStrings("No Error (0)", InitErrorCode.none.asEnglishDescription());
}

pub extern fn VR_GetGenericInterface([*c]const u8, *InitErrorCode) callconv(.C) *isize;

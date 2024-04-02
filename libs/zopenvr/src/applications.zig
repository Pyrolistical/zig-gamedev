const std = @import("std");

const common = @import("common.zig");

function_table: *FunctionTable,

const Self = @This();
const version = "IVRApplications_007";
pub fn init() common.InitError!Self {
    return .{
        .function_table = try common.getFunctionTable(FunctionTable, version),
    };
}

pub const ApplicationError = error{
    None,
    AppKeyAlreadyExists,
    NoManifest,
    NoApplication,
    InvalidIndex,
    UnknownApplication,
    IPCFailed,
    ApplicationAlreadyRunning,
    InvalidManifest,
    InvalidApplication,
    LaunchFailed,
    ApplicationAlreadyStarting,
    LaunchInProgress,
    OldApplicationQuitting,
    TransitionAborted,
    IsTemplate,
    SteamVRIsExiting,
    BufferTooSmall,
    PropertyNotSet,
    UnknownProperty,
    InvalidParameter,
    NotImplemented,
};
pub const ApplicationErrorCode = enum(i32) {
    none = 0,

    app_key_already_exists = 100, // Only one application can use any given key
    no_manifest = 101, // the running application does not have a manifest
    no_application = 102, // No application is running
    invalid_index = 103,
    unknown_application = 104, // the application could not be found
    ipc_failed = 105, // An IPC failure caused the request to fail
    application_already_running = 106,
    invalid_manifest = 107,
    invalid_application = 108,
    launch_failed = 109, // the process didn't start
    application_already_starting = 110, // the system was already starting the same application
    launch_in_progress = 111, // The system was already starting a different application
    old_application_quitting = 112,
    transition_aborted = 113,
    is_template = 114, // error when you try to call LaunchApplication() on a template type app (use LaunchTemplateApplication)
    steam_vr_is_exiting = 115,

    buffer_too_small = 200, // The provided buffer was too small to fit the requested data
    property_not_set = 201, // The requested property was not set
    unknown_property = 202,
    invalid_parameter = 203,

    not_implemented = 300, // Fcn is not implemented in current interface

    pub fn maybe(error_code: ApplicationErrorCode) ApplicationError!void {
        return switch (error_code) {
            .none => {},
            .app_key_already_exists => ApplicationError.AppKeyAlreadyExists,
            .no_manifest => ApplicationError.NoManifest,
            .no_application => ApplicationError.NoApplication,
            .invalid_index => ApplicationError.InvalidIndex,
            .unknown_application => ApplicationError.UnknownApplication,
            .ipc_failed => ApplicationError.IPCFailed,
            .application_already_running => ApplicationError.ApplicationAlreadyRunning,
            .invalid_manifest => ApplicationError.InvalidManifest,
            .invalid_application => ApplicationError.InvalidApplication,
            .launch_failed => ApplicationError.LaunchFailed,
            .application_already_starting => ApplicationError.ApplicationAlreadyStarting,
            .launch_in_progress => ApplicationError.LaunchInProgress,
            .old_application_quitting => ApplicationError.OldApplicationQuitting,
            .transition_aborted => ApplicationError.TransitionAborted,
            .is_template => ApplicationError.IsTemplate,
            .steam_vr_is_exiting => ApplicationError.SteamVRIsExiting,
            .buffer_too_small => ApplicationError.BufferTooSmall,
            .property_not_set => ApplicationError.PropertyNotSet,
            .unknown_property => ApplicationError.UnknownProperty,
            .invalid_parameter => ApplicationError.InvalidParameter,
            .not_implemented => ApplicationError.NotImplemented,
        };
    }
};

pub fn addApplicationManifest(self: Self, application_manifest_full_path: [:0]const u8, temporary: bool) ApplicationError!void {
    const error_code = self.function_table.AddApplicationManifest(@constCast(application_manifest_full_path.ptr), temporary);
    try error_code.maybe();
}
pub fn removeApplicationManifest(self: Self, application_manifest_full_path: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.RemoveApplicationManifest(application_manifest_full_path.ptr);
    try error_code.maybe();
}
pub fn isApplicationInstalled(self: Self, app_key: [:0]const u8) bool {
    return self.function_table.IsApplicationInstalled(app_key.ptr);
}
pub fn getApplicationCount(self: Self) u32 {
    return self.function_table.GetApplicationCount();
}
pub const max_application_key_length = 128;
pub fn allocApplicationKeyByIndex(self: Self, allocator: std.mem.Allocator, application_index: u32) ![]u8 {
    var application_key_buffer: [max_application_key_length]u8 = undefined;

    self.function_table.GetApplicationKeyByIndex(application_index, application_key_buffer.ptr, @intCast(application_key_buffer.len));

    const application_key_length = std.mem.indexOfScalar(u8, application_key_buffer[0..], 0);
    const application_key = try allocator.alloc(u8, application_key_length);
    std.mem.copyForward(u8, application_key_buffer[0..application_key_length], application_key);
    return application_key;
}
pub fn allocApplicationKeyByProcessId(self: Self, allocator: std.mem.Allocator, process_id: u32) ![]u8 {
    var application_key_buffer: [max_application_key_length]u8 = undefined;

    self.function_table.GetApplicationKeyByProcessId(process_id, application_key_buffer.ptr, @intCast(application_key_buffer.len));

    const application_key_length = std.mem.indexOfScalar(u8, application_key_buffer[0..], 0);
    const application_key = try allocator.alloc(u8, application_key_length);
    std.mem.copyForward(u8, application_key_buffer[0..application_key_length], application_key);
    return application_key;
}

pub fn launchApplication(self: Self, app_key: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.LaunchApplication(app_key.ptr);
    try error_code.maybe();
}

pub const AppOverrideKeys = extern struct {
    key: [*c]u8,
    value: [*c]u8,
};

pub fn launchTemplateApplication(self: Self, template_app_key: [:0]const u8, new_app_key: [:0]const u8, keys: []AppOverrideKeys) ApplicationError!void {
    const error_code = self.function_table.LaunchTemplateApplication(template_app_key.ptr, new_app_key.ptr, keys.ptr, @intCast(keys.len));
    try error_code.maybe();
}

pub fn launchApplicationFromMimeType(self: Self, mime_type: [:0]const u8, args: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.LaunchApplicationFromMimeType(mime_type.ptr, args.ptr);
    try error_code.maybe();
}

pub fn launchDashboardOverlay(self: Self, app_key: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.LaunchDashboardOverlay(app_key.ptr);
    try error_code.maybe();
}

pub fn cancelApplicationLaunch(self: Self, app_key: [:0]const u8) bool {
    return self.function_table.CancelApplicationLaunch(app_key.ptr);
}

pub fn identifyApplication(self: Self, process_id: u32, app_key: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.IdentifyApplication(process_id, app_key.ptr);
    try error_code.maybe();
}

pub fn getApplicationProcessId(self: Self, app_key: [:0]const u8) ApplicationError!u32 {
    return self.function_table.GetApplicationProcessId(app_key.ptr);
}

pub fn getApplicationsErrorNameFromEnum(self: Self, error_code: ApplicationErrorCode) []const u8 {
    return std.mem.span(self.function_table.GetApplicationsErrorNameFromEnum(error_code));
}

pub const ApplicationProperty = enum(i32) {
    name_string = 0,

    launch_type_string = 11,
    working_directory_string = 12,
    binary_path_string = 13,
    arguments_string = 14,
    url_string = 15,

    description_string = 50,
    news_url_string = 51,
    image_path_string = 52,
    source_string = 53,
    action_manifest_url_string = 54,

    is_dashboard_overlay_bool = 60,
    is_template_bool = 61,
    is_instanced_bool = 62,
    is_internal_bool = 63,
    wants_compositor_pause_in_standby_bool = 64,
    is_hidden_bool = 65,

    last_launch_time_uint64 = 70,
};

pub fn allocApplicationPropertyString(self: Self, allocator: std.mem.Allocator, app_key: [:0]const u8, property: ApplicationProperty) ApplicationErrorCode![:0]u8 {
    var error_code: ApplicationErrorCode = undefined;
    const buffer_length = self.function_table.GetStringTrackedDeviceProperty(app_key.ptr, property, null, 0, &error_code);
    try error_code.maybe();

    const buffer = try allocator.allocSentinel(u8, buffer_length - 1, 0);
    if (buffer_length > 0) {
        error_code = undefined;
        _ = self.function_table.GetApplicationPropertyString(app_key.ptr, property, buffer.ptr, buffer_length, &error_code);
        try error_code.maybe();
    }

    return buffer;
}

pub fn getApplicationPropertyBool(self: Self, app_key: [:0]const u8, property: ApplicationProperty) ApplicationError!bool {
    var error_code: ApplicationErrorCode = undefined;
    const result = self.function_table.GetApplicationPropertyBool(app_key.ptr, property, &error_code);
    try error_code.maybe();
    return result;
}

pub fn getApplicationPropertyUint64(self: Self, app_key: [:0]const u8, property: ApplicationProperty) ApplicationError!u64 {
    var error_code: ApplicationErrorCode = undefined;
    const result = self.function_table.GetApplicationPropertyUint64(app_key.ptr, property, &error_code);
    try error_code.maybe();
    return result;
}

pub fn setApplicationAutoLaunch(self: Self, app_key: [:0]const u8, auto_launch: bool) ApplicationError!void {
    const error_code = self.function_table.SetApplicationAutoLaunch(app_key.ptr, auto_launch);
    try error_code.maybe();
}

pub fn getApplicationAutoLaunch(self: Self, app_key: [:0]const u8) ApplicationError!bool {
    return self.function_table.GetApplicationAutoLaunch(app_key.ptr);
}

pub fn setDefaultApplicationForMimeType(self: Self, app_key: [:0]const u8, mime_type: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.SetDefaultApplicationForMimeType(app_key.ptr, mime_type.ptr);
    try error_code.maybe();
}

pub fn allocDefaultApplicationForMimeType(self: Self, allocator: std.mem.Allocator, mime_type: [:0]const u8) ![]u8 {
    var application_key_buffer: [max_application_key_length]u8 = undefined;

    const result = self.function_table.GetDefaultApplicationForMimeType(mime_type.ptr, application_key_buffer.ptr, @intCast(application_key_buffer.len));
    @compileLog("GetDefaultApplicationForMimeType: what is result " ++ std.fmt.compPrint("{}", .{result}));

    const application_key_length = std.mem.indexOfScalar(u8, application_key_buffer[0..], 0);
    const application_key = try allocator.alloc(u8, application_key_length);
    std.mem.copyForward(u8, application_key_buffer[0..application_key_length], application_key);
    return application_key;
}

pub const MimeTypes = struct {
    buffer: []u8,

    pub fn deinit(self: MimeTypes, allocator: std.mem.Allocator) void {
        allocator.free(self.buffer);
    }

    pub fn allocTypes(self: MimeTypes, allocator: std.mem.Allocator) ![][]const u8 {
        var types = std.ArrayList([]const u8).init(allocator);
        var it = std.mem.splitScalar(u8, self.buffer, ',');
        while (it.next()) |t| {
            try types.append(t);
        }
        return types.toOwnedSlice();
    }
};

pub fn allocApplicationSupportedMimeTypes(self: Self, allocator: std.mem.Allocator, app_key: [:0]const u8, buffer_length: u32) !MimeTypes {
    const buffer = try allocator.allocSentinel(u8, buffer_length - 1, 0);
    const result = self.function_table.GetApplicationSupportedMimeTypes(app_key.ptr, buffer.ptr, buffer_length);
    @compileLog("GetApplicationSupportedMimeTypes: what is result " ++ std.fmt.compPrint("{}", .{result}));

    return MimeTypes{ .buffer = buffer };
}

pub const AppKeys = struct {
    buffer: []u8,

    pub fn deinit(self: AppKeys, allocator: std.mem.Allocator) void {
        allocator.free(self.buffer);
    }

    pub fn allocKeys(self: AppKeys, allocator: std.mem.Allocator) ![][]const u8 {
        var keys = std.ArrayList([]const u8).init(allocator);
        var it = std.mem.splitScalar(u8, self.buffer, ',');
        while (it.next()) |key| {
            try keys.append(key);
        }
        return keys.toOwnedSlice();
    }
};

pub fn allocApplicationsThatSupportMimeType(self: Self, allocator: std.mem.Allocator, mime_type: [:0]const u8) !AppKeys {
    const buffer_length = self.function_table.GetApplicationsThatSupportMimeType(mime_type.ptr, null, 0);

    const buffer = try allocator.allocSentinel(u8, buffer_length - 1, 0);
    if (buffer_length > 0) {
        _ = self.function_table.GetApplicationPropertyString(mime_type.ptr, buffer.ptr, buffer_length);
    }

    return AppKeys{ .buffer = buffer };
}

pub fn allocApplicationLaunchArguments(self: Self, allocator: std.mem.Allocator, handle: u32) ![]u8 {
    const buffer_length = self.function_table.GetApplicationLaunchArguments(handle, null, 0);

    const buffer = try allocator.allocSentinel(u8, buffer_length - 1, 0);
    if (buffer_length > 0) {
        _ = self.function_table.GetApplicationPropertyString(handle, buffer.ptr, buffer_length);
    }

    return buffer;
}

pub fn allocStartingApplication(self: Self, allocator: std.mem.Allocator) ApplicationError![]u8 {
    var application_key_buffer: [max_application_key_length]u8 = undefined;

    const error_code = self.function_table.GetStartingApplication(application_key_buffer.ptr, @intCast(application_key_buffer.len));
    try error_code.maybe();

    const application_key_length = std.mem.indexOfScalar(u8, application_key_buffer[0..], 0);
    const application_key = try allocator.alloc(u8, application_key_length);
    std.mem.copyForward(u8, application_key_buffer[0..application_key_length], application_key);
    return application_key;
}

pub const SceneApplicationState = enum(i32) {
    none = 0,
    starting = 1,
    quitting = 2,
    running = 3,
    waiting = 4,
};

pub fn getStartingApplication(self: Self) SceneApplicationState {
    return self.function_table.GetStartingApplication();
}

pub fn performApplicationPrelaunchCheck(self: Self, app_key: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.PerformApplicationPrelaunchCheck(app_key.ptr);
    try error_code.maybe();
}

pub fn getSceneApplicationStateNameFromEnum(self: Self, state: SceneApplicationState) []const u8 {
    return std.mem.span(self.function_table.GetSceneApplicationStateNameFromEnum(state));
}

pub fn launchInternalProcess(self: Self, binary_path: [:0]const u8, arguments: [:0]const u8, working_directory: [:0]const u8) ApplicationError!void {
    const error_code = self.function_table.LaunchInternalProcess(binary_path.ptr, arguments.ptr, working_directory.ptr);
    try error_code.maybe();
}

pub fn getCurrentSceneProcessId(self: Self) u32 {
    return self.function_table.GetCurrentSceneProcessId();
}

pub const FunctionTable = extern struct {
    AddApplicationManifest: *const fn ([*c]u8, bool) callconv(.C) ApplicationErrorCode,
    RemoveApplicationManifest: *const fn ([*c]u8) callconv(.C) ApplicationErrorCode,
    IsApplicationInstalled: *const fn ([*c]u8) callconv(.C) bool,
    GetApplicationCount: *const fn () callconv(.C) u32,
    GetApplicationKeyByIndex: *const fn (u32, [*c]u8, u32) callconv(.C) ApplicationErrorCode,
    GetApplicationKeyByProcessId: *const fn (u32, [*c]u8, u32) callconv(.C) ApplicationErrorCode,
    LaunchApplication: *const fn ([*c]u8) callconv(.C) ApplicationErrorCode,
    LaunchTemplateApplication: *const fn ([*c]u8, [*c]u8, [*c]AppOverrideKeys, u32) callconv(.C) ApplicationErrorCode,
    LaunchApplicationFromMimeType: *const fn ([*c]u8, [*c]u8) callconv(.C) ApplicationErrorCode,
    LaunchDashboardOverlay: *const fn ([*c]u8) callconv(.C) ApplicationErrorCode,
    CancelApplicationLaunch: *const fn ([*c]u8) callconv(.C) bool,
    IdentifyApplication: *const fn (u32, [*c]u8) callconv(.C) ApplicationErrorCode,
    GetApplicationProcessId: *const fn ([*c]u8) callconv(.C) u32,
    GetApplicationsErrorNameFromEnum: *const fn (ApplicationErrorCode) callconv(.C) [*c]u8,
    GetApplicationPropertyString: *const fn ([*c]u8, ApplicationProperty, [*c]u8, u32, *ApplicationErrorCode) callconv(.C) u32,
    GetApplicationPropertyBool: *const fn ([*c]u8, ApplicationProperty, *ApplicationErrorCode) callconv(.C) bool,
    GetApplicationPropertyUint64: *const fn ([*c]u8, ApplicationProperty, *ApplicationErrorCode) callconv(.C) u64,
    SetApplicationAutoLaunch: *const fn ([*c]u8, bool) callconv(.C) ApplicationErrorCode,
    GetApplicationAutoLaunch: *const fn ([*c]u8) callconv(.C) bool,
    SetDefaultApplicationForMimeType: *const fn ([*c]u8, [*c]u8) callconv(.C) ApplicationErrorCode,
    GetDefaultApplicationForMimeType: *const fn ([*c]u8, [*c]u8, u32) callconv(.C) bool,
    GetApplicationSupportedMimeTypes: *const fn ([*c]u8, [*c]u8, u32) callconv(.C) bool,
    GetApplicationsThatSupportMimeType: *const fn ([*c]u8, [*c]u8, u32) callconv(.C) u32,
    GetApplicationLaunchArguments: *const fn (u32, [*c]u8, u32) callconv(.C) u32,
    GetStartingApplication: *const fn ([*c]u8, u32) callconv(.C) ApplicationErrorCode,
    GetSceneApplicationState: *const fn () callconv(.C) SceneApplicationState,
    PerformApplicationPrelaunchCheck: *const fn ([*c]u8) callconv(.C) ApplicationErrorCode,
    GetSceneApplicationStateNameFromEnum: *const fn (SceneApplicationState) callconv(.C) [*c]u8,
    LaunchInternalProcess: *const fn ([*c]u8, [*c]u8, [*c]u8) callconv(.C) ApplicationErrorCode,
    GetCurrentSceneProcessId: *const fn () callconv(.C) u32,
};

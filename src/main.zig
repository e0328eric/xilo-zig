const std = @import("std");
const ansi = @import("./ansi.zig");
const Remover = @import("./Remover.zig");
const Zlap = @import("zlap").Zlap;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var zlap = try Zlap.init(allocator, @embedFile("./xilo_command.json"));
    defer zlap.deinit();

    // Datas from command line argument
    const file_contents = zlap.main_args.items[0].value.strings.items;
    const is_recursive = flag: {
        const flag = zlap.main_flags.get("recursive") orelse break :flag false;
        break :flag flag.value.bool;
    };
    const is_force = flag: {
        const flag = zlap.main_flags.get("force") orelse break :flag false;
        break :flag flag.value.bool;
    };
    const is_permanent = flag: {
        const flag = zlap.main_flags.get("permanent") orelse break :flag false;
        break :flag flag.value.bool;
    };

    if (zlap.is_help or (!is_permanent and file_contents.len == 0)) {
        // zig fmt: off
        const err_msg = ansi.red
            ++ ansi.bold ++ "Error: "
            ++ ansi.reset ++ "there is no file/directory name to run this program.\n";
        const note_msg = ansi.cyan
            ++ ansi.bold ++ "Note:  "
            ++ ansi.reset ++ "add files or directories to remove.\n\n";
        // zig fmt: on
        std.debug.print(err_msg, .{});
        std.debug.print(note_msg, .{});
        std.debug.print("{s}\n", .{zlap.help_msg});
    }

    const remover = try Remover.init(
        allocator,
        is_recursive,
        is_force,
        is_permanent,
        file_contents,
    );
    defer remover.deinit();

    std.debug.print("{s}\n", .{remover.trashbin_path.items});
    for (file_contents) |filename| {
        std.debug.print("<{s}>\n", .{filename});
    }
}

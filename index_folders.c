// bear -- gcc -Wall -Wextra -O0 -ggdb -std=c23 -lstz2

#include "types.h"

#include <stz2/args.h>
#include <stz2/cmd.h>
#include <stz2/path.h>

// clang-format off
Arg options[] = {
    {_("help"), no_argument,       0, _("Show help"),       ARG_Bool,   &cfg.help, false},
    {_("path"), required_argument, 0, _("Data folder"),     ARG_String, &cfg.path, false},
    {_("meta"), required_argument, 0, _("Metadata folder"), ARG_String, &cfg.meta, false},
    {_("url"),  required_argument, 0, _("Remarkable url"),  ARG_String, &cfg.url,  false},
};
// clang-format on

int main(int argc, char* argv[])
{
    int err = 0;
    Buf b   = buf_new(64 * MB_);

    Args args = {
        .len   = countof(options),
        .buf   = options,
        .usage = _0("index_folders [OPTIONS]"),
    };

    err = args_parse(&b, &args, argc, argv, true);
    OnError_Fatal(err, "Failed: args_parse: err=%d", err);

    CmdResult res = {};
    Str0      cmd = {};

    // --------------- Setup metadata folders ---------------

    Str0 meta_path    = str0_fmt(&b, "%.*s", _s(cfg.meta));
    Str0 files_path   = str0_fmt(&b, "%.*s/files", _s(cfg.meta));
    Str0 folders_path = str0_fmt(&b, "%.*s/folders", _s(cfg.meta));

    err = path_mkdir(meta_path, 0755);
    OnError_Fatal(err, "Failed: path_mkdir(%.*s): err=%d", err, _s(meta_path));

    err = path_mkdir(files_path, 0755);
    OnError_Fatal(err, "Failed: path_mkdir(%.*s): err=%d", err, _s(files_path));

    err = path_mkdir(folders_path, 0755);
    OnError_Fatal(err, "Failed: path_mkdir(%.*s): err=%d", err, _s(folders_path));

    // --------------- Index metadata ---------------

    // Fetch folders in root
    cmd = str0_fmt(&b, "curl %.*s/documents/", _s(cfg.url));
    err = cmd_exec(&b, cmd, CmdShellBash, 60 * MB_, 2 * MB_, &res);
    OnError_Fatal((err | res.status), "Failed: err=%d, res.status=%d", err, res.status);

    // Write to documents.json
    Str0 index_path = str0_fmt(&b, "%.*s/documents.json", _s(cfg.meta));

    err = path_write_text(index_path, res.out, "w");
    OnError_Fatal(err, "Failed: path_write_text: err=%d", err);

    // Parse documents.json
    Parser p = BufFromStr(res.out);

    Docs docs = arr_new(Docs, &b, Doc, 32, ALLOC_ZERO);
    parse__Docs(&p, &docs);
    PrintLn(docs.len);

    buf_free(&b);

    return EXIT_SUCCESS;
}

#include <stz2/parse.h>
#include <stz2/types.h>

// --------------- Command Line Options ---------------

typedef struct
{
    bool help;
    Str0 path;
    Str0 meta;
    Str0 url;
} Config;

// --------------- Doc type ---------------

#define X_TABLE_RMK_DOCS(name, type)                                                                                   \
    X(Bookmarked, bool)                                                                                                \
    X(CurrentPage, int)                                                                                                \
    X(ID, Str)                                                                                                         \
    X(ModifiedClient, Str)                                                                                             \
    X(Parent, Str)                                                                                                     \
    X(Type, Str)                                                                                                       \
    X(VisibleName, Str)                                                                                                \
    X(VissibleName, Str)                                                                                               \
    X(fileType, Str)

#define X(name, type) type name;
typedef struct
{
    X_TABLE_RMK_DOCS(name, type)
} Doc;
#undef X

#define X(name, type) Doc__FIELD_##name,
typedef enum
{
    X_TABLE_RMK_DOCS(name, type) Doc__FIELD_COUNT,
} DocFields;
#undef X

DECLARE_ARRAY(Docs, Doc);

// --------------- Serialize, Deserialize ---------------

SI Str parse__Doc(Parser* b, Doc* doc)
{
    *doc = (Doc){};

    Parser bb = BufFromBuffer(b);

    consume__char(&bb, '{');
    if (bb.err) return StrNull;

    // X_TABLE_RMK_DOCS(name, type);

    consume__char(&bb, '}');
    if (bb.err) return StrNull;

    b->len += bb.len;

    return BufToStr((&bb), bb.pos);
}

SI Str parse__Docs(Parser* b, Docs* docs)
{
    isize len  = 0;
    len       += consume__char(b, '[').len;

    isize count = 0;
    while (!b->err && (count < docs->len))
    {
        len += consume__whitespace(b).len;
        parse__Doc(b, &docs->buf[count]);
        len += consume__whitespace(b).len;
        if (!b->err) count++;
        len += consume__char(b, ',').len;
    }
    docs->len = count;

    len += consume__char(b, ']').len;
    return BufToStr(b, len);
}

#include <stdarg.h>
#include "reaper_plugin.h"

// extern "C" void ProjectStateContext_AddLine(ProjectStateContext *ctx, const char *fmt, ...) {
//     va_list args;
//     va_start(args, fmt);
//     ctx->AddLine(fmt, args);
//     va_end(args);
// }

extern "C" void ProjectStateContext_AddLine(ProjectStateContext *ctx, const char *str) {
    ctx->AddLine(str);
}

extern "C" int ProjectStateContext_GetLine(ProjectStateContext *ctx, char *buf, int buflen) {
    return ctx->GetLine(buf, buflen);
}
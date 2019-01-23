module printerr;

static import cstdio = core.stdc.stdio;
import std.string : toStringz;

extern(C) void printErr(Args...)(scope const(char*) format, auto ref Args args) nothrow @nogc @system
{
    cstdio.fprintf(cstdio.stderr, format, args);
}

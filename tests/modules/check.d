module check;

import std.stdio    ;
import std.typecons ;//: Tuple, tuple;
import std.range    ;//: array;
import std.file;//.tempDir
import std.random;
import std.string;
import std.algorithm;
import std.algorithm  : splitter, joiner;
import std.range      : enumerate;
import std.string     : indexOf, strip;
import std.functional : forward;
import std.stdio      : File;
import std.conv : to;
import std.getopt;
import std.path : buildPath;


static import c;

void checkTest(bool valid, string msg)
{
    writeln('\n', c.yellow, msg, c.reset);
    write( c.blue, "".leftJustifier(20, '.'), c.reset);
    if(valid) {
        writeln(c.green, "OK", c.reset);
    } else {
        writeln(c.red, "FAIL", c.reset);
        throw new Exception("Failed test " ~ msg);
    }
}

void headTest(string msg)
{
    writeln( c.blue, "".leftJustifier(50, '.'), c.reset);
    writeln(c.gray, msg, c.reset);
}
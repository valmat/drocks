module check;

import std.stdio  : write, writeln;
import std.string : leftJustifier;
import std.conv   : to;

static import c;

void checkTest(bool valid, string msg)
{
    write("\n   ", c.yellow, (msg ~ c.blue).to!string.leftJustifier(70, '.').to!string  );
    write(c.reset);

    if(valid) {
        writeln(c.green, "OK", c.reset);
    } else {
        writeln(c.red, "FAIL", c.reset);
        throw new Exception("Failed test: " ~ msg);
    }
}

void headTest(const string msg)
{
    string m = "\n".leftJustifier(20, '.').to!string ~ c.white ~ msg ~ c.gray;
    m = m.leftJustifier(85, '.').to!string;
    
    writeln( c.gray, m, c.reset);
}
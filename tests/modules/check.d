module check;

import std.stdio  : write, writeln;
import std.string : leftJustifier;
import std.conv   : to;

static import c;

void successMsg(string msg)
{
    writeln(c.green, msg, c.reset);
}
void failMsg(string msg)
{
    writeln(c.red, msg, c.reset);
}

void checkTest(bool valid, string msg)
{
    write("\n   ", c.yellow, (msg ~ c.blue).to!string.leftJustifier(70, '.').to!string  );
    write(c.reset);

    if(valid) {
        successMsg("OK");
    } else {
        failMsg("FAIL");
        throw new Exception("Failed test: " ~ msg);
    }
}

void headTest(const string msg)
{
    string m = "\n".leftJustifier(20, '.').to!string ~ c.white ~ msg ~ c.gray;
    m = m.leftJustifier(85, '.').to!string;
    
    writeln( c.gray, m, c.reset);
}
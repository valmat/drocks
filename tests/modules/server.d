module server;

import std.stdio   : writeln, stderr;
import std.process : spawnProcess, Pid, kill, wait;
import core.thread : Thread, seconds, msecs;

struct ServerRunner
{
private:
    Pid _pid;
    bool _opened = true;

public:
    
    @disable this(this);
    @disable this();

    this(string binary, string confFile)
    {
        _pid = spawnProcess([binary, confFile]);

        stderr.writeln("Waiting server start...");
        Thread.sleep(100.msecs);
    }

    ~this()
    {
        this.close();
    }
    void close()
    {
        if(_opened) {
            stderr.writeln("Close Server...");
            kill(_pid);
            _pid.wait();
            stderr.writeln("Server closed");
            _opened = false;
        }
    }

};
module drocks.backupunit;
import std.conv : to;

struct BackupUnit
{
    size_t id;        //: 7
    size_t timestamp; //: 1548151594
    string time;      //: 22.01.2019 15:06:34 +0500
    size_t size;      //: 10482

    this(const string[] args)
    {
        assert(4 == args.length);
        //["id: 1", "timestamp: 1547966392", "time: 20.01.2019 11:39:52 +0500", "size: 7222"]
        id        = args[0]["id: "       .length..$].to!size_t;
        timestamp = args[1]["timestamp: ".length..$].to!size_t;
        time      = args[2]["time: "     .length..$];
        size      = args[3]["size: "     .length..$].to!size_t;
    }
}

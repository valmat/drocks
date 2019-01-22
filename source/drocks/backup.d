module drocks.backup;

import std.conv      : to;
import std.range     : array, slide;
import std.algorithm : map;

import drocks.response : Response;


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

struct BackupUnitsRange
{
    alias Range = typeof(makeRange(Response.init));
    Range _range;
    size_t _size;

    private static
    auto makeRange(Response resp)
    {
        return resp
            .getMultiKey
            .array
            .slide(5, 5)
            .map!"a[0..4]"
            //.map!(x => x.map!( el => el.split(": ")[1] ) )
            .map!(args => args.BackupUnit);
    }

    this(Response resp)
    {
        _size  = resp.getKey.to!size_t;
        _range = makeRange(resp);
    }

    size_t length() const
    {
        return _size;
    }
    bool empty()
    {
        return _range.empty;
    }
    auto front()
    {
        return _range.front;
    }
    void popFront()
    {
        _range.popFront;
    }
}

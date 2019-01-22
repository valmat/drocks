module customclient;
import std.conv: to;
import drocks;

struct CustomClient
{
    mixin ExtendClient;

    // incriment value by key
    long getIncr(string key, long value)
    {
        return _db.request.httpPost("get-incr", key ~ "\n" ~ value.to!string ).getValue().to!long;
    }
    long getIncr(string key)
    {
        return _db.request.httpPost("get-incr", key).getValue().to!long;
    }

    // Check if DB server is available
    bool ping() //const
    {
        return "pong" == _db.request.httpGet("ping").raw();
    }

    // Seack first pair by key prefix
    auto seekFirst(string prefix)
    {
        return _db.request.httpGet("seek-first", prefix).getPair();
    }

    // retrive wide server statistics
    // Posible option values are: 
    // "stats", "sstables", "num-files-at-level0", "num-files-at-level1"
    auto wstats(string option)
    {
        return _db.request.httpPost("wstats", option).raw;
    } 
}

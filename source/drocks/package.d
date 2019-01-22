module drocks;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.conv;
import std.socket;

public import drocks.exception : ClientException;
//import drocks.response         : Response;
import drocks.request          : Request;
import drocks.pair             : Pair;
import drocks.multivalue       ;//: MultiValue;

struct Client
{
private:
    // Requestes handler
    Request _req;
public:
    this(string host, ushort port)
    {
        _req = Request(host, port);
    }
    @disable this ();

    static Client createDefault()
    {
        return Client("localhost", 5533);
    }

    // get value by key
    string get(string key) {
        return _req.httpGet("get", key).getValue();
        //return _req.httpGet("get", key).raw();
    }

    // multi get key-value pairs by keys
    auto mget(Range)(Range range) {
        //return _req.httpGet("mget", range).raw();//
        return _req.httpGet("mget", range).getMultiPair();
    }

    // set value for key
    bool set(string key, string val) {
        return this.set(Pair(key, val));
    }
    bool set(Pair pair) {
        //return _req.httpPost("set", pair.serialize()).raw();
        return _req.httpPost("set", pair.serialize()).isOk();
    }

    // remove key from db
    bool del(string key) {
        return _req.httpPost("del", key).isOk();
    }
    

    static struct KeyExist
    {
        bool   exist;
        string value;
        alias exist this;
    }
    // Check if key exist
    KeyExist exist(string key) {
        auto resp = _req.httpGet("exist", key);
        bool rez  = resp.isOk();
        return !rez ? 
            KeyExist(rez) :
            KeyExist(rez, resp.getValue());
    }
    

}



// test:
// cd source
// rdmd -unittest -main --force drocks/package
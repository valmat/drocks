module drocks.client;

import std.stdio : stderr, writeln;
import std.range   : join, isInputRange, ElementType;
import std.traits  : isIntegral;
import std.conv    : to;

import drocks.exception : ClientException;
import drocks.request   : Request;
import drocks.pair      : Pair;
import drocks.backup    : BackupUnitsRange;

struct Client
{
private:
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

    ref Request request()
    {
        return _req;
    }

    // get value by key
    string get(string key)
    {
        return _req.httpGet("get", key).getValue();
    }

    // multi get key-value pairs by keys
    auto get(Range)(auto ref Range range)
        if(isInputRange!Range && is(ElementType!Range == string))
    {
        return _req.httpGet("mget", range).getMultiPair();
    }

    auto get(Args...)(auto ref Args args)
        if(Args.length > 1 && is(Args[0] == string))
    {
        return _req.httpGet("mget", args).getMultiPair();
    }

    // set value for key
    bool set(string key, string val)
    {
        return this.set(Pair(key, val));
    }
    bool set(Pair pair)
    {
        return _req.httpPost("set", pair.serialize()).isOk();
    }

    // multi set values for keys
    bool set(Range)(auto ref Range pairs)
        if(isInputRange!Range && is(ElementType!Range == Pair))
    {
        return _req.httpPost("mset", pairs).isOk();
    }

    // remove key from db
    bool del(string key)
    {
        return _req.httpPost("del", key).isOk();
    }

    // Multi range of keys from db
    bool del(Range)(auto ref Range keys)
        if(isInputRange!Range && is(ElementType!Range == string))
    {
        return _req.httpPost("mdel", keys).isOk();
    }

    auto del(Args...)(auto ref Args args)
        if(Args.length > 1 && is(Args[0] == string))
    {
        return _req.httpPost("mdel", args).isOk();
    }


    // incriment value by key
    bool incr(string key, long value)
    {
        return _req.httpPost("incr", key, value ).isOk();
    }
    bool incr(string key)
    {
        return _req.httpPost("incr", key).isOk();
    }

    // multi get all key-value pairs (by key-prefix)
    auto getall(string prefix)
    {
        return _req.httpGet("prefit", prefix).getMultiPair();
    }

    // multi get all key-value pairs
    auto getall()
    {
        return _req.httpGet("tail").getMultiPair();
    }

    // Make database backup
    bool backup()
    {
        return _req.httpPost("backup").isOk();
    }

    // Make database backups info
    auto backupInfo()
    {
        return _req.httpPost("backup/info").BackupUnitsRange;
    }

    // Remove backup by ID
    bool backupDel(size_t id)
    {
        return _req.httpPost("backup/del", id).isOk;
    }

    // Remove backup by IDs
    auto backupDel(Range)(auto ref Range ids)
        if(isInputRange!Range && isIntegral!(ElementType!Range))
    {
        return _req.httpPost("backup/mdel", ids).getMultiBool();
    }

    // retrive server statistics
    string stats()
    {
        return _req.httpPost("stats").raw;
    }   

    static struct KeyExist
    {
        bool   has;
        string value;
        alias has this;
    }
    // Check if key exist
    KeyExist has(string key) {
        auto resp = _req.httpGet("exist", key);
        bool rez  = resp.isOk();
        return !rez ? 
            KeyExist(rez) :
            KeyExist(rez, resp.getValue());
    }

    //
    // Implementation array access overloading
    //
    // https://dlang.org/spec/operatoroverloading.html
    // get by db[...]
    auto opIndex(Args...)(auto ref Args args)
    {
        return this.get(args);
    }
    // set by db[...] = ...
    auto opIndexAssign(string val, string key)
    {
        return this.set(key, val);
    }
    // db[...] += ...
    bool opIndexOpAssign(string op)(long value, string key)
        if("+" == op)
    {
        return incr(key, value);
    }
    // db[...] += ...
    bool opIndexOpAssign(string op)(long value, string key)
        if("-" == op)
    {
        return incr(key, -value);
    }

    // ++db[...]
    bool opIndexUnary(string op)(string key)
        if("++" == op)
    {
        return incr(key);
    }
    // --db[...]
    bool opIndexUnary(string op)(string key)
        if("--" == op)
    {
        return incr(key, -1);
    }

}

//
// This mixin allows to extend struct Client
// 
//Example:
//struct CustomClient
//{
//    mixin ExtendClient;
//    long getCastom(string key)
//    {
//        return _db.request.httpGet("castom", key).getValue();
//    }
//}
//

mixin template ExtendClient()
{
private:
    alias __ThisType = typeof(this);
    Client _db;
public:
    alias _db this;

    this(string host, ushort port)
    {
        _db = Client(host, port);
    }
    //@disable this ();

    static __ThisType createDefault()
    {
        __ThisType rez = __ThisType.init;
        rez._db = Client.createDefault();
        return rez;
    }

    auto opDispatch(string methodName, Args...)(Args args) {
        return mixin("_db." ~ methodName)(args);
    }
}

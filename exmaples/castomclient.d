module castomclient;

import std.stdio;
import std.typecons;
import std.range : join;
import std.socket;
import std.string;
import std.conv : to;
import std.socket;
import std.algorithm : map;

//import     : BackupUnitsRange;

import drocks;

struct CastomClient
{
private:
    // Requestes handler
    Client _db;
public:
    alias _db this;

    this(string host, ushort port)
    {
        _db = Client(host, port);
    }
    //@disable this ();

    static CastomClient createDefault()
    {
        CastomClient rez = CastomClient.init;
        rez._db = Client.createDefault();
        return rez;
    }

    auto opDispatch(string methodName, Args...)(Args args) {
        writeln("called ", methodName);
        return mixin("_db." ~ methodName)(args);
    }

    //// get value by key
    //string get(string key) {
    //    return _req.httpGet("get", key).getValue();
    //    //return _req.httpGet("get", key).raw();
    //}

    //// multi get key-value pairs by keys
    //auto mget(Range)(Range range) {
    //    //return _req.httpGet("mget", range).raw();//
    //    return _req.httpGet("mget", range).getMultiPair();
    //}

    //// set value for key
    //bool set(string key, string val) {
    //    return this.set(Pair(key, val));
    //}
    //bool set(Pair pair) {
    //    //return _req.httpPost("set", pair.serialize()).raw();
    //    return _req.httpPost("set", pair.serialize()).isOk();
    //}

    //// remove key from db
    //bool del(string key) {
    //    return _req.httpPost("del", key).isOk();
    //}

    //// multi set values for keys
    //bool mset(Range)(Range pairs) {
    //    //pairs.writeln;
    //    string data = pairs
    //        .map!( (Pair x) {return x.serialize;})
    //        .join("\n");

    //    //[[_req.httpPost("mset", data).raw]].writeln;
    //    return _req.httpPost("mset", data).isOk();
    //    //return true;
    //}

    //// Multi range of keys from db
    //bool mdel(Range)(Range keys) {
    //    string data = keys.join("\n");
    //    //data.writeln;
    //    //[[_req.httpPost("mdel", data).raw]].writeln;
    //    return _req.httpPost("mdel", data).isOk();
    //    //return true;
    //}

    //// incriment value by key
    //bool incr(string key, int value) {
    //    return _req.httpPost("incr", key ~ "\n" ~ value.to!string ).isOk();
    //}
    //bool incr(string key) {
    //    return _req.httpPost("incr", key).isOk();
    //}

    ///**
    //  *  
    //  *  @return MgetIterator
    //  */
    //// multi get all key-value pairs (by key-prefix)
    //auto getall(string prefix) {
    //    //return _req.httpGet("prefit", prefix).raw();
    //    return _req.httpGet("prefit", prefix).getMultiPair();
    //}

    //// multi get all key-value pairs
    //auto getall() {
    //    //return _req.httpGet("tail").raw();
    //    return _req.httpGet("tail").getMultiPair();
    //}

    //// Make database backup
    //bool backup() {
    //    //return _req.httpPost("backup").raw();
    //    return _req.httpPost("backup").isOk();
    //}

    //// Make database backups info
    //auto backupInfo() {
    //    return _req.httpPost("backup/info").BackupUnitsRange;
    //}

    //// Remove backup by ID
    //bool backupDel(size_t id) {
    //    return _req.httpPost("backup/del", id.to!string).isOk;
    //}

    //// Remove backup by ID
    //auto backupMdel(Range)(Range ids) {
    //    string data = ids
    //        .map!"a.to!string"
    //        .join('\n');

    //    return _req.httpPost("backup/mdel", data)
    //        .getMultiKey
    //        .map!`a == "OK"`;
    //}

    //// retrive server statistics
    //auto stats() {
    //    return _req.httpPost("stats").raw;
    //}


    

    //static struct KeyExist
    //{
    //    bool   has;
    //    string value;
    //    alias has this;
    //}
    //// Check if key exist
    //KeyExist has(string key) {
    //    auto resp = _req.httpGet("exist", key);
    //    bool rez  = resp.isOk();
    //    return !rez ? 
    //        KeyExist(rez) :
    //        KeyExist(rez, resp.getValue());
    //}
    

}



// test:
// cd source
// rdmd -unittest -main --force drocks/package
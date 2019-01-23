#!/usr/bin/rdmd --shebang=-I../source -I.  -I./modules

import std.stdio    ;
import std.typecons ;//: Tuple, tuple;
import std.range    ;//: array;
import std.file;//.tempDir
import std.random;
import std.string;
import std.conv : to;
import std.algorithm;
import std.algorithm  : splitter, joiner;
import std.range      : enumerate;
import std.string     : indexOf, strip;
import std.functional : forward;
import std.stdio      : File;
import std.conv : to;
import std.getopt;
import std.path : buildPath;

import drocks;
import ini;



struct c {
    @disable this();
    @disable this(this);
    enum string reset   = "\033[0m";
    enum string red     = "\033[1m\033[31m";
    enum string green   = "\033[1m\033[32m";
    enum string yellow  = "\033[1m\033[33m";
    enum string blue    = "\033[1m\033[34m";
}

void main(string[] args)
{
    auto rnd     = Random(unpredictableSeed);
    auto rnd_pfx = uniform(0, int.max, ).to!string;

    string serverBinary = "/usr/local/bin/rocksserver";
    //string configFile   = "/etc/rocksserver/config.ini";
    string configFile;
    
    string tmpDir       = tempDir() ~ "/rocksserver." ~ rnd_pfx;

    string host;
    string port;



//auto rnd = rndGen;
//rnd.take(3).writeln;

//auto rnd1 = ;
//// Generate an integer in [0, 1023]
//auto a = ;
//a.writeln;

    auto helpInformation = getopt(args,
        "binary|b", 
        "RocksServer binary file location." ~
        "\n\t\tDefault: \"" ~ serverBinary ~"\"",
        &serverBinary,

        "config|c",
        "RocksServer config file location." ~
        "\n\t\tBy default created automatically",
        &configFile,

        "tmp|t",
        "temporary dir." ~
        "\n\t\tDefault: \"" ~ tmpDir ~"\"\n",
        &tmpDir,
        
        "host|s",
        "DB host. If did not specified use default.\n",
        &host,
        
        "port|p",
        "DB host. If did not specified use default.\n",
        &port
    );
    

    if (helpInformation.helpWanted) {
        defaultGetoptPrinter(
            "Some information about the program.", 
            helpInformation.options
        );
        return;
    }

    //if(tmpDirDflt == tmpDir) {

    //}
    //tmpDir = ;


    writeln( c.yellow, "__________________________________________________________________", c.reset);
    writeln( c.yellow, "RocksServer binary file location          :", c.green, serverBinary, c.reset);
    writeln( c.yellow, "RocksServer config file location          :", c.green, configFile  , c.reset);
    writeln( c.yellow, "temporary dir                             :", c.green, tmpDir      , c.reset);
    writeln( c.yellow, "DB host. If did not specified use default :", c.green, host        , c.reset);
    writeln( c.yellow, "DB host. If did not specified use default :", c.green, port        , c.reset);
    writeln( c.yellow, "__________________________________________________________________", c.reset);

    string[string] cfgMap = configFile.file2map;
    [cfgMap].writeln;


    cfgMap["log_level"]      = "debug"; 
    cfgMap["error_log"]      = tmpDir ~ "/error.log"; 
    cfgMap["backup_path"]    = tmpDir ~ "/backup"; 
    cfgMap["extdir"]         = tmpDir ~ "/plugins";
    cfgMap["db_path"]        = tmpDir ~ "/db";

    if(host.length) {
        cfgMap["server_host"] = host;
    }
    if(host.length) {
        cfgMap["server_port"] = port;
    }

    [cfgMap].writeln;
    
    string configFileNew = tmpDir ~ "/configs.ini";



    writeln( c.yellow, "__________________________________________________________________", c.reset);
    writeln( c.blue, "RocksServer options:", c.reset);
    foreach(key, ref val; cfgMap) {
        writeln( c.yellow, key.leftJustifier(20, ' '), " : ", c.green, val, c.reset);
    }
    writeln( c.yellow, "__________________________________________________________________", c.reset);



    //auto nested = dir.buildPath("a", "b", "c");
    //nested.mkdirRecurse;


    cfgMap["backup_path"] .buildPath.mkdirRecurse; 
    cfgMap["extdir"]      .buildPath.mkdirRecurse;
    cfgMap["db_path"]     .buildPath.mkdirRecurse;
    
    // Create INI configs file
    cfgMap.map2file(configFileNew);







    auto db = Client.createDefault();

    try {
        //writeln(`[db.get("key1")]:`);
        //[db.get("key1")].writeln;
        //writeln(`[db.get("key2")]:`);
        //[db.get("key2")].writeln;
        //writeln(`[db.get("key3")]:`);
        //[db.get("key3")].writeln;

        //writeln(`[db.get("key1", "key2", "keyq")]:`);
        //[db.get("key1", "key2", "keyq")].writeln;

        //writeln(`[ db["key1"] ]:`);
        //[ db["key1"] ].writeln;
        //writeln(`[ db["key1", "key2", "keyq"] ]:`);
        //[ db["key1", "key2", "keyq"] ].writeln;

        //writeln(`[ db["key1"] ]:`);
        //writeln(db["key2del_"] = "KeyToDel_");
        //writeln(`[ db["key1", "key2", "keyq"] ]:`);
        //[ db["key1", "key2", "keyq"] ].writeln;

        //writeln(`[db.set("keyq", "QQQqqqQQQ")]:`);
        //[db.set("keyq", "QQQqqqQQQ")].writeln;
        //writeln(`[db.get("keyq")]:`);
        //[db.get("keyq")].writeln;

        //writeln(`[db.has("keyq")]:`);
        //[db.has("keyq")].writeln;
        //[db.has("keyq").has].writeln;
        //[db.has("keyq").value].writeln;

        //auto a = db.get(["key1","key2","key3",]).array;
        //a.writeln;
        //[db.get(["key1","key2","key3",])].writeln;

        //writeln(`[db.set("key2del", "KeyToDel")]:`);
        //[db.set("key2del", "KeyToDel")].writeln;
        //writeln(`[db.get("key2del")]:`);
        //[db.get("key2del")].writeln;
        //writeln(`[db.del("key2del")]:`);
        //[db.del("key2del")].writeln;
        //writeln(`[db.get("key2del")]:`);
        //[db.get("key2del")].writeln;

        //`[db.set(["key-1","key-2","key-3",])]`.writeln;
        //[db.set([
        //    Pair("key-1", "val-1"),
        //    Pair("key-2", "val-2"),
        //    Pair("key-3", "val-3"),
        //])].writeln;
        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;


        //`[db.set(["key-1","key-2","key-3",])]`.writeln;
        //[db.set([
        //    tuple("key-1", "val-1@"),
        //    tuple("key-2", "val-2@"),
        //    tuple("key-3", "val-3@"),
        //])].writeln;
        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;

        //`[db.set(["key-1","key-2","key-3",])]`.writeln;
        //[db.set([
        //    "key-1" : "val-1*",
        //    "key-2" : "val-2*",
        //    "key-3" : "val-3*",
        //])].writeln;
        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;

        //`[db.del(["key-1","key-2","key-3",])]`.writeln;
        ////[db.del(["key-1","key-2","key-3",])].writeln;
        //[db.del("key-1","key-2","key-3")].writeln;

        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;

        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;

        //`[db.incr]`.writeln;
        //[db.incr("incr1"     )].writeln;
        //[db.incr("incr2",   5)].writeln;
        //[db.incr("incr3", -11)].writeln;
        //writeln(`[db.get("incr1")]:`);
        //[db.get("incr1")].writeln;
        //writeln(`[db.get("incr2")]:`);
        //[db.get("incr2")].writeln;
        //writeln(`[db.get("incr3")]:`);
        //[db.get("incr3")].writeln;

        //`[db.incr]`.writeln;
        //( db["incr4"] += 7 ).writeln;
        //`[db.get("incr4")]:`.writeln;
        //[db.get("incr4")].writeln;
        //( db["incr4"] += -4 ).writeln;
        //[db.get("incr4")].writeln;
        //( db["incr4"] -= 1 ).writeln;
        //[db.get("incr4")].writeln;
        //( ++db["incr4"] ).writeln;
        //[db.get("incr4")].writeln;
        //( --db["incr4"] ).writeln;
        //[db.get("incr4")].writeln;


        //`[ db["key1","key2","key3"] ]`.writeln;
        //[ db["key1","key2","key3"] ].writeln;


        //writeln(`[db.getall("key")]:`);
        //[db.getall("key").array].writeln;
        //writeln(`[db.getall()]:`);
        //[db.getall().array].writeln;

        //writeln(`[db.backup()]:`);
        //[db.backup()].writeln;

        //writeln(`[db.backupInfo()]:`);
        //[db.backupInfo().array].writeln;
        ////db.backupInfo().writeln;
        //[db.backupInfo().length].writeln;

        //writeln(`[db.backupDel(8)]:`);
        //[db.backupDel(8)].writeln;

        //writeln(`[db.backupDel([12, 13, 15, 2])]:`);
        //[db.backupDel([12, 13, 15, 2]).array].writeln;
        
        //writeln(`[db.stats()]:`);
        //db.stats().writeln;

        
        //writeln(`[db.get(["empty", "incr1"]).array]:`);
        //[db.get(["empty", "incr1"]).array].writeln;

    } catch (ClientException e) {
        writeln([e.msg, e.file], e.line);
    }
    
}
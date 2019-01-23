#!/usr/bin/rdmd --shebang=-I../source -I.  -I./modules

import std.stdio    ;
import std.typecons ;//: Tuple, tuple;
import std.range    ;//: array;
import std.file;//.tempDir
import std.random;
import std.string;
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
import server : ServerRunner;
static import c;
import opts;
import check : checkTest, headTest;

bool not(bool x) {return !x;}

void main(string[] args)
{
    auto opts = Opts(args);
    if (!opts.valid) {
        return;
    }
    opts.show();

    auto server = ServerRunner(opts.servOpts);

    try {
        
        //auto db = Client(host, opts.port.to!ushort);
        auto db = Client("127.0.0.1", opts.port.to!ushort);

        //
        // Now DB is empty
        //
        headTest("Get on empty base");
        {
            db.get("key1")
                .equal("")
                .checkTest(`db.getall("") on empty base`);

            db.getall("key")
                .equal(Pair[].init)
                .checkTest(`db.getall("key") on empty base`);

            db.getall()
                .equal(Pair[].init)
                .checkTest(`db.getall("") on empty base`);

            db.del("key2del")
                .checkTest(`db.del("key2del") on empty base`);
        }
        
        //
        // Set keys
        //
        headTest("Single set & get");
        {
            
            db.set("dgdg", "QQQqqqQQQ")
                .checkTest(`Single set by key & value`);

            db.get("dgdg")
                .equal("QQQqqqQQQ")
                .checkTest(`Single get & Check previous`);


            auto pair = Pair("hyhy", "JfTdW");
            db.set(pair)
                .checkTest(`Single set by Pair`);

            db.get(pair.key)
                .equal(pair.value)
                .checkTest(`Single get & Check previous`);

        }

        headTest("Set Pairs range");
        {
            auto range = [
                Pair("key:1:_1", "val-1(1)"),
                Pair("key:1:_2", "val-2(1)"),
                Pair("key:1:_3", "val-3(1)"),
            ];
            auto keys   = range.map!(x => x.key);

            db.set(range)
                .checkTest(`db.set(range) Set Pairs range`);

            db.get(keys)
                .equal(range)
                .checkTest(`Get range & Check previous`);
        }

        headTest("Set tuples range");
        {
            auto range = [
                tuple("key:2:_1", "val-1@2"),
                tuple("key:2:_2", "val-2@2"),
                tuple("key:2:_3", "val-3@2"),
            ];
            auto range1 = range.map!(x => Pair(x));
            auto keys   = range1.map!(x => x.key);

            db.set(range)
                .checkTest(`db.set(range) Set tuples range`);

            db.get(keys)
                .equal(range1)
                .checkTest(`Get range & Check previous`);
        }

        headTest("Set map");
        {
            auto map = [
                "key:3:*1" : "val-1*",
                "key:3:*2" : "val-2*",
                "key:3:*3" : "val-3*",
            ];
            auto range = map.byPair.map!(x => Pair(x));
            auto keys   = map.byKey;

            db.set(map)
                .checkTest(`db.set(range) Set map`);

            db.get(keys)
                .equal(range)
                .checkTest(`Get range & Check previous`);
        }

        headTest("Set map");
        {
            auto map = [
                "key:3:*1" : "val-1*",
                "key:3:*2" : "val-2*",
                "key:3:*3" : "val-3*",
            ];
            auto range = map.byPair.map!(x => Pair(x));
            auto keys   = map.byKey.array;

            db.set(map)
                .checkTest(`db.set(range) Set map`);

            db.get(keys)
                .equal(range)
                .checkTest(`Get array & (Check previous)`);
        }

        headTest("Get multiargs");
        {
            auto range = [
                Pair("key:1:_1", "val-1(1)"),
                Pair("key:1:_2", "val-2(1)"),
                Pair("key:1:_3", "val-3(1)"),
            ];

            db.get("key:1:_1", "key:1:_2", "key:1:_3")
                .equal(range)
                .checkTest(`db.get("key:1:_1", "key:1:_2", "key:1:_3")`);
        }

        headTest("Keys existing");
        {
            db.has("key:1:_1")
                .checkTest(`db.has(existentKey)`);

            db.has("key:1:_2").has
                .checkTest(`db.has(existentKey).has`);

            db.has("key:1:_2").value
                .equal("val-2(1)")
                .checkTest(`db.has(existentKey).value`);

            db.has("key:1:_4")
                .not
                .checkTest(`db.has(missingKey)`);

            db.has("key:1:_5").has
                .not
                .checkTest(`db.has(missingKey).has`);

            db.has("key:1:_5").value
                .equal("")
                .checkTest(`db.has(missingKey).value`);
        }

        headTest("Single delete");
        {
            db.set(["key2del": "KeyToDel"])
                .checkTest(`set("key2del")`);

            db.get("key2del")
                .equal("KeyToDel")
                .checkTest(`Single get & Check previous`);

            db.del("key2del")
                .checkTest(`Single del`);

            db.get("key2del")
                .equal("")
                .checkTest(`Single get & Check previous`);

            db.has("key2del")
                .not
                .checkTest(`Check previous`);

        }

        headTest("Multi delete");
        {
            auto range = [
                Pair("delme_1", "ToDel*1"),
                Pair("delme_2", "ToDel*2"),
                Pair("delme_3", "ToDel*3"),
                Pair("delme_4", "ToDel*3"),
            ];
            auto keys   = range.map!(x => x.key);
            auto values = range.map!(x => x.value);
            auto empty  = range.map!(x => Pair(x.key));

            // multiargs del
            db.set(range)
                .checkTest(`set("range")`);

            db.get(keys)
                .equal(range)
                .checkTest(`Check previous`);

            db.del("delme_1","delme_2","delme_3","delme_4")
                .checkTest(`multiargs del`);

            db.get(keys)
                .equal(empty)
                .checkTest(`Check previous`);

            db.has("delme_2")
                .not
                .checkTest(`Check previous`);

            // range del
            db.set(range)
                .checkTest(`set("range")`);

            db.get(keys)
                .equal(range)
                .checkTest(`Check previous`);

            db.del(keys)
                .checkTest(`multiargs del`);

            db.get(keys)
                .equal(empty)
                .checkTest(`Check previous`);

            db.has("delme_4")
                .not
                .checkTest(`Check previous`);
        }

        headTest("Ingrements keys");
        {
            db.incr("incr1")
                .checkTest(`Check increment`);

            db.incr("incr2", 5)
                .checkTest(`Check increment`);

            db.incr("incr3", -11)
                .checkTest(`Check derement`);

            db.get("incr1")
                .equal("1")
                .checkTest(`Check previous`);

            db.get("incr2")
                .equal("5")
                .checkTest(`Check previous`);

            db.get("incr3")
                .equal("-11")
                .checkTest(`Check previous`);
        }

        headTest("Array access overloading");
        {
            //auto values = [
            //    "\r\n1\n%%%\t^\n",
            //    "\r\n2\n%%%\t^\n",
            //    "\r\n3\n%%%\t^\n",
            //];
            auto range = [
                Pair("pref:_0_", "\r\n1\n%%%\t^\n"),
                Pair("pref:_1_", "\r\n2\n%%%\t^\n"),
                Pair("pref:_2_", "\r\n3\n%%%\t^\n"),
            ];
            //auto keys = range.map!(x => x.key);
            auto keys   = range.map!(x => x.key);
            auto values = range.map!(x => x.value);


            db.set(range)
                .checkTest(`set("range")`);

            db[keys[0]]
                .equal(values[0])
                .checkTest(`db[key]`);

            db[keys[0], keys[1]]
                .equal(range[0..2])
                .checkTest(`db[key1, key2]`);

            db[keys]
                .equal(range)
                .checkTest(`db[keysRange]`);

            keys[0..2]
                .writeln;

            db[keys[1..2]]
                .writeln;
                //.equal(values[0])
                //.checkTest(`db[key]`);





 
        }

        headTest("array access overloading");
        {

        }





        /*
        {
            auto range = [
                Pair("key:1:_1", "val-1(1)"),
                Pair("key:1:_2", "val-2(1)"),
                Pair("key:1:_3", "val-3(1)"),
            ];
            auto keys   = range.map!(x => x.key);

            db.set(range)
                .checkTest(`db.set(range) Set Pairs range`);

            db.get(keys)
                .equal(range)
                .checkTest(`Get range & Check previous`);

        }
        */




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


        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;

        //`[db.get(["key-1","key-2","key-3",])]`.writeln;
        //[db.get(["key-1","key-2","key-3",])].writeln;


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
    } catch (Exception e) {
        writeln([e.msg, e.file], e.line);
    }



    
}
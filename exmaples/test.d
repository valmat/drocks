#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio;
import std.typecons;
import std.range;
import drocks;


void main()
{
    auto db = Client.createDefault();

    try {
        //writeln(`[db.get("key1")]:`);
        //[db.get("key1")].writeln;
        //writeln(`[db.get("key2")]:`);
        //[db.get("key2")].writeln;
        //writeln(`[db.get("key3")]:`);
        //[db.get("key3")].writeln;

        //writeln(`[db.set("key q", "QQQ QQQ")]:`);
        //[db.set("keyq", "QQQ QQQ")].writeln;
        //writeln(`[db.set("keyq", "QQQqqqQQQ")]:`);
        //[db.set("keyq", "QQQqqqQQQ")].writeln;
        //writeln(`[db.get("keyq")]:`);
        //[db.get("keyq")].writeln;

        //writeln(`[db.exist("keyq")]:`);
        //[db.exist("keyq")].writeln;
        //[db.exist("keyq").exist].writeln;
        //[db.exist("keyq").value].writeln;

        //auto a = db.mget(["key1","key2","key3",]).array;
        //a.writeln;
        //[db.mget(["key1","key2","key3",])].writeln;

        //writeln(`[db.set("key2del", "KeyToDel")]:`);
        //[db.set("key2del", "KeyToDel")].writeln;
        //writeln(`[db.get("key2del")]:`);
        //[db.get("key2del")].writeln;
        //writeln(`[db.del("key2del")]:`);
        //[db.del("key2del")].writeln;
        //writeln(`[db.get("key2del")]:`);
        //[db.get("key2del")].writeln;

        

    } catch (ClientException e) {
        writeln([e.msg, e.file], e.line);
    }
    
}
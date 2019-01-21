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
        //[db.set("key q", "QQQ QQQ")].writeln;
        //writeln(`[db.set("keyq", "QQQqqqQQQ")]:`);
        //[db.set("key q", "QQQqqqQQQ")].writeln;
        //writeln(`[db.get("keyq")]:`);
        //[db.get("keyq")].writeln;

        //writeln(`[db.exist("keyq")]:`);
        //[db.exist("keyq")].writeln;
        //[db.exist("keyq").exist].writeln;
        //[db.exist("keyq").value].writeln;

        //db.mget(["key1","key2","key3",]);
        [db.mget(["key1","key2","key3",])].writeln;

        

    } catch (ClientException e) {
        writeln([e.msg, e.file], e.line);
    }
    
}
#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio;
import std.typecons;
import std.range;
import drocks;

void main()
{
    auto db = Client.createDefault();

    try {
        writeln(`[db.get("key1")]:`);
        [db.get("key1")].writeln;
        writeln(`[db.get("key2")]:`);
        [db.get("key2")].writeln;
        writeln(`[db.get("key3")]:`);
        [db.get("key3")].writeln;

        writeln(`[db.set("key q", "QQQ QQQ")]:`);
        [db.set("keyq", "QQQ QQQ")].writeln;
        writeln(`[db.set("keyq", "QQQqqqQQQ")]:`);
        [db.set("keyq", "QQQqqqQQQ")].writeln;
        writeln(`[db.get("keyq")]:`);
        [db.get("keyq")].writeln;

        writeln(`[db.has("keyq")]:`);
        [db.has("keyq")].writeln;
        [db.has("keyq").has].writeln;
        [db.has("keyq").value].writeln;

        auto a = db.get(["key1","key2","key3",]).array;
        a.writeln;
        [db.get(["key1","key2","key3",])].writeln;

        writeln(`[db.set("key2del", "KeyToDel")]:`);
        [db.set("key2del", "KeyToDel")].writeln;
        writeln(`[db.get("key2del")]:`);
        [db.get("key2del")].writeln;
        writeln(`[db.del("key2del")]:`);
        [db.del("key2del")].writeln;
        writeln(`[db.get("key2del")]:`);
        [db.get("key2del")].writeln;

        `[db.mset(["key-1","key-2","key-3",])]`.writeln;
        [db.mset([
            Pair("key-1", "val-1"),
            Pair("key-2", "val-2"),
            Pair("key-3", "val-3"),
        ])].writeln;
        `[db.get(["key-1","key-2","key-3",])]`.writeln;
        [db.get(["key-1","key-2","key-3",])].writeln;

        `[db.mdel(["key-1","key-2","key-3",])]`.writeln;
        [db.mdel(["key-1","key-2","key-3",])].writeln;
        `[db.get(["key-1","key-2","key-3",])]`.writeln;
        [db.get(["key-1","key-2","key-3",])].writeln;

        `[db.get(["key-1","key-2","key-3",])]`.writeln;
        [db.get(["key-1","key-2","key-3",])].writeln;

        `[db.incr]`.writeln;
        [db.incr("incr1"     )].writeln;
        [db.incr("incr2",   5)].writeln;
        [db.incr("incr3", -11)].writeln;
        writeln(`[db.get("incr1")]:`);
        [db.get("incr1")].writeln;
        writeln(`[db.get("incr2")]:`);
        [db.get("incr2")].writeln;
        writeln(`[db.get("incr3")]:`);
        [db.get("incr3")].writeln;

        writeln(`[db.getall("key")]:`);
        [db.getall("key").array].writeln;
        writeln(`[db.getall()]:`);
        [db.getall().array].writeln;

        writeln(`[db.backup()]:`);
        [db.backup()].writeln;

        writeln(`[db.backupInfo()]:`);
        [db.backupInfo().array].writeln;
        //db.backupInfo().writeln;
        [db.backupInfo().length].writeln;

        writeln(`[db.backupDel(8)]:`);
        [db.backupDel(8)].writeln;

        writeln(`[db.backupMdel([12, 13, 15, 2])]:`);
        [db.backupMdel([12, 13, 15, 2]).array].writeln;
        
        //writeln(`[db.stats()]:`);
        //db.stats().writeln;

        




        //writeln(`[db.get(["empty", "incr1"]).array]:`);
        //[db.get(["empty", "incr1"]).array].writeln;

        


        

    } catch (ClientException e) {
        writeln([e.msg, e.file], e.line);
    }

    //import core.thread: Thread, seconds;
    //writeln(`###########################################`);
    //Thread.sleep(2.seconds);

    
}
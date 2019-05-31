#!/usr/bin/rdmd --shebang=-I../source -I.  -I./modules

import std.stdio     : writeln;
import std.typecons  : Tuple, tuple;
import std.range     : array, byPair;
import std.algorithm : map, equal;
import std.conv      : to;

import drocks;
import opts   : Opts;
import server : ServerRunner;
import check  : checkTest, headTest;

bool not(T)(auto ref T x) {return !x;}
bool eq(T)(auto ref T lhs, auto ref T rhs) {return lhs == rhs;}

//bool equal(T)(auto ref T lhs, auto ref T rhs)
//    if (!isInputRange!T)
//{return lhs == rhs;}
//bool equal(T1, T2)(auto ref T1 lhs, auto ref T2 rhs)
//    if (isInputRange!T1 && isInputRange!T2)
//{return .equal(lhs, rhs);}

int main(string[] args)
{
    auto opts = Opts(args);
    if (!opts.valid) {
        return 1;
    }
    opts.show();

    auto server = ServerRunner(opts.servOpts);

    try {
        auto db = Client(opts.host, opts.port.to!ushort);

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

        headTest("Replace key");
        {
            db.set("key:3:*2", "**val-2##")
                .checkTest(`db.set(key)`);

            db.get("key:3:*2")
                .equal("**val-2##")
                .checkTest(`Check replaced key`);
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

        headTest("Increments keys");
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
            auto range = [
                Pair("pref:_0_", "\r\n1\n%%%\t^\n"),
                Pair("pref:_1_", "\r\n2\n%%%\t^\n"),
                Pair("pref:_2_", "\r\n3\n%%%\t^\n"),
            ];
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
        }

        headTest("Array access overloading Assign");
        {
            auto pair = Pair("pref:_4_", "\n4\n%\t^%%\n\r");
            (db[pair.key] = pair.value)
                .checkTest(`db[key] = value`);

            db[pair.key]
                .equal(pair.value)
                .checkTest(`db[key]`);
        }

        headTest("Array access increment");
        {
            auto v = uint.max.to!string;

            (++db["incr4"])
                .checkTest(`++db[key]`);

            db["incr4"]
                .equal("1")
                .checkTest(`Check previous`);

            //
            (--db["incr5"])
                .checkTest(`--db[key]`);

            db["incr5"]
                .equal("-1")
                .checkTest(`Check previous`);

            //
            (db["incr6"] += uint.max)
                .checkTest(`db[key] +=...`);

            db["incr6"]
                .equal(v)
                .checkTest(`Check previous`);

            //
            (db["incr7"] += 0UL - uint.max)
                .checkTest(`db[key] +=...`);

            db["incr7"]
                .equal("-" ~ v)
                .checkTest(`Check previous`);

            //
            (db["incr8"] -= uint.max)
                .checkTest(`db[key] -=...`);

            db["incr8"]
                .equal("-" ~ v)
                .checkTest(`Check previous`);
        }

        headTest("Backups");
        {
            auto backupInfo = db.backupInfo;
            
            backupInfo
                .equal(BackupUnit[].init)
                .checkTest(`Check empty backups`);
            backupInfo.length
                .not
                .checkTest(`Check empty backups length`);


            db.backup()
                .checkTest(`Create first backup`);

            db.backupInfo.length
                .eq(1)
                .checkTest(`Check backups length`);

            db.backup();
            db.backup();
            db.backup();
            db.backup();

            db.backupInfo.length
                .eq(5)
                .checkTest(`Check backups length`);

            db.backupInfo
                .map!(x => x.id)
                .equal([1, 2, 3, 4, 5])
                .checkTest(`Check backups ids`);

            db.backupDel(2)
                .checkTest(`Check backupDel`);

            db.backupDel(2)
                .not
                .checkTest(`Check backupDel repeat`);

            db.backupInfo
                .map!(x => x.id)
                .equal([1, 3, 4, 5])
                .checkTest(`Check backups ids`);

            db.backupInfo.length
                .eq(4)
                .checkTest(`Check backups length`);

            db.backup();
            db.backup();
            db.backup().checkTest(`Check backup creating`);
            db.backup();

            db.backupInfo
                .map!(x => x.id)
                .equal([1, 3, 4, 5, 6, 7, 8, 9])
                .checkTest(`Check backups ids`);

            db.backupDel([8, 4, 2, 6, 9])
                .equal([true, true, false, true, true])
                .checkTest(`Check backup(multi)Del`);

            db.backupDel([8, 4, 2, 6, 9])
                .equal([false, false, false, false, false])
                .checkTest(`Check backup(multi)Del repeat`);

            db.backupInfo
                .map!(x => x.id)
                .equal([1, 3, 5, 7])
                .checkTest(`Check backups ids`);

            //db.backupInfo.writeln;
            //db.backupInfo.map!(x => x.id).writeln;
        }

        headTest("Other iterators");
        {
            db.getall("key:")
                .equal([
                    Pair("key:1:_1", "val-1(1)"),
                    Pair("key:1:_2", "val-2(1)"),
                    Pair("key:1:_3", "val-3(1)"),
                    Pair("key:2:_1", "val-1@2"),
                    Pair("key:2:_2", "val-2@2"),
                    Pair("key:2:_3", "val-3@2"),
                    Pair("key:3:*1", "val-1*"),
                    Pair("key:3:*2", "**val-2##"),
                    Pair("key:3:*3", "val-3*")
                ])
                .checkTest(`Check Prefix iterator`);

            db.getall()
                .equal([
                    Pair("dgdg", "QQQqqqQQQ"),
                    Pair("hyhy", "JfTdW"),
                    Pair("incr1", "1"),
                    Pair("incr2", "5"),
                    Pair("incr3", "-11"),
                    Pair("incr4", "1"),
                    Pair("incr5", "-1"),
                    Pair("incr6", "4294967295"),
                    Pair("incr7", "-4294967295"),
                    Pair("incr8", "-4294967295"),
                    Pair("key:1:_1", "val-1(1)"),
                    Pair("key:1:_2", "val-2(1)"),
                    Pair("key:1:_3", "val-3(1)"),
                    Pair("key:2:_1", "val-1@2"),
                    Pair("key:2:_2", "val-2@2"),
                    Pair("key:2:_3", "val-3@2"),
                    Pair("key:3:*1", "val-1*"),
                    Pair("key:3:*2", "**val-2##"),
                    Pair("key:3:*3", "val-3*"),
                    Pair("pref:_0_", "\r\n1\n%%%\t^\n"),
                    Pair("pref:_1_", "\r\n2\n%%%\t^\n"),
                    Pair("pref:_2_", "\r\n3\n%%%\t^\n"),
                    Pair("pref:_4_", "\n4\n%\t^%%\n\r")
                ])
                .checkTest(`Check all-pairs iterator`);
        }

        headTest("Seek key");
        {
            db.set([
                "w:a" : "v-w:a",
                "w:c" : "v-w:c",
                "w:e" : "v-w:e",
                "w:g" : "v-w:g",
                "w:h" : "v-w:h",
                "w:l" : "v-w:l",
                "x:a" : "v-x:a",
                "x:c" : "v-x:c",
            ]);

            db.seekPrev("w:d")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a"), Pair("x:c", "v-x:c")])
                .checkTest(`seekPrev(prefixStart)`);
            db.seekPrev("w:d", "w:")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekPrev(prefixStart, startsWith)`);

            db.seekPrev("w:e")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a"), Pair("x:c", "v-x:c")])
                .checkTest(`seekPrev(prefixStart)`);
            db.seekPrev("w:e", "w:")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekPrev(prefixStart, startsWith)`);

            db.seekPrev("0:e")
                .equal([Pair("dgdg", "QQQqqqQQQ"), Pair("hyhy", "JfTdW"), Pair("incr1", "1"), Pair("incr2", "5"), Pair("incr3", "-11"), Pair("incr4", "1"), Pair("incr5", "-1"), Pair("incr6", "4294967295"), Pair("incr7", "-4294967295"), Pair("incr8", "-4294967295"), Pair("key:1:_1", "val-1(1)"), Pair("key:1:_2", "val-2(1)"), Pair("key:1:_3", "val-3(1)"), Pair("key:2:_1", "val-1@2"), Pair("key:2:_2", "val-2@2"), Pair("key:2:_3", "val-3@2"), Pair("key:3:*1", "val-1*"), Pair("key:3:*2", "**val-2##"), Pair("key:3:*3", "val-3*"), Pair("pref:_0_", "\r\n1\n%%%\t^\n"), Pair("pref:_1_", "\r\n2\n%%%\t^\n"), Pair("pref:_2_", "\r\n3\n%%%\t^\n"), Pair("pref:_4_", "\n4\n%\t^%%\n\r"), Pair("w:a", "v-w:a"), Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a"), Pair("x:c", "v-x:c")])
                .checkTest(`seekPrev(prefixStart)`);
            db.seekPrev("0:e", "w:")
                .equal(Pair[].init)
                .checkTest(`seekPrev(prefixStart, startsWith)`);

            db.seekPrevRange("w:d", "x:b")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a")])
                .checkTest(`seekPrevRange(prefixStart, prefixEnd)`);
            db.seekPrevRange("w:d", "x:b", "w:")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekPrevRange(prefixStart, prefixEnd, startsWith)`);

            db.seekPrevRange("w:e", "x:b")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a")])
                .checkTest(`seekPrevRange(prefixStart, prefixEnd)`);
            db.seekPrevRange("w:e", "x:a")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a")])
                .checkTest(`seekPrevRange(prefixStart, prefixEnd)`);
            db.seekPrevRange("w:e", "x:b", "w:")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekPrevRange(prefixStart, prefixEnd, startsWith)`);


            db.seekNext("w:d")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a"), Pair("x:c", "v-x:c")])
                .checkTest(`seekNext(prefixStart)`);
            db.seekNext("w:d", "w:")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekNext(prefixStart, startsWith)`);

            db.seekNext("w:e")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a"), Pair("x:c", "v-x:c")])
                .checkTest(`seekNext(prefixStart)`);
            db.seekNext("w:e", "w:")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekNext(prefixStart, startsWith)`);

            db.seekNext("0:e")
                .equal([Pair("dgdg", "QQQqqqQQQ"), Pair("hyhy", "JfTdW"), Pair("incr1", "1"), Pair("incr2", "5"), Pair("incr3", "-11"), Pair("incr4", "1"), Pair("incr5", "-1"), Pair("incr6", "4294967295"), Pair("incr7", "-4294967295"), Pair("incr8", "-4294967295"), Pair("key:1:_1", "val-1(1)"), Pair("key:1:_2", "val-2(1)"), Pair("key:1:_3", "val-3(1)"), Pair("key:2:_1", "val-1@2"), Pair("key:2:_2", "val-2@2"), Pair("key:2:_3", "val-3@2"), Pair("key:3:*1", "val-1*"), Pair("key:3:*2", "**val-2##"), Pair("key:3:*3", "val-3*"), Pair("pref:_0_", "\r\n1\n%%%\t^\n"), Pair("pref:_1_", "\r\n2\n%%%\t^\n"), Pair("pref:_2_", "\r\n3\n%%%\t^\n"), Pair("pref:_4_", "\n4\n%\t^%%\n\r"), Pair("w:a", "v-w:a"), Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a"), Pair("x:c", "v-x:c")])
                .checkTest(`seekNext(prefixStart)`);
            db.seekNext("0:e", "w:")
                .equal(Pair[].init)
                .checkTest(`seekNext(prefixStart, startsWith)`);

            db.seekNextRange("w:d", "x:b")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a")])
                .checkTest(`seekNextRange(prefixStart, prefixEnd)`);
            db.seekNextRange("w:d", "x:b", "w:")
                .equal([Pair("w:c", "v-w:c"), Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekNextRange(prefixStart, prefixEnd, startsWith)`);

            db.seekNextRange("w:e", "x:b")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a")])
                .checkTest(`seekNextRange(prefixStart, prefixEnd)`);
            db.seekNextRange("w:e", "x:a")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l"), Pair("x:a", "v-x:a")])
                .checkTest(`seekNextRange(prefixStart, prefixEnd)`);
            db.seekNextRange("w:e", "x:b", "w:")
                .equal([Pair("w:e", "v-w:e"), Pair("w:g", "v-w:g"), Pair("w:h", "v-w:h"), Pair("w:l", "v-w:l")])
                .checkTest(`seekNextRange(prefixStart, prefixEnd, startsWith)`);
        }

        headTest("stats");
        {
            db.stats()
                .length
                .not.not
                .checkTest(`Check db.stats().length`);
        }
        headTest("");

    } catch (ClientException e) {
        writeln([e.msg, e.file], e.line);
        return 1;
    } catch (Exception e) {
        writeln("\n", e.msg);
        return 1;
    }
    return 0;
}
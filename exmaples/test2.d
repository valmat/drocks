#!/usr/bin/rdmd --shebang=-I../source -I.

import std.stdio;
//import std.typecons;
//import std.range;
import drocks : ClientException;
import customclient : CustomClient;

void main()
{
    auto db = CustomClient.createDefault();

    try {

        //writeln(`[db.get("key1")]:`);
        //[db.get("key1")].writeln;

        //`[db.getIncr]`.writeln;
        //[db.getIncr("incr1"     )].writeln;
        //[db.getIncr("incr2",   5)].writeln;
        //[db.getIncr("incr3", -11)].writeln;
        //writeln(`[db.get("incr1")]:`);
        //[db.get("incr1")].writeln;
        //writeln(`[db.get("incr2")]:`);
        //[db.get("incr2")].writeln;
        //writeln(`[db.get("incr3")]:`);
        //[db.get("incr3")].writeln;


        //`[db.ping]`.writeln;
        //[db.ping()].writeln;

        //`[db.seekFirst]`.writeln;
        //[db.seekFirst("ms")].writeln;


        `[db.wstats]`.writeln;
        "\t\t stats:"                    .writeln;
        db.wstats("stats")               .writeln;
        "\t\t sstables:"                 .writeln;
        db.wstats("sstables")            .writeln;
        "\t\t num-files-at-level0:"      .writeln;
        db.wstats("num-files-at-level0") .writeln;
        "\t\t num-files-at-level1:"      .writeln;
        db.wstats("num-files-at-level1") .writeln;

        

    } catch (ClientException e) {
        writeln([e.msg, e.file], e.line);
    }
    
}
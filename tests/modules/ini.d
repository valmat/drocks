module ini;

import std.stdio     : writeln;
import std.string    : leftJustifier;
import std.conv      : to;
import std.algorithm : map, filter;
import std.string    : indexOf, strip;
import std.stdio     : File;

// Read map from ini-file
string[string] file2map(string fileName)
{
    size_t npos = size_t(-1);
    auto cfgRange = File(fileName)
        .byLineCopy()
        .map!((line) {
            size_t pos = line.indexOf(';');
            // remove comment & trim
            return ( npos > pos ) ? line[0..pos].strip() : line.strip();
        })
        .filter!"a.length";

    string[string] cfgMap;

    foreach(ref line; cfgRange) {
        size_t pos = line.indexOf(';');
        // parse key and value
        pos = line.indexOf('=');
        if( npos > pos ) {
            string key   = line[  0 .. pos  ].strip();
            string value = line[ pos+1 .. $ ].strip();
            if(value.length > 1 && '"' == value[0] && '"' == value[$-1]) {
                value = value[1..$-1];
            }

            cfgMap[key] = value;
        }
    }
    
    return cfgMap;
}

// Write map to ini-file
void map2file(string[string] map, string fileName)
{
    auto file = File(fileName, "w");
    foreach(key, ref val; map) {
        file.writeln(key, ` = `, val);
    }
}




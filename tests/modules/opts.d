module opts;


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

static import c;

struct Opts
{
    string serverBinary = "/usr/local/bin/rocksserver";
    //string configFile   = "/etc/rocksserver/config.ini";
    string configFile;
    
    string tmpDir;

    //string host = "localhost";
    string port = "5541";

    bool keepTemp = false;

    bool valid = true;
    
    string configFileNew;

    this(string[] args)
    {
        auto rnd     = Random(unpredictableSeed);
        auto rnd_pfx = uniform(0, int.max, ).to!string;
        tmpDir       = tempDir() ~ "/rocksserver." ~ rnd_pfx;

        configFileNew = tmpDir ~ "/configs.ini";
        
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
            
            //"host|s",
            //"DB host. Default: \"" ~ host ~"\".\n",
            //&host,
            
            "port|p",
            "DB port. Default: \"" ~ port ~"\".\n",
            &port,
            
            "keep|k",
            "Keep temporary files after tests finished.\n",
            &keepTemp
            
        );
        

        if (helpInformation.helpWanted) {
            defaultGetoptPrinter(
                "Some information about the program.", 
                helpInformation.options
            );
            valid = false;
            return;
        }

        buildPath(tmpDir ~ "/backup")  .mkdirRecurse; 
        buildPath(tmpDir ~ "/plugins") .mkdirRecurse;
        buildPath(tmpDir ~ "/db")      .mkdirRecurse;
    }

    ~this()
    {
        // Remove temporary dir
        if(valid && !keepTemp) {
            tmpDir.rmdirRecurse;
        }
    }

    void show() const
    {
        writeln( c.yellow, "__________________________________________________________________", c.reset);
        writeln( c.yellow, "RocksServer binary file location          :", c.green, serverBinary, c.reset);
        writeln( c.yellow, "RocksServer config file location          :", c.green, configFile  , c.reset);
        writeln( c.yellow, "temporary dir                             :", c.green, tmpDir      , c.reset);
        //writeln( c.yellow, "DB host. If did not specified use default :", c.green, host        , c.reset);
        writeln( c.yellow, "DB port.                                  :", c.green, port        , c.reset);

        writeln( c.yellow, "Keep temporary files after tests finished :", c.green, keepTemp    , c.reset);

        writeln( c.yellow, "__________________________________________________________________", c.reset);
    }
    

}

void showMap(string[string] cfgMap)
{
    writeln( c.blue, "RocksServer options:", c.reset);
    foreach(key, ref val; cfgMap) {
        writeln( c.yellow, key.leftJustifier(20, ' '), " : ", c.green, val, c.reset);
    }
    writeln( c.yellow, "__________________________________________________________________", c.reset);
}
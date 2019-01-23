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

import ini : file2map, map2file;

static import c;

struct Opts
{
private:
    string tmpDir;

    bool keepTemp = false;

    bool _valid = true;
    
    string configFileNew;

    string[string] cfgMap;

    string serverBinary = "/usr/local/bin/rocksserver";
    //string configFile   = "/etc/rocksserver/config.ini";
    string configFile;

public:
    
    //string host = "localhost";
    string port = "5541";

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
            _valid = false;
            return;
        }

        buildPath(tmpDir ~ "/backup")  .mkdirRecurse; 
buildPath(tmpDir ~ "/plugins") .mkdirRecurse;
        buildPath(tmpDir ~ "/db")      .mkdirRecurse;

        if(configFile.length) {
            cfgMap = configFile.file2map;
        }

        cfgMap["log_level"]      = "debug"; 
        cfgMap["error_log"]      = tmpDir ~ "/error.log"; 
        cfgMap["backup_path"]    = tmpDir ~ "/backup"; 
        cfgMap["extdir"]         = tmpDir ~ "/plugins";
        cfgMap["db_path"]        = tmpDir ~ "/db";

        //if(host.length) {
        //    cfgMap["server_host"] = host;
        //}
        if(port.length) {
            cfgMap["server_port"] = port;
        }


        // Create INI configs file
        cfgMap.map2file(configFileNew);

    }

    ~this()
    {
        // Remove temporary dir
        if(_valid && !keepTemp) {
            tmpDir.rmdirRecurse;
        }
    }

    bool valid() const
    {
        return _valid;
    }

    string[] servOpts() const
    {
        return [serverBinary, configFileNew];
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

        // RocksServer options
        writeln( c.blue, "RocksServer options:", c.reset);
        foreach(key, ref val; cfgMap) {
            writeln( c.yellow, key.leftJustifier(20, ' '), " : ", c.green, val, c.reset);
        }
        writeln( c.yellow, "__________________________________________________________________", c.reset);
    }
}


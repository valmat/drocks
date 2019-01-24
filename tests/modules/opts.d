module opts;

import std.stdio  : writeln, write;
import std.file   : mkdirRecurse, rmdirRecurse, tempDir;
import std.random : Random, uniform, unpredictableSeed;
import std.string : leftJustifier;
import std.conv   : to;
import std.getopt : getopt, defaultGetoptPrinter;
import std.path   : buildPath;

import ini : file2map, map2file;

static import c;

struct Opts
{
private:
    string tmpDir;

    bool _keepTemp = false;

    bool _valid = true;
    
    string _configFileNew;

    string[string] _cfgMap;

    string _serverBinary = "/usr/local/bin/rocksserver";
    string _configFile;

    string _hostDflt = "localhost";
    string _portDflt = "5541";

    string _host;
    string _port;

public:
    this(string[] args)
    {
        auto rnd     = Random(unpredictableSeed);
        auto rnd_pfx = uniform(0, int.max, ).to!string;
        tmpDir       = tempDir() ~ "/rocksserver." ~ rnd_pfx;

        _configFileNew = tmpDir ~ "/configs.ini";
        
        auto helpInformation = getopt(args,
            "binary|b", 
            "RocksServer binary file location." ~
            "\n\t\tDefault: \"" ~ _serverBinary ~"\"",
            &_serverBinary,

            "config|c",
            "RocksServer config file location." ~
            "\n\t\tBy default created automatically",
            &_configFile,

            "tmp|t",
            "temporary dir." ~
            "\n\t\tDefault: \"" ~ tmpDir ~"\"\n",
            &tmpDir,
            
            "host|s",
            "DB host. Default: \"" ~ _hostDflt ~"\".\n",
            &_host,
            
            "port|p",
            "DB port. Default: \"" ~ _portDflt ~"\".\n",
            &_port,
            
            "keep|k",
            "Keep temporary files after tests finished.\n",
            &_keepTemp
            
        );
        

        if (helpInformation.helpWanted) {
            defaultGetoptPrinter(
                "Run tets for drocks - RocksServer client", 
                helpInformation.options
            );
            _valid = false;
            return;
        }

        if(_configFile.length) {
            _cfgMap = _configFile.file2map;
        }

        _cfgMap["log_level"]   = "debug"; 
        _cfgMap["error_log"]   = tmpDir ~ "/error.log"; 
        _cfgMap["backup_path"] = tmpDir ~ "/backup"; 
        _cfgMap["db_path"]     = tmpDir ~ "/db";

        if("extdir" !in _cfgMap) {
            _cfgMap["extdir"] = tmpDir ~ "/plugins";
            buildPath(tmpDir ~ "/plugins").mkdirRecurse;
        }
        
        buildPath(tmpDir ~ "/backup").mkdirRecurse; 
        buildPath(tmpDir ~ "/db")    .mkdirRecurse;

        if(_host.length) {
            _cfgMap["server_host"] = _host;
        } else if("server_host" in _cfgMap) {
            _host = _cfgMap["server_host"];
        } else {
            _cfgMap["server_host"] = _host = _hostDflt;
        }

        if(_port.length) {
            _cfgMap["server_port"] = _port;
        } else if("server_port" in _cfgMap) {
            _port = _cfgMap["server_port"];
        } else {
            _cfgMap["server_port"] = _port = _portDflt;
        }

        // Create INI configs file
        _cfgMap.map2file(_configFileNew);
    }

    ~this()
    {
        // Remove temporary dir
        if(_valid && !_keepTemp) {
            tmpDir.rmdirRecurse;
        }
    }

    bool valid() const
    {
        return _valid;
    }
    string host() const
    {
        return _host;
    }
    string port() const
    {
        return _port;
    }

    string[] servOpts() const
    {
        return [_serverBinary, _configFileNew];
    }


    void show() const
    {
        writeln( c.yellow, "__________________________________________________________________", c.reset);
        writeln( c.yellow, "RocksServer binary file location          :", c.green, _serverBinary, c.reset);
        writeln( c.yellow, "RocksServer config file location          :", c.green, _configFile , c.reset);
        writeln( c.yellow, "temporary dir                             :", c.green, tmpDir      , c.reset);
        writeln( c.yellow, "DB host.                                  :", c.green, _host       , c.reset);
        writeln( c.yellow, "DB port.                                  :", c.green, _port       , c.reset);

        writeln( c.yellow, "Keep temporary files after tests finished :", c.green, _keepTemp   , c.reset);

        writeln( c.yellow, "__________________________________________________________________", c.reset);

        // RocksServer options
        writeln( c.blue, "RocksServer options:", c.reset);
        foreach(key, ref val; _cfgMap) {
            writeln( c.yellow, key.leftJustifier(20, ' '), " : ", c.green, val, c.reset);
        }
        writeln( c.yellow, "__________________________________________________________________", c.reset);
    }
}


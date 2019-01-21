module drocks;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.conv;
import std.socket;

public import drocks.exception : ClientException;
//import drocks.response         : Response;
import drocks.request          : Request;
import drocks.multivalue       : MultiValue;

struct Client
{
private:
    // Requestes handler
    Request _req;
public:
    this(string host, ushort port)
    {
        _req = Request(host, port);
    }
    @disable this ();

    static Client createDefault()
    {
        return Client("localhost", 5533);
    }

    // get value by key
    string get(string key) {
        return _req.httpGet("get", key).getValue();
        //return _req.httpGet("get", key).raw();
    }

    /**
      *  
      *  @return MgetIterator
      */
    // multi get key-value pairs by keys
    auto mget(Range)(Range range) {
        range.join("&").writeln;
        //return _req.httpGet("mget", range).raw();//
        //return _req.httpGet("mget", range).MultiValue;
        return _req.httpGet("mget", range).getMultiValue();

    }

    // set value for key
    bool set(string key, string val) {
        string data = key ~ "\n" ~ val.length.to!string ~ "\n" ~ val;
        //return _req.httpPost("set", data).raw();
        return _req.httpPost("set", data).isOk();
    }

    static struct KeyExist
    {
        bool   exist;
        string value;
        alias exist this;
    }
    // Check if key exist
    KeyExist exist(string key) {
        auto resp = _req.httpGet("exist", key);
        bool rez  = resp.isOk();
        return !rez ? 
            KeyExist(rez) :
            KeyExist(rez, resp.getValue());
    }
    
private:


    



/*
    // POST request
    protected function httpPost($path, $data = NULL) {
        $buf  = "POST /$path HTTP/1.1\r\n";
        $buf .= "Host:{$this->_host}\r\n";
        
        if(NULL !== $data) {
            $buf .= "Content-Type:application/x-www-form-urlencoded; charset=UTF-8\r\n";
            $buf .= "Content-Length: " . strlen($data) . "\r\n";
            $buf .= "Connection: Close\r\n\r\n";
            $buf .= $data;
        } else {
            $buf .= "Content-Type: charset=UTF-8\r\n";
            $buf .= "Connection: Close\r\n\r\n";
        }
        return $this->request($buf);
    }
    

    
    // Encodes data to send in a POST request
    private function data2str(array $data) {
        $ret = '';
        foreach($data as $key => $val) {
            $ret .= "$key\n".strlen($val)."\n$val\n";
        }
        return $ret;
    }
*/

}



// test:
// cd source
// rdmd -unittest -main --force drocks/package
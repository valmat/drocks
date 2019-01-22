module drocks.response;

import std.conv           : to;
import drocks.sockhandler : SockHandler;
import drocks.exception   : ClientException;
import drocks.pair        : Pair;
import drocks.multivalue;

struct Response
{
private:
    SockHandler _sock;

public:
    this(SockHandler sockHandler)
    {
        _sock = sockHandler;
    }
    @disable this ();

    //void close() { _sock.close(); }
    
    // Raw data of response
    string raw()
    {
        return _sock.readAll();
    }
    
    // Cast response to bool (is response "OK")
    bool isOk()
    {
        if(_sock.isValid) {
            auto resp = _sock.readLine();
            return (resp.length > 1) && (resp[0..2] == "OK");
        }
        return false;
    }

    // Check if socket is valid
    bool isValid() const
    {
        return _sock.isValid;
    }
    
    // Get single value of response
    string getValue()
    {
        if(!_sock.isValid) {
            return null;
        }

        auto val_len_str = _sock.readLine();
        if(!val_len_str.length) {
            return null;
        }

        auto val_len = val_len_str.to!int;
        if(val_len < 0 || !_sock.isValid) {
            return null;
        }

        auto rez = val_len ? _sock.read(val_len).idup : "";
        if(!val_len) {
            _sock.getChar(); // retrieve char '\n'
        }

        return rez;
    }

    // Get key and value of response
    Pair getPair()
    {
        return Pair(this.getKey(), this.getValue());
    }

   
    // Get multi-value iterator of response
    auto getMultiPair()
    {
        //return refRange(new MultiPair(this));
        return MultiPair(this);
    }

    
    auto getMultiKey()
    {
        //return refRange(new MultiKey(this));
        return MultiKey(this);
    }

    
    auto getMultiValue()
    {
        //return refRange(new MultiValue(this));
        return MultiValue(this);
    }

    // Get single value of response
    string getKey() // const
    {
        if(!_sock.isValid) {
            return null;
        }
        return _sock.readLine().idup;
    }
}

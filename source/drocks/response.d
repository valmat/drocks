module drocks.response;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.conv;
import std.socket;
import drocks.sockhandler      : SockHandler;
import drocks.multivalue       ;//: MultiValue;
public import drocks.exception : ClientException;
import std.algorithm: move;
import drocks.pair             : Pair;

struct Response
{
private:
    SockHandler _sock = null;
    // Владеет ли текущий экземпляр сокетом
    bool _ownsSock = true;

public:
    this(SockHandler sockHandler)
    {
        writeln("^^^^^^^^^^^^^^^ Response %%%%%%%%%%%%%%%%%%%%%" );
        _ownsSock = true;
        _sock = sockHandler;
    }
    @disable this ();

    //@disable this(this);
    //this(ref Response rhs)
    this(this)
    {
        writeln("-------------- Response this(this)" );
        //_ownsSock = false;
        //this._ownsSock = true;
    }

    Response clone()
    {
        _ownsSock = false;
        return Response(_sock);
    }

    ~this()
    {
        writeln("~~~~~~~~~~~~~~~ ~Response %%%%%%%%%%%%%%%%%%%%%" );
        //[(_sock !is null), _ownsSock].writeln;
        if((_sock !is null) && _ownsSock) {
            //[&_sock].writeln;
            //_ownsSock = false;
            //_sock.close();
            writeln("~~~~~~~~~~~~~~~ \t\t close Response" );
        }
    }

    void close()
    {
        writeln("~~~~~~~~~~~~~~~ ~Response           void close() ");
        _sock.close();
    }
    
    // Raw data of response
    string raw()
    {
        return _sock.readAll();
    }
    
    // Cast response to bool
    // is response OK
    bool isOk(){
        if(_sock.isValid) {
            auto resp = _sock.readLine();
            return (resp.length > 1) && (resp[0..2] == "OK");
        }
        return false;
    }

    // Check if socket is valid
    bool isValid() const
    {
        return /*_ownsSock &&*/ _sock.isValid;
    }
    
    // Get single value of response
    string getValue() {
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


        //auto rez = val_len ? _sock.read(val_len).idup : "";
        auto rez = val_len ? _sock.read(val_len).idup : "";
        if(!val_len) {
            _sock.getChar(); // retrieve char '\n'
        }
        
        //writeln([rez], [val_len]);
        //[_sock.readLine()].writeln;

        return rez;
    }

    // Get key and value of response
    Pair getPair() {
        return Pair(this.getKey(), this.getValue());
    }

   
    // Get multi-value iterator of response
    auto getMultiPair()
    {
        _ownsSock = false;
        //return MultiPair(this.clone())
        //return MultiPair(this)
        return refRange(new MultiPair(this.clone()))
        //return refRange(new MultiPair(this))

            //.array
            ;
    }

    auto
    getMultiKey() // const
    {
        _ownsSock = false;
        //return MultiPair(this.clone())
        return MultiKey(this)
            //.array
            ;
    }


    // Get single value of response
    string getKey() // const
    {
        if(!_sock.isValid) {
            return null;
        }
        return _sock.readLine().idup;
    }
    

    
    
    ///**
    //  *  Read data from socket
    //  *  @return string
    //  */
    //public function read($len = 0) {
    //    if(!$len) return fgets($this->_sock);
        
    //    $rez = fgets($this->_sock, $len);
    //    $rlen = strlen($rez);
        
    //    while($rlen < $len-1 && !feof($this->_sock)) {
    //        $rez .= fgets($this->_sock, $len-$rlen);
    //        $rlen = strlen($rez);
    //    }
    //    return $rez;
    //}
    
    ///**
    //  *  Cast to string
    //  */
    //public function __toString(){
    //    return $this->raw();
    //}


}

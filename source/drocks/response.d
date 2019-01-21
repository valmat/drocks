module drocks.response;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.conv;
import std.socket;
import drocks.sockhandler      : SockHandler;
import drocks.multivalue       : MultiValue;
public import drocks.exception : ClientException;


struct Response
{
private:
    SockHandler _sock;
    // Владеет ли текущий экземпляр сокетом
    bool _ownsSock = true;

public:
    this(SockHandler sockHandler)
    {
        writeln("^^^^^^^^^^^^^^^ Response %%%%%%%%%%%%%%%%%%%%%" );
        _sock = sockHandler;
    }
    @disable this ();

    //@disable
    //this(ref Response rhs)
    this(this)
    {
        this._sock = _sock;
        _ownsSock = false;
        //this._ownsSock = true;
    }

    Response clone()
    {
        return Response(_sock);
    }

    ~this()
    {
        writeln("~~~~~~~~~~~~~~~ ~Response %%%%%%%%%%%%%%%%%%%%%" );
        if(_ownsSock) 
            _sock.close();
    }

    void close()
    {
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
        
auto qq = _sock.readLine();
writeln("qq : ", [qq]);


        auto val_len = qq.to!uint16_t;
        //auto val_len = _sock.readLine().to!uint16_t;

        if( !val_len || !_sock.isValid ) {
            return "";
        }

        auto rez = val_len ? _sock.read(val_len) : "";
writeln("rez : ", [rez]);
        // skip '\n'
        //_sock.readLine();
        //return $rez;
        
        writeln([rez], [val_len]);
        //[_sock.readLine()].writeln;

        return rez.idup;
    }

   
    //MultiValue
    auto
    getMultiValue() // const
    {
        //return MultiValue(this.clone())
        return MultiValue(this)
            .array
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
    //  *  Get multi-value iterator of response
    //  *  @return MgetIterator
    //  */
    //public function getMultiValue() {
    //    return new MgetIterator($this);
    //}
    
    
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

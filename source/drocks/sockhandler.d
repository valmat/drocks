module drocks.sockhandler;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.conv;
import std.socket;

public import drocks.exception : ClientException;

class SockHandler
{
private:
    TcpSocket _sock;
    char[] _line_buf;
    bool   _opened = false;
    bool   _valid = true;

public:
    this(TcpSocket sock, char[] buf)
    {
        "Open sock1|||||".writeln; 
        _opened = true;
        _sock     = sock;
        _line_buf = buf;
    }
    this(char[] buf)
    {
        "Open sock2|||||".writeln;
        _opened = false;
        _sock     = new TcpSocket();
        _line_buf = buf;
    }
    //@disable this ();
    ~this()
    {
        "close sock ~this".writeln;
        this.close();
    }

    bool isValid() const
    {
        return _opened && _valid && _sock.isAlive();
    }
    
    void close()
    {
        "close sock________".writeln;
        if(_opened) {
            "close sock........".writeln;
            //_sock.close();
            _opened = false;
        }
    }

    void connect(InternetAddress addr)
    {
        _opened = true;
        _sock.connect(addr);
    }
    auto send(string req)
    {
        return _sock.send(req);
    }

    // Receives a Header from socket
    char[] receiveHeader()
    {
        _line_buf.length = 0;
        //char[1] buf;
        // Receive behind "\r\n"
        //while(_sock.isAlive() && _sock.receive(buf) && '\r' != buf[0]) {
        //    _line_buf ~= buf;
        //}
        //
        for(auto c = getChar(); isValid() && '\r' != c; c = getChar()) {
            _line_buf ~= c;
        }

        // Receive char '\n'
        if(isValid()) {
            //_sock.receive(buf);
            getChar();
        }
        
        return _line_buf;
    }
    // Receives a line from socket
    char[] readLine()
    {
        _line_buf.length = 0;
        //char[1] buf;
        // Receive behind '\n'
        //while(_sock.isAlive() && _sock.receive(buf) && '\n' != buf[0]) {
        //    _line_buf ~= buf;
        //}
        for(auto c = getChar(); isValid() && '\n' != c; c = getChar()) {
            _line_buf ~= c;
        }

        return _line_buf;
    }
    
    // Receives num chars from socket
    char[] read(size_t num)
    {
        _line_buf.length = 0;
        //char[1] buf;
        //for(size_t i = 0; i < num && _sock.isAlive() &&  _sock.receive(buf); ++i) {
        //    _line_buf ~= buf;
        //}
        
        size_t i = 0;
        for(auto c = getChar(); i < num && isValid(); ++i, c = getChar()) {
            _line_buf ~= c;
        }
        return _line_buf;
    }

    // Receives all data from socket
    string readAll() /*const*/
    {
        _line_buf.length = 0;
        //char[1] buf;
        string rez = "";

        //bool valid  = true;
        while(isValid()) {
            //valid = _sock.isAlive() && _sock.receive(buf);
            //while(valid) {
            //    _line_buf ~= buf;
            //    valid = _sock.isAlive() && _sock.receive(buf);
            //}
            for(auto c = getChar(); isValid(); c = getChar()) {
                _line_buf ~= c;
            }
            rez ~= _line_buf;
        }
        return rez;
    }

    //private
    //ReceivedChar
    char getChar()
    {
        char[1] buf;
        _valid  = _sock.receive(buf) != 0;
        //return ReceivedChar(_valid, buf[0]);
        return buf[0];
    }


}

//private struct ReceivedChar
//{
//    bool valid;
//    char value;
//    alias value this;
//}



// test:
// cd source
// rdmd -unittest -main --force drocks/package
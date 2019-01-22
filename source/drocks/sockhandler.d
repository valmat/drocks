module drocks.sockhandler;

import std.stdio;
import std.socket : TcpSocket, InternetAddress, recv;
//import std.socket : recv, SocketFlags;
//import std.socket;

public import drocks.exception : ClientException;

// Define thread local static buffer
private static char[] _line_buf;
static this() {
    _line_buf.reserve(128);
}

class SockHandler
{
private:
    TcpSocket _sock;
    bool   _opened = false;
    bool   _valid = true;

public:
    this(TcpSocket sock)
    {
        "Open sock1|||||".writeln; 
        _opened = true;
        _sock     = sock;
    }
    this()
    {
        "Open sock2|||||".writeln;
        _opened = false;
        _sock     = new TcpSocket();
    }

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
        //"close sock________".writeln;
        if(_opened) {
            "\t\t\t\t\t\t\tclose sock__........".writeln;
            _sock.close();
            //_opened = false;
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
        // Receive behind "\r\n"
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
        // Receive behind '\n'
        for(auto c = getChar(); isValid() && '\n' != c; c = getChar()) {
            _line_buf ~= c;
        }

        return _line_buf;
    }
    
    // Receives num chars from socket
    char[] read(size_t num)
    {
        _line_buf.length = 0;
        size_t i = 0;
        for(auto c = getChar(); i < num && isValid(); ++i, c = getChar()) {
            _line_buf ~= c;
        }
        return _line_buf;
    }

    // Receives all data from socket
    string readAll()
    {
        _line_buf.length = 0;
        string rez = "";

        while(isValid()) {
            for(auto c = getChar(); isValid(); c = getChar()) {
                _line_buf ~= c;
            }
            rez ~= _line_buf;
        }
        return rez;
    }

    char getChar()
    {
        char[1] buf;
        _valid  = (_sock.receive(buf) != 0UL);
        //_valid  = recv(_sock.handle(), buf.ptr, 1, cast(int) SocketFlags.NONE) != 0UL;
        if(!_valid) close();
        return buf[0];
    }

}
module drocks.request;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.algorithm;
import std.conv;
import std.socket;
static import uri = std.uri;

public import drocks.exception : ClientException;
import drocks.sockhandler      : SockHandler;
import drocks.response         : Response;


// Создаёт сокеты и генерирует запросы
struct Request
{
private:
    InternetAddress _addr;
    char[] _line_buf;
    string _host;

public:
    this(string host, ushort port)
    {
        _host = host;
        _addr = new InternetAddress(host, port);
        _line_buf.reserve(128);
    }
    @disable this ();

    // @param string request
    auto request(string req) {
        auto sock = new SockHandler(_line_buf);
        //auto sock = SockHandler(_line_buf);
        //scope(exit) sock.close();

        try {
            sock.connect(_addr);
            sock.send(req);
        } catch (SocketException e) {
            throw new ClientException(e);
        }

        stderr.writeln("~~~~~~~~~~~~~~~~");
        stderr.writeln(req);
        stderr.writeln("~~~~~~~~~~~~~~~~");

        //
        // Check response status
        //
        auto status = sock.receiveHeader();
        enum string expectedStatus = "200 OK";
        if( status.length < expectedStatus.length ){
            throw new ClientException("Empty response");
        }
        stderr.writeln(status);
        
        // Expected: status == "HTTP/1.1 200 OK"
        if( !sock.isValid() || expectedStatus != status[$-expectedStatus.length..$] ){
            throw new ClientException("Status error: " ~ status.idup);
        }

        // skip headers
        while (sock.receiveHeader().length) {}
        
        //[receiveLine(sock)].writeln;
        //[receiveLine(sock, 5000)].writeln;

        return Response(sock);
    }

    // GET request
    //Response
    auto httpGet(string path)
    {
        string buf;
        buf  = "GET /" ~ path  ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;
        return this.request(buf);
    }

    // GET request
    //Response
    auto httpGet(string path, string data)
    {
        string buf;
        buf  = "GET /" ~ path  ~ "?" ~ uri.encode(data) ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;
        return this.request(buf);
    }

    //Response
    auto httpGet(Range)(string path, Range range)
    {
        static import uri = std.uri;
        string buf;
        string data = range
            .map!( (string x) {return uri.encode(x);})
            .join("&");

        buf  = "GET /" ~ path  ~ "?" ~ data ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;

        return this.request(buf);
    }

    // POST request
    //Response
    auto httpPost(string path, string data) {
        string buf;
        buf  = "POST /" ~ path ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEndPost(data.length) ~
               data;

        [buf].writeln;
        return this.request(buf);
    }

    // POST request
    //Response
    auto httpPost(string path) {
        string buf;
        buf  = "POST /" ~ path ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;

        [buf].writeln;
        return this.request(buf);
    }

    private enum string  headsEnd = 
        "Content-Type: charset=UTF-8\r\n" ~
        "Connection: Close\r\n\r\n";

    private string headsEndPost(size_t len)
    {
        return 
            "Content-Type:application/x-www-form-urlencoded; charset=UTF-8\r\n" ~
            "Content-Length: " ~ len.to!string ~ "\r\n" ~
            "Connection: Close\r\n\r\n";
    }

}

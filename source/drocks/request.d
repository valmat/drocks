module drocks.request;

//import std.typecons;
import std.range : join;
//import std.string;
import std.algorithm : map;
import std.stdio  : stderr, writeln;
import std.socket : InternetAddress, SocketException;
import std.conv   : to;
static import uri = std.uri;

public import drocks.exception : ClientException;
import drocks.sockhandler      : SockHandler;
import drocks.response         : Response;


// Creates sockets and generates requests
struct Request
{
private:
    InternetAddress _addr;
    string _host;

public:
    this(string host, ushort port)
    {
        _host = host;
        _addr = new InternetAddress(host, port);
    }
    @disable this ();

    // Generates a request and returns response
    Response request(string req)
    {
        auto sock = new SockHandler();

        try {
            sock.connect(_addr);
            sock.send(req);
        } catch (SocketException e) {
            throw new ClientException(e);
        }

        //stderr.writeln("~~~~~~~~~~~~~~~~");
        //stderr.writeln(req);
        //stderr.writeln("~~~~~~~~~~~~~~~~");

        // Check response status
        auto status = sock.receiveHeader();
        enum string expectedStatus = "200 OK";
        if( status.length < expectedStatus.length ){
            throw new ClientException("Empty response");
        }
        
        // Expected: status == "HTTP/1.1 200 OK"
        if( !sock.isValid() || expectedStatus != status[$-expectedStatus.length..$] ){
            throw new ClientException("Status error: " ~ status.idup);
        }

        // skip headers
        while (sock.receiveHeader().length) {}
        
        return Response(sock);
    }

    // GET request
    Response httpGet(string path)
    {
        string buf;
        buf  = "GET /" ~ path  ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;
        return this.request(buf);
    }

    // GET request
    Response httpGet(string path, string data)
    {
        string buf;
        buf  = "GET /" ~ path  ~ "?" ~ uri.encode(data) ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;
        return this.request(buf);
    }

    Response httpGet(Range)(string path, Range range)
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
    Response httpPost(string path, string data) {
        string buf;
        buf  = "POST /" ~ path ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEndPost(data.length) ~
               data;

        //[buf].writeln;
        return this.request(buf);
    }

    // POST request
    Response httpPost(string path) {
        string buf;
        buf  = "POST /" ~ path ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;

        //[buf].writeln;
        return this.request(buf);
    }


private:

    enum string  headsEnd = 
        "Content-Type: charset=UTF-8\r\n" ~
        "Connection: Close\r\n\r\n";

    string headsEndPost(size_t len)
    {
        return 
            "Content-Type:application/x-www-form-urlencoded; charset=UTF-8\r\n" ~
            "Content-Length: " ~ len.to!string ~ "\r\n" ~
            "Connection: Close\r\n\r\n";
    }

}

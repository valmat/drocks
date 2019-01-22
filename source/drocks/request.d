module drocks.request;

import std.stdio   : stderr, writeln;
import std.range     : join, isInputRange, ElementType;
import std.traits    : isIntegral;
import std.algorithm : map;
import std.socket    : InternetAddress, SocketException;
import std.typecons  : Tuple, tuple;
import std.conv      : to;

static import uri = std.uri;

public import drocks.exception : ClientException;
import drocks.sockhandler      : SockHandler;
import drocks.response         : Response;
import drocks.pair             : Pair;

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

        pragma(msg, "DELME ", __FILE__, " ",__LINE__);
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

    //
    // GET requests
    //
    Response httpGet(const string path)
    {
        string buf;
        buf  = "GET /" ~ path  ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;
        return this.request(buf);
    }

    Response httpGet(const string path, string data)
    {
        string buf;
        buf  = "GET /" ~ path  ~ "?" ~ uri.encode(data) ~ " HTTP/1.1\r\n" ~
               "Host:" ~ _host ~ "\r\n" ~
               headsEnd;
        return this.request(buf);
    }

    Response httpGet(T)(const string path, auto ref T data)
        if(isIntegral!T)
    {
        return this.httpGet(path, data.to!string);
    }

    Response httpGet(Range)(const string path, auto ref Range range)
        if(isInputRange!Range && is(ElementType!Range == string))
    {
        string data = range
            .map!( (const string x) {return uri.encode(x);})
            .join("&");

        return this.httpGet(path, data);
    }

    Response httpGet(Args...)(const string path, auto ref Args args)
        if(Args.length > 1)
    {
        return this.httpGet(path, join(tuple(args), '&'));
    }

    //
    // POST requests
    //
    Response httpPost(const string path, string data)
    {
        string buf;
        buf  = headsStartPost(path) ~
               headsEndPost(data.length) ~
               data;

        return this.request(buf);
    }

    Response httpPost(T)(const string path, auto ref T data)
        if(isIntegral!T)
    {
        return this.httpPost(path, data.to!string);
    }

    Response httpPost(const string path)
    {
        return this.request( headsStartPost(path) ~ headsEnd );
    }

    Response httpPost(Range)(const string path, auto ref Range range)
        if(isInputRange!Range && is(ElementType!Range == string))
    {
        return this.httpPost(path, range.join("\n"));
    }

    Response httpPost(Range)(const string path, auto ref Range range)
        if(isInputRange!Range && is(ElementType!Range == Pair))
    {
        string data = range
            .map!( (const Pair x) {return x.serialize;})
            .join("\n");

        return this.httpPost(path, data);
    }

    Response httpPost(Range)(const string path, auto ref Range range)
        if(isInputRange!Range && isIntegral!(ElementType!Range))
    {
        return this.httpPost(path, range.map!"a.to!string");
    }

    Response httpPost(Args...)(const string path, auto ref Args args)
        if(Args.length > 1)
    {
        return this.httpPost(path, join(tuple(args), '\n'));
    }


private:

    static string join(Args...)(auto ref Tuple!Args args, char c)
        if(Args.length > 0)
    {
        static if(is(Args[0] == string)) {
            string data = args[0];
        } else {
            string data = args[0].to!string;
        }
        
        static foreach(enum ind; 1..Args.length) {
            static if(is(Args[ind] == string)) {
                data ~= c ~ args[ind];
            } else {
                data ~= c ~ args[ind].to!string;
            }
        }
        return data;
    }

    enum string  headsEnd = 
        "Content-Type: charset=UTF-8\r\n" ~
        "Connection: Close\r\n\r\n";

    string headsStartPost(const string path)
    {
        return 
            "POST /" ~ path ~ " HTTP/1.1\r\n" ~
            "Host:" ~ _host ~ "\r\n";
    }
    string headsEndPost(size_t len)
    {
        return 
            "Content-Type:application/x-www-form-urlencoded; charset=UTF-8\r\n" ~
            "Content-Length: " ~ len.to!string ~ "\r\n" ~
            "Connection: Close\r\n\r\n";
    }

}

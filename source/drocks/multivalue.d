module drocks.multivalue;

import std.stdio;
import std.typecons;
import std.range;
import std.socket;
import std.string;
import std.algorithm;
import std.conv;
import std.socket;


//public import drocks.exception : ClientException;
//import drocks.sockhandler      : SockHandler;
import drocks.response         : Response;
import drocks.pair             : Pair;

struct MultiValue
{
    Response  _resp;
    //Unique!Response  _resp;
    Pair      _cur;
    this(Response resp)
    //this(Unique!Response resp)
    {
        _resp = resp;
        _cur = Pair(_resp.getKey(), _resp.getValue());
    }

    // The fibonacci range never ends
    bool empty() const
    {
        writeln("****************       empty ", !_resp.isValid());
        return !_resp.isValid();
    }

    // Peak at the first element
    Pair front() const @property
    {
        writeln("****************       front");
        return _cur;
    }

    // Remove the first element
    void popFront()
    {
        writeln("****************       popFront");
        _cur = Pair(_resp.getKey(), _resp.getValue());
        _cur.writeln;
    }

}

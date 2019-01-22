module drocks.multivalue;

import std.stdio;
//import std.typecons;
//import std.range;
//import std.socket;
//import std.string;
//import std.algorithm;
//import std.conv;
//import std.socket;


//public import drocks.exception : ClientException;
//import drocks.sockhandler      : SockHandler;
import drocks.response         : Response;
import drocks.pair             : Pair;

alias MultiPair  = Multi!"getPair";
alias MultiKey   = Multi!"getKey";
alias MultiValue = Multi!"getValue";

struct Multi(string ValueType)
{
    ~this()
    {
        //writeln("~Multi" ~ ValueType);
    }
    Response  _resp;

    alias cursor_t = typeof(mixin("Response.init." ~ ValueType ~ "()"));
    cursor_t _cur;


    this(Response resp)
    {
        //writeln("Multi" ~ ValueType);
        _resp = resp;
        _cur = mixin("_resp." ~ ValueType ~ "()");
    }

    bool empty() const
    {
        //writeln("****************       empty ", !_resp.isValid());
        return !_resp.isValid();
    }
    auto front() const @property
    {
        //writeln("****************       front");
        return _cur;
    }
    void popFront()
    {
        //writeln("****************       popFront");
        _cur = mixin("_resp." ~ ValueType ~ "()");
        //_cur.writeln;
    }

}

module drocks.multivalue;

//import std.stdio;
import drocks.response : Response;
import drocks.pair     : Pair;

alias MultiPair  = Multi!"getPair";
alias MultiKey   = Multi!"getKey";
alias MultiValue = Multi!"getValue";

struct Multi(string ValueType)
{
private:
    alias cursor_t = typeof(mixin("Response.init." ~ ValueType ~ "()"));
    
    Response  _resp;
    cursor_t _cur;

public:

    this(Response resp)
    {
        _resp = resp;
        _cur = mixin("_resp." ~ ValueType ~ "()");
    }

    bool empty() const
    {
        return !_resp.isValid();
    }
    auto front() const
    {
        return _cur;
    }
    void popFront()
    {
        _cur = mixin("_resp." ~ ValueType ~ "()");
    }
}

module drocks.multivalue;

//import std.stdio;
import drocks.response : Response;
import drocks.pair     : Pair;

alias MultiPair  = Multi!"getPair";
alias MultiKey   = Multi!"getKey";
alias MultiValue = Multi!"getValue";

struct Multi(alias fun)
{
private:
    static if (is(typeof(fun) : string)) {
        alias cursor_t = typeof(mixin("Response.init." ~ fun ~ "()"));
        auto _get()
        {
            return mixin("_resp." ~ fun ~ "()");
        }
    } else {
        alias cursor_t = typeof(fun(Response.init));
        auto _get()
        {
            return fun(_resp);
        }
    }    

    Response  _resp;
    cursor_t _cur;

public:

    this(Response resp)
    {
        _resp = resp;
        _cur = _get();
    }

    bool empty() const @property
    {
        return !_resp.isValid();
    }
    auto front() const @property
    {
        return _cur;
    }
    void popFront()
    {
        _cur = _get();
    }
}

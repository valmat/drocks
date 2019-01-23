module drocks.pair;
import std.typecons  : Tuple, tuple;
import std.conv      : to;

struct Pair
{
    string key;
    string value;

    this(string key)
    {
        this.key = key;
    }
    this(string key, string value)
    {
        this.key   = key;
        this.value = value;
    }
    this(Tuple!(string, string) args)
    {
        key   = args[0];
        value = args[1];
    }

    string serialize() const
    {
        return key ~ '\n' ~ value.length.to!string ~ '\n' ~ value;
    }
}

module drocks.pair;
import std.conv : to;

struct Pair
{
    string key;
    string value;

    string serialize() const
    {
        return key ~ '\n' ~ value.length.to!string ~ '\n' ~ value;
    }
}

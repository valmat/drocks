Drocks is a Dlang driver for RocksDB server [RocksServer](https://github.com/valmat/RocksServer)

# Usage

## Create
```D
auto db = Client(host, port);
```
or
```D
auto db = Client.createDefault();
```

## Get

### By single key
```D
string value = db.get(key);
string value = db[key];
```
### By multi keys

```D
auto values = db.get(key1, key2, key3);
auto values = db.get([key1, key2, key3]);
auto values = db.get(keysRange);

auto values = db[key1, key2, key3];
auto values = db[[key1, key2, key3]];
auto values = db[keysRange];
```

## Set / Replace

### By single key
```D
db.set(key, value);
db.set(Pair(key, value));
db[key] = value;
```

### By multi keys

```D
auto range = [
    Pair(key1, val1),
    Pair(key2, val2),
    Pair(key3, val3),
];
db.set(range);
```
```D
auto range = [
    tuple(key1, val1),
    tuple(key2, val2),
    tuple(key3, val3),
];
db.set(range);
```
```D
auto map = [
    key1: val1,
    key2: val2,
    key3: val3,
];
db.set(map);
```

## Delete keys

```D
db.del(key);
db.del(key1, key2, key3);
db.del([key1, key2, key3]);
db.del(keysRange);
```
## Increment value by key

```D
db.incr(key, value);
db.incr(key);

db[key] += 7;
db[key] += -4;
db[key] -= 1;
++db[key];
--db[key];
```
## Check if key exist

```D
bool keyExist = db.has(key);
```
```D
auto keyExist = db.has(key);
bool   has   = db.has(key).has;
string value = db.has(key).value;
```

## Prefix iterator

```D
auto range = db.getall(KeysPrefix);
```
## More details
For more details see [exmaples](exmaples), [tests](tests/readme.md) and
[sources](source/drocks/client.d)

# How to extend

```D
import drocks;
struct CustomClient
{
    mixin ExtendClient;
    //...
}
```

See [exmaple](exmaples/customclient.d):
```D
struct CustomClient
{
    mixin ExtendClient;

    // incriment value by key
    long getIncr(string key, long value)
    {
        return _db.request.httpPost("get-incr", key, value).getValue().to!long;
    }
    long getIncr(string key)
    {
        return _db.request.httpPost("get-incr", key).getValue().to!long;
    }

    // Check if DB server is available
    bool ping() //const
    {
        return "pong" == _db.request.httpGet("ping").raw();
    }

    // Seack first pair by key prefix
    auto seekFirst(string prefix)
    {
        return _db.request.httpGet("seek-first", prefix).getPair();
    }

    // ...
}
```

```D
try {
    auto db = CustomClient.createDefault();
    db.get("key1").writeln;
    db.getIncr("incr1").writeln;
    db.ping().writeln;
    db.seekFirst("key-prefix:").writeln;
} catch (ClientException e) {
    writeln(e.msg);
}
```

# Tests

[see tests readme](tests/readme.md)

# License

[MIT](LICENSE)
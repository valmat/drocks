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


# How to extend


# Tests

[see tests readme](tests/readme.md)

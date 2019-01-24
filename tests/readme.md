# Run tets for drocks - RocksServer client

## Compile

```bash
make
```

## Run

```bash
$ ./tests.bin -h
Run tets for drocks - RocksServer client
-b --binary RocksServer binary file location.
		Default: "/usr/local/bin/rocksserver"
-c --config RocksServer config file location.
		By default created automatically
-t    --tmp temporary dir.
		Default: "/tmp/rocksserver.2015897473"

-p   --port DB port. Default: "5541".

-k   --keep Keep temporary files after tests finished.

-h   --help This help information.

```

Opthions:

`-b --binary` specifies RocksServer binary file location.
        Default: "/usr/local/bin/rocksserver"

`-c --config` specifies RocksServer config file location.
		By default created automatically

`-t --tmp` specifies temporary directory.
    		Default: "/tmp/rocksserver.2015897473"

`-p --port` specifies RocksServer port. Default: "5541".

`-k --keep` Keep temporary files after tests finished.

No one options are required


```bash
./tests.bin
```

# replay

Record & Replay proxy.

## Installation

### From Sources

```console
$ git clone https://github.com/y2k2mt/replay && cd replay
$ make clean && make install
```

## Usage

Recording mode.
```console
$ replay -r http://your-awesome-web-api
...
$ curl localhost:8080/endpoint
Hello # Record and return a response from the real server.
```

Replaying mode.
```console
$ replay -R http://your-awesome-web-api
...
$ curl localhost:8080/endpoint
Hello # Answering from 'replay' server.
```

## Contributing

1. Fork it (<https://github.com/y2k2mt/replay/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [y2k2mt](https://github.com/y2k2mt) - creator and maintainer

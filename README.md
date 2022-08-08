# replay

Record & Replay proxy.

## Installation

### From Sources

```console
$ git clone https://github.com/y2k2mt/replay && cd replay
$ make clean && make install
```

## Usage

Recording

```console
$ replay -r http://your-awesome-api
...
$ curl localhost:8899/endpoint
Hello # Record and return a response from the real server.(http://your-awesome-api/endpoint)
```

Replaying(Work as a mock server)

```console
$ replay -R http://your-awesome-api
...
$ curl localhost:8899/endpoint
Hello # Answering from 'replay' server.
```

## RoadMap

- Ideomatic refactor
- More flexible condition matching
- Support more protocol (Implements by pure TCP API)
- Condition editor UI

## Contributing

1. Fork it (<https://github.com/y2k2mt/replay/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [y2k2mt](https://github.com/y2k2mt) - creator and maintainer

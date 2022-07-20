CRYSTAL_BIN ?= crystal
SHARDS_BIN ?= shards
PREFIX ?= /usr/local
SHARD_BIN ?= ../../bin
CRFLAGS ?= -Dpreview_mt

build: bin/replay
bin/replay:
	$(SHARDS_BIN) build $(CRFLAGS)
clean:
	rm -f ./bin/replay
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/replay $(PREFIX)/bin
bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/replay $(SHARD_BIN)
test: build
	$(CRYSTAL_BIN) spec
	./bin/ameba --all

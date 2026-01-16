CC := crystal
OPTS := --error-on-warnings
ifeq ($(MODE),release)
	OPTS += --release --no-debug
else
	OPTS += -O0 --debug
endif

ALL := $(wildcard src/*.cr)
MAIN := src/main.cr
OUT := calc

all: $(OUT)

run: $(OUT)
	./$(OUT)

$(OUT): $(MAIN) $(ALL)
	$(CC) build $(OPTS) $< -o $@

.PHONY: clean
clean:
	rm -f $(OUT)

lint:
	shellcheck swn-supervise
	shellcheck swn-watch
.PHONY: lint

test-supervise-true:
	SWN_DRYRUN=1 \
	SWN_CHECK_COMMAND=true \
	WATCHDOG_USEC=5000000 \
	./swn-supervise sleep 30
.PHONY: test-supervise-true

test-supervise-false:
	SWN_DRYRUN=1 \
	SWN_CHECK_COMMAND=false \
	WATCHDOG_USEC=5000000 \
	./swn-supervise sleep 30
.PHONY: test-supervise-true

test-supervise-watch-okay:
	SWN_DRYRUN=1 \
	SWN_CHECK_COMMAND=./swn-watch \
	SWN_WATCH_CHECKER=true \
	SWN_WATCH_COMMAND=./fake-watch-command \
	SWN_WATCH_PATTERN="mavis" \
	WATCHDOG_USEC=5000000 \
	./swn-supervise sleep 30
.PHONY: test-supervise-watch-okay

test-supervise-watch-fail:
	SWN_DRYRUN=1 \
	SWN_CHECK_COMMAND=./swn-watch \
	SWN_WATCH_CHECKER=true \
	SWN_WATCH_COMMAND=./fake-watch-command \
	SWN_WATCH_PATTERN=".* saw .* fnords" \
	WATCHDOG_USEC=5000000 \
	./swn-supervise sleep 30
.PHONY: test-supervise-watch-fail

test-supervise-fake-watch:
	WATCHDOG_USEC=5000000 \
	SWN_CHECK_COMMAND=./swn-fake-watch \
	SWN_WATCH_CHECKER=true \
	SWN_DRYRUN=1 \
	swn-supervise sleep 30
.PHONY: test-supervise-fake-watch

test-watch-okay:
	SWN_DRYRUN=1 \
	SWN_CHECK_COMMAND=./swn-watch \
	SWN_CHECK_TIMEOUT=3 \
	SWN_WATCH_COMMAND=./fake-watch-command \
	SWN_WATCH_PATTERN="mavis" \
	./swn-watch
.PHONY: test-watch-okay

test-watch-fail:
	SWN_DRYRUN=1 \
	SWN_CHECK_COMMAND=./swn-watch \
	SWN_CHECK_TIMEOUT=3 \
	SWN_WATCH_COMMAND=./fake-watch-command \
	SWN_WATCH_PATTERN=".* saw .* fnords" \
	./swn-watch
.PHONY: test-watch-fail

install:
	install -m 0755 swn-supervise /usr/bin/
	install -m 0755 swn-watch /usr/bin/
.PHONY: install

uninstall:
	rm -fv /usr/bin/swn-supervise
	rm -fv /usr/bin/swn-watch
.PHONY: uninstall

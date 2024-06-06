# SWN: SystemD Watchdog Notifier

a simple process supervisor with systemd watchdog notifications

this repository contains two utilities `swn-supervise` and `swn-watch`.

`swn-supervise` is a simple and opinionated process supervisor which performs
the following functions:

1. forks all subsequent command line arguments as a background process
1. uses `sd_notify(3)` to send `WATCHDOG=1` notifications to systemd at the required interval
1. monitors the background job to see if it is still running; if not, stops sending `WATCHDOG=1` notifications to systemd
1. one of the following health check tasks, based on user configuration:
   1. forks a configured "check" command at the required watchdog interval and monitors exit status; if non-zero status, stops sending `WATCHDOG=1` notifications to systemd
   1. execs a configured "check" service which then takes over all notification responsibilities

all other elements of the process lifecycle are left up to systemd.

`swn-watch` is a bundled "check" service which performs the following duties:

1. uses `sd_notify(3)` to send `WATCHDOG=1` notifications to systemd at the required interval
1. in its default configuration, watches `journalctl` output of a configured systemd service, can be overridden to use a custom watch command
1. watches for a configured regex pattern in the watch command output; if any line matches, stops sending `WATCHDOG=1` notifications.

## build/install

clone this repository

install:

```shell
sudo make install
```

uninstall:

```shell
sudo make uninstall
```

## usage

`swn-supervise` is intended to be used with systemd services. command line arguments
are invoked as a subprocess unmodified. for this reason, all configuration for
`swn-supervise` must be provided via environment variables.

`swn-supervise` can be prepended to any existing `ExecStart=`. for example,
`ExecStart=/usr/bin/collectd` becomes `ExecStart=swn-supervise /usr/bin/collectd`

## configuration

see `system_collectd.service.d_override.conf` for an example of how to patch a
watchdog notifier into an existing systemd service. the unit file would be installed
to `/etc/systemd/system/collectd.service.d/override.conf`.

see `system_swn-fake-watch.conf` for an example which uses a fake watch service and
will be killed by systemd due to watchdog timeout. the unit file would be installed
to `/etc/systemd/system/swn-fake-watch.conf` and depends on `swn-fake-watch` being
manually installed/executable in a system path (eg. `/usr/bin/swn-fake-watch`)

### swn-supervise

#### `SWN_CHECK_COMMAND`

**accepted values: any single argument supported by the `which` command**

**required: true**

command which will be executed to determine the health status of the systemd service.

the `SWN_CHECK_COMMAND` must be the full path to an executable, or an executable in
your system path with no other arguments. spaces will be interpreted as being part
of the command path and will likely result in an error.

if you need to pass additional configuration to a check command, they will need to
be passed via another mechanism, such as configuration file or environment variables.

by default, `SWN_CHECK_COMMAND` will be invoked at the correct systemd provided `WatchdogSec`
interval and a successful exit code will trigger a systemd `WATCHDOG=1` notification.

you can create your own `SWN_CHECK_COMMAND`. this doesn't support command line arguments
so you will need to pass any additional configuration via environment variables or
using an external configuration file.

#### `SWN_WATCH_CHECKER`

**accepted values: true, false**

**default: false**

to run the check as a stateful service, set `SWN_WATCH_CHECKER=true`.
in this case, the service must send systemd notifications on its own. if the watcher exits,
or misses a notification, configured restart behavior for the systemd unit will be triggered.

### `swn-watch`

#### `SWN_WATCH_SERVICE`

**accepted values: any valid systemd service name**

a systemd service to watch for `journalctl` for lines matching the `SWN_WATCH_PATTERN`

if not specified, a custom `SWN_WATCH_COMMAND` must be specified.

#### `SWN_WATCH_PATTERN`

**accepted values: any bash compatible regular expression**

**required: true**

pattern to watch for in the output of `SWN_WATCH_COMMAND`.

when the pattern is found in the output, `swn-watch` will exit immediately.

#### `SWN_WATCH_COMMAND`

**default: `journalctl -u ${SWM_WATCH_SERVICE} -n 0 -f`**

the command to use as a generator of lines to match the `SWN_WATCH_PATTERN` against.

NOTE: if `SWN_WATCH_SERVICE` is not specified, the command must be set manually.

## tests

```shell
# test when check command always exits status 0
make test-supervise-true

# test when check command always exits status 1
make test-supervise-false

# test when watch command produces a match after 10 seconds
make test-supervise-watch-fail

# test when watch command never produces a match
make test-supervise-watch-okay

# test when check service notifies WATCHDOG=1 twice and then no more
make test-supervise-fake-watch
```

## references

- https://0pointer.de/blog/projects/watchdog.html
- https://www.medo64.com/2019/01/systemd-watchdog-for-any-service/

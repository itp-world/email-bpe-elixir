# Email Delivery Engine in Elixir

This project provides an [Elixir](http://elixir-lang.org) based background processing engine for email delivery.
It uses [Exq](https://github.com/akira/exq) job processing library, [Quantum](https://github.com/c-rack/quantum-elixir) cron-like job scheduler, [Timex](https://github.com/bitwalker/timex) date/time library, [Mailman](https://github.com/kamilc/mailman) mailer, [UUID](https://github.com/zyro/elixir-uuid) generator, [Mongodb](https://github.com/ericmj/mongodb) driver and [HTTPotion](https://github.com/myfreeweb/httpotion) HTTP client.

## Requirements

### [Erlang](http://www.erlang.org), [Elixir](http://elixir-lang.org) and [Redis](http://redis.io)

Example for Ubuntu 12.04 or newer / Debian 7:

```bash
$ cd /tmp
$ wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
$ sudo dpkg -i erlang-solutions_1.0_all.deb
$ sudo apt-get update
$ sudo apt-get install erlang elixir redis-server
```

### [MongoDB](https://www.mongodb.org)

Follow the instructions on [Install MongoDB Community Edition on Linux](https://docs.mongodb.org/master/administration/install-on-linux/).

## Installation

### Get the sources:

```bash
$ git clone https://github.com/itp-world/email-bpe-elixir.git
$ cd email-bpe-elixir
```

### Get dependencies and compile:

```bash
$ mix deps.get
$ mix compile
```

## Startup

### Job Processing:

```bash
$ mix run --no--halt (Stop with CTRL-C)
```

### UI Dashboard:

**Disabled in case of potential memory leak in `Exq.Middleware.Stat` currently!**

```bash
$ mix exq.ui (Stop with CTRL-C)
```

Open http://localhost:4040 in your preferred browser.

### Debugging:

```bash
$ iex -S mix run (Stop with CTRL-C)
iex(bpe@127.0.0.1)1> :observer.start()
```

A GUI will open with a lot of information about the running state of the app.

### Erlang VM crash dumps:

```bash
$ erl -s crashdump_viewer
```

This starts the [Crashdump Viewer](http://erlang.org/doc/apps/observer/crashdump_ug.html)
GUI and loads the given file. If no file name is given, a file dialog will be
opened where the file can be selected.

## Email delivery service

To run the email delivery engine a template engine service is needed to create the HTML body of the EML files.
For a quick start use the [bpe-service-freemarker](https://github.com/itp-world/bpe-service-freemarker)
project. After its setup and start execute in different terminals the following commands:

* Terminal #1 - Start Ratpack/Freemarker

  ```bash
  $ cd /path/to/bpe-service-freemarker
  $ gradle installApp
  $ ./build/install/service-freemarker/bin/service-freemarker
  ```
* Terminal #2 - Start Background processing engine for email delivery

  ```bash
  $ cd /path/to/email-bpe-elixir
  $ mix run --no-halt
  ```
* Terminal #3 - Create and enqueue a job

  ```bash
  $ cd /path/to/email-bpe-elixir
  $ mix bpe.jobs.create -j 1 -r 10000
  $ mix bpe.enqueue.job_poller_worker
  ```

The generated EML files are located under `/path/to/email-bpe-elixir/tmp/smtp`.

### Jobs Generation

```bash
$ mix bpe.jobs.create
Usage: mix bpe.jobs.create <options>

  Options:
  --help       -h             this help
  --jobs       -j <Integer>   number of jobs
  --recipients -r <Integer>   number of recipients per job
  --sendat        <DateTime>  UTC date emails are sent to recipients, optional
                              e.g. 2016-02-05T14:59:38Z (ISO 8601)
  --nosendtime    <String>    optional UTC time interval during which no emails
                              are allowed to be sent, format "HH:MM HH:MM"
```

### Enqueue Job Poller Worker

```bash
$ mix bpe.enqueue.job_poller_worker
```

### (Un)Subscribe Exq Queues

You need to guarantee `epmd` (Erlang Port Mapper Daemon) is running on a port that is not blocked (you can run `epmd -d` for debug info) and you need to ensure all machines have a `~/.erlang.cookie` file with exactly the same value.

```bash
$ mix bpe.client.queue_manager
Usage: mix bpe.client.queue_manager <options>

  Options:
  --help   -h            this help
  --node   -n <String>   node name of the BPE instance
  --queue  -q <String>   exq queue name to (un)subscribe
  --worker -w <Integer>  number of workers for subscription (optional)
  --(un)subscribe        (un)subscribes the queue
```

### Reset BPE

```bash
$ mix bpe.reset
```

This will reset Redis / MongoDB and delete the `./tmp/` directory.

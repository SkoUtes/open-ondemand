import sys

from supervisor.childutils import listener

def write_stdout(s):
    sys.stdout.write(s)
    sys.stdout.flush()


def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


def main():
    while True:
        headers, body = listener.wait(sys.stdin, sys.stdout)
        body = dict([pair.split(":") for pair in body.split(" ")])
        write_stderr("Headers: %r\n" % repr(headers))
        write_stderr("Body: %r\n" % repr(body))
        listener.ok(sys.stdout)

        if headers["eventname"] == "PROCESS_STATE_STOPPED":
            write_stderr("Process state stopped...\n")


if __name__ == '__main__':
    main()
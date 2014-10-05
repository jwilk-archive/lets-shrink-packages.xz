#!/usr/bin/python3

import sys
import subprocess as ipc

fields = set()

def check_size(data, exclude=None):
    if exclude is None:
        data = b''.join(data)
    else:
        prefix = exclude.encode('ASCII') + b':'
        def f(s):
            return not s.startswith(prefix)
        data = b''.join(filter(f, data))
    cmdline = 'xz | wc -c'
    xz = ipc.Popen(cmdline, shell=True, stdin=ipc.PIPE, stdout=ipc.PIPE)
    stdout, stderr = xz.communicate(data)
    if xz.returncode:
        raise ipc.CalledProcessError(xz.returncode, cmdline)
    return int(stdout)

def main():
    data = []
    for line in sys.stdin.buffer:
        if line[:1] == b' ':
            data[-1] += line
        else:
            if len(line) > 1:
                field, rest = line.split(b':', 1)
                field = field.decode('ASCII')
                fields.add(field)
            data += [line]
    pristine_size = check_size(data)
    def p(field, size):
        print('{:23s}\t{:12.1f} KiB\t({:7.1%})'.format(
            field,
            size / 1024.0,
            1.0 * size / pristine_size)
        )
    p('*', pristine_size)
    for field in sorted(fields):
        reduced_size = check_size(data, field)
        p(field, pristine_size - reduced_size)

if __name__ == '__main__':
    main()

# vim:ts=4 sts=4 sw=4 et

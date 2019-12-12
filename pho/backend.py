def _print(msg):
    from sys import stdout
    stdout.write(msg)
    stdout.write('\n')
    stdout.flush()


if '__main__' == __name__:

    from pho import HELLO_FROM_PHO as hello_message
    from sys import argv

    _print(hello_message)

    args = argv[1:]

    if len(args):
        from time import sleep
        first, *rest = args

        _print(f"one argument: '{first}'")

        count = 1
        for arg in rest:
            count += 1

            if 0 == count % 2:
                sleep(0.718)
            else:
                sleep(1.180)

            _print(f"one argument: '{arg}'")

    _print("done from backend.")
    exit(0)


print("WWWWOOOOWWWWWW")


def say_hello(s):
    return f"COOL PERSON {s.upper()}"

# #history-A.1: begin for electron
# #born.

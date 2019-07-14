def JOB_VIA_WEB_FIELD(field, jobser):
    """(this function is web-only but because it's so small it's..

    .. a stowaway here
    """

    self = _JobViaWebField()
    self._ok = True

    def __main():
        __check_content_type()
        self._ok and __save_file()
        if self._ok:
            return self._job

    def __save_file():
        self._job = jobser.begin_job()
        file_storage.save(self._job.big_json_dump_path)

    def __check_content_type():
        cs = file_storage.content_type
        need = 'application/json'
        if cs != need:
            _fail_because('needed {} had {}', need, cs)
            _fail_because('(is file extension ".json"?')

    def _fail_because(msg, *a):
        _tmpl = field.gettext(msg)
        _msg = _tmpl.format(*a)
        field.errors.append(_msg)
        self._ok = False

    file_storage = field.data
    return __main()


class _JobViaWebField:
    def __init__(self):
        self._job = None
        self._ok = None


class IndexingJob:
    """(injected into the jobser, makes it more task-specific by one member)"""

    def __init__(self, o):
        import os
        self.big_json_dump_path = os.path.join(o.path, 'BIG_JSON_DUMP.json')
        self.path = o.path
        self.job_number = o.job_number


def SELF(
        upstream_lines_iterator,
        listener,
        ):
    r"""write the Big Index (a filetree) given a dump (a file).


    Broad design objectives and expected environment:

    the goal is to structure this module (file) in a straightforward, self-
    contained manner; but the behavior we design into it will target several
    objectives that are perhaps unusual. first, the axiom:

      - this is seen as a possibly "long-running", "batch job".

    ideally this job will take at most a few seconds (but we don't want it
    to fall over if it takes a few minutes or longer). but the central
    conceit here is that we want the client (it's a web browser but pretend
    we don't konw that) to get back a response from the initial request
    "immediately", even though the job itself will take some time to complete.

    the client will then have the ability to get "continuous" feedback about
    the progress of the job, until it finishes (which the client is notified
    of).

    so, to the end of running this possibly long-running job while giving
    the client progressive updates:

      - don't leak memory or otherwise scale assuming infinite memory
      - assume we are running asynchronously (concurrently)

    in more detail to this second point, we can expect (but don't assume)
    that we are running in our own process, separate from the request handler
    that invokes us.

      - process not thread. there is probably nothing to be gained and
        everything to lose by trying to do this in a worker thread.

      - probably we will fork, but watch out for zombie processes..

      - fork and not `system` just because we don't need the overhead
        of firing up a new python interpreter when we are already in one.

    HOWEVER keep in mind that this whole module (file) must be written fully
    ignorant of the outside ecosystem (other processes, threads) that may
    have invoked it. this is both so that the module is more flexible,
    future-proof, modular, resilient (etc); but also because it will be
    easier to test/develop/maintain.


    Mini-spec: the logfile structure:

    in effect the whole outward-facing interface is just a logfile. if
    any client wants to know the progress of the job, it needs only know
    the path to the logfile and its format.

      - every line of the logfile will be terminated with a newline.
        (when discussing the lines here, we won't show the newlines.)

      - the first line of the logfile will always be this: "begun."

      - when the job is finished, the last line of the logfile will
        be this: "finished."

      - (so note the minimum size of any finished lofile is 2 lines.)

      - every line that is not the first line or the last line is
        a "line-item line" (defined below).

    the most interesting part of this grammar is these "line-item" lines.
    the line item line consists of two parts, separated by a single space:

      - the "share complete" number

      - the description

    about the "share complete" term:

      - it is always a float. '0.0' means we are near the beginning,
        '1.0' means we are near the end. (do not use integers (`0` and `1`).)

      - typically clients will multiply the share complete number by 100
        to get a "percent complete" term. (but possibly the client is only
        doing something like a visual progress bar, etc.)

      - (redundantly) the "share complete" number will never be less than
        0 or greater than 1.

      - we intentionally don't specify a precision (but we probably wouldn't
        exceed two bytes of precision, whatever that gets us).

      - NOTE the share complete float CAN change directions. (that is, each
        next line item does not necessarily have a greater "share complete"
        than the previous line.) we make this provision to allow ourselves
        to make "estimates" with incomplete information; estimates that
        improve their accuracy over time as more information comes in.
        (however, we would preer that we never do this.)

    of the "description" term:

      - (corollaraly) it cannot contain a newline character.

      - it must be at least one character wide.

      - it must contain at least one nonblank character.

      - it SHOULD NOT have trailing whitespace.

      - it SHOULD NOT make use of tabs (use spaces instead).

    our spec for the description term intenionally allows for the possibility
    of a novel use of indenting (after the obligatory single space that
    separates the percent from the description). however: this whole space
    is a "shadow provision". we'll wait and see if it is useful to produce
    psudo-structured line items and/or how much a headache is. after an
    incubation period we may refine the spec near here somewhat. or not 😛

    formal-esque-ly:

        complete_logfile ::= first_line item_line* last_line
        first_line ::= "begun.\n"
        last_line ::= "finished.\n"
        item_line ::= share_complete ' ' description "\\n"
        share_complete ::= /\d+\.\d+/
        description ::= /[ ]*[[:graph:]]([ [:graph:]]*[:graph:]])?/

    (that "description" regex is a rough, eyeblood estimation

    corollaries of the above:

      - there can be no blank lines.

    there is the whole issue with how our backend will fulfill requests
    from a client for a progress report, and what structure these resposes
    take, but that will be the subject of a sibling magnet.
    """  # :[#203]

    def __main():

        line = None
        for line in upstream_lines_iterator:
            break
        if line is None:
            return __when_no_lines_in_file()
        else:
            return __when_one_or_more_lines(line)

    def __when_one_or_more_lines(first_line):

        line = None
        for line in upstream_lines_iterator:
            break
        if line is None:
            return __when_only_one_line_in_file(first_line)
        else:
            return __when_more_than_one_line_in_file(line, first_line)

    def __when_more_than_one_line_in_file(second_line, first_line):
        raise Exception('cover me - more than one upstream line')

    def __when_only_one_line_in_file(line):
        return _VISUAL_TEST(line)

    def __when_no_lines_in_file():
        raise Exception('cover me - no upstream lines')

    # ==

    def _VISUAL_TEST(line):
        _log('(ignoring dummy line: {})', repr(line))

        import time

        def _yikes():
            yield 'begun.'
            for i in range(1, 11):
                time.sleep(0.666)
                yield ('%f line item number %d' % ((0.10 * i), i))
            yield 'finished.'

        return _yikes()

    # ==

    def _log(msg, *a, **kw):
        def expr():
            yield msg.format(*a, **kw)
        listener('info', 'expression', expr)

    # ==

    return __main()


if __name__ == '__main__':

    from sys import argv
    if 2 != len(argv) or '-' == argv[1][0]:
        print('usage: {} <file>'.format(argv[0]))
        exit(5)

    def _listener(*chan):
        for line in chan[-1]():
            print(line)

    with open(argv[1]) as fh:
        itr = SELF(fh, listener=_listener)

    for line in itr:
        print("line: {}".format(repr(line)))

    print("done!")


# #history-A.1: inject visitor for web only
# #born.

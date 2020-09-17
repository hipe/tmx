

def SELF(
        last_known_number_of_line_items,
        logfile_line_upstream,
        ):

    """result in a hash (suitable to be JSON-ified) describing the progress.

    our [#203] sibling magnet specifies the structure and meaning of
    "the logfile". the subject magnet is for processing requests inquiring
    as to the status of the job. here we specify the details of *that*
    interaction.

    to simplify terminology, we'll say that the thing inquiring about the
    job is "the client" and the thing processing the job is "the server".

    the server does not keep track of clients. (this reflects what is meant
    by saying that HTTP is a "stateless" protocol.) as such, it is incumbent
    on the client to tell the server how far along things were the last time
    the client checked.

    fundamentally this interaction is mediated through counting line-items.

    (refer back to the terminology introduced in [#same] because we'll be
    using elements of it heavily: "line-item", ..)

    the client tells the server, "hey. last time i checked, i found out that
    you had completed 14 line items total. do you have more than this now?"

    the server will be like, "yes. i have 3 more (so i have completed a
    total of 17 line-items. here they are."

    also the server at each step tells the client the "share complete"
    number (an estimate, used to show a percentage complete).

    additionally, we will maintain a separate parameter (sent from server
    to client) that's *just* a boolean saying yes/no whether the job is
    complete. (we don't rely simploy on the "share complete" term to derive
    this because it's conceivable that the server could report a share
    complete number of 1.0 but not actually be done, based on factors like
    precision or if the estimation is off.)


    More formally, the request structure:
        - job number
        - last known number of line items (integer, 0 or more)


    More formally, the response structure (normally):
        - job is complete (boolean)
        - share complete (float)
        - last known number of line items (integer, 0 or more)
        - your last known number of line items (the number sent in the request)
        - an array of the 0 or more line items
          - each line item is the description string of the line item


    Issues/wishlist:
        - the whole file is read on every request.
    """

    def __main():
        __advance_over_the_first_line()
        item_count, line = __skip_over_lines_you_are_not_interested_in()

        job_is_finished = False
        new_item_descriptions = []
        md = None

        for line in logfile_line_upstream:

            if _FINAL_LINE == line:
                job_is_finished = True
                break

            md = _matchdata_via_line(line)
            if md is None:
                _fmt = 'malformed item line: {}'
                raise _MyException(_fmt.format(repr(line)))

            item_count += 1

            new_item_descriptions.append(md['desc'])

        for line in logfile_line_upstream:
            _fmt = 'unexpected extra line in file: {}'
            raise _MyException(_fmt.format(repr(line)))

        if job_is_finished:
            share_complete_float = 1.0  # (Case499)
        elif item_count > last_known_number_of_line_items:
            share_complete_float = float(md['share'])  # (Case500)
        elif item_count == 0:
            share_complete_float = 0.0  # (Case497)
        else:
            # your item count is nonzero, but your item count does not
            # exceed that of the client's last known item count (Case503)
            md = _matchdata_via_line(line)
            share_complete_float = float(md['share'])  # ..

        return {
            'job_is_complete': job_is_finished,
            'share_complete': share_complete_float,
            'last_known_number_of_line_items': item_count,
            'your_last_known_number_of_line_items':
                last_known_number_of_line_items,
            'zero_or_more_new_line_item_descriptions': new_item_descriptions,
        }

    def _matchdata_via_line(line):
        return line_regex.search(line)

    import re
    line_regex = re.compile(
            r'^(?P<share>\d+\.\d+)'
            '[ ]'
            r'(?P<desc>[^\n]+)\n')
    # (although we waste a little effort regexing share values that we don't
    # end up using, it's better to catch a malformed file early.)

    def __skip_over_lines_you_are_not_interested_in():
        """if you knew that there were 3 line items (total) last time

        then in order to get the file head lined up to where you want it,
        it's easy: simply go over that many lines.
        """

        if last_known_number_of_line_items == 0:
            # nothing to do - don't advance file head
            return (0, None)
        else:
            return __skip_over_lines_you_are_not_interested_in_normally()

    def __skip_over_lines_you_are_not_interested_in_normally():
        """advance the file's read cursor to just past the last seen line item

        normally, result is a tuple (see).

        the central game mechanic of our host module is to send back to the
        client only those line items it hasn't seen yet. this function is
        where we skip over the line items in the logfile that the client has
        already seen (according to the client).

        this would be very simple were it not for an important error case
        that we need to check for.

        assume you are advanced just past the static "begun" line.

        in a normal interaction, all that needs to happen is that we read
        that number of lines that corresponds to the number of line items
        that the client reports as having already seen.

        but imagine if the client reports having seen more line items than
        actually exist in the logfile. a couple of bad things can happen
        depending on our state:

            - if the job is finished, we would traverse over the static
              terminator line accidentally counting it as a line item here,
              and certainly wreaking havoc (hard to find bugs) downstream
              when the latter code looks for and doesn't see the terminator
              line.

            - whether or not the job is finished, different kinds of bad
              things would happen depending on what we use to drive our
              below loop.

        so anyway, it's always an error to traverse over the terminator
        line, and we can't not check for it because of how nasty the bug
        would be.
        """

        found_expected_number_of_items = False
        real_item_count = 0
        last_line = None

        for last_line in logfile_line_upstream:

            if _FINAL_LINE == last_line:
                break

            real_item_count += 1
            if last_known_number_of_line_items == real_item_count:
                found_expected_number_of_items = True
                break

        if found_expected_number_of_items:
            return (real_item_count, last_line)
        else:
            _fmt = 'expected {exp} existing line items in logfile, '\
                    'had {act}'
            _msg = _fmt.format(
                    act=real_item_count,
                    exp=last_known_number_of_line_items)
            raise _MyException(_msg)  # (Case505)

    def __advance_over_the_first_line():

        line = next(logfile_line_upstream)
        line = line.rstrip('\n')

        if line != 'begun.':
            _fmt = 'malformed logfile (first line): {}'
            raise _MyException(_fmt.format(repr(line)))

    return __main()


class Exception(Exception):
    """(local version so client can catch those specific to this moudule)"""
    pass


_MyException = Exception  # (future-proof our code from our name choice)


if __name__ == '__main__':

    from sys import argv
    if 3 != len(argv) or '-' == argv[1][0]:
        print('usage: {} <logfile> <last-lineitem-number>'.format(argv[0]))
        exit(5)

    _, logfile, last_line_item_number = argv
    last_line_item_number = int(last_line_item_number)
    with open(logfile) as fh:
        xx = SELF(
            last_known_number_of_line_items=last_line_item_number,
            logfile_line_upstream=fh)

    print('wahoo: {}'.format(repr(xx)))


_FINAL_LINE = 'finished.\n'


# #born.

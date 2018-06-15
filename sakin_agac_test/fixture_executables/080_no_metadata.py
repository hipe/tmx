class open_dictionary_stream:
    """(example with no metadata)"""

    def __init__(self, cache_path, listener):
        pass

    def __enter__(self):
        yield {'choovo chavo': 'fuu fee'}

    def __exit__(*_):
        return False  # no, we don't trap exceptions


if __name__ == '__main__':
    raise Exception('(see [#410.H])')
    """
    about exceptions tagged :[#410.H]:
      - these fixture executables are not actually executable
      - but they could be made executable trivially.
      - we haven't done so only for lack of need, and to keep them DRY KISS

    we have nonethelss flipped the executable bit to true:
      - so there is an upgrade path laid down in case we decide to yes do this.
      - so that the files more accurately resemble real life such files.
    """

# #born.

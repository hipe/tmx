_this_one_path = './tilex-doc/890.C.youtube-tutorial-dim-sum.rec'

def WRITE_JSON__INTERFACE_IS_EXPLORATORY(sout, stop):
    def main():
        w = sout.write
        w('{\n"tilexResponseType": "ok",\n"responsePayload": [\n')
        import json
        is_first = True
        for dct in the_stream_of_jsonables():
            if is_first:
                is_first = False
            else:
                w(',\n')
            json.dump(dct, sout, indent='  ')
        w(']}\n')
        return 0

    def the_stream_of_jsonables():
        """Whereas the database only has video entries (leaf nodes), we want the
        output to have nodes for both video entries and their containing playlists
        ("branch" nodes, i.e. "groups"). The output can be in any order, but make
        sure the node identifiers (offsets) are right, in both their identity
        and their reference.

        We do this by: each time you see a playlist name for the first time,
        output a node for it.
        """

        node_offset_via_playlist_name = {}
        current_offset = -1
        for ent in all_the_entities():
            current_offset += 1
            playlist_name = ent.playlist
            if playlist_name not in node_offset_via_playlist_name:
                yield {k: v for k, v in jsonable_playlist(playlist_name, current_offset)}
                node_offset_via_playlist_name[playlist_name] = current_offset
                current_offset += 1
            playlist_node_offset = node_offset_via_playlist_name[playlist_name]
            yield {k: v for k, v in jsonable_video(ent, playlist_node_offset, current_offset)}

    def jsonable_playlist(playlist_name, current_offset):
        yield 'key', current_offset
        yield 'isGroup', True
        yield 'text', playlist_name
        yield 'fill', "(random color)"  # this doesn't feel right. groups have color?

    def jsonable_video(ent, playlist_node_offset, current_offset):
        yield 'key', current_offset
        yield 'isGroup', False
        yield 'parent', playlist_node_offset
        yield 'text', ent.video_title
        yield 'fill', "(random color)"  # about to change NOTE
        yield 'size', ent.duration_in_seconds

    def all_the_entities():
        colz = _collectioner_via(_this_one_path, stop)
        coll = colz['YoutubeVideo']
        return coll.where()

    return main()


def _collectioner_via(collection_path, stop):
    from kiss_rdb.storage_adapters.rec import \
            collections_via_main_recfile as func

    def bridger(colz):
        return _model(colz, stop)

    return func(_this_one_path, 'YoutubeVideo', bridger)


def _model(colz, stop):
    result = {}
    from dataclasses import dataclass

    @dataclass
    class YoutubeVideo:
        video_ordinal: int
        video_title: str
        playlist: str
        duration: str

        @property
        def duration_in_seconds(self):
            return _duration_seconds_via_stored_string(self.duration, stop)

    result['YoutubeVideo'] = YoutubeVideo
    return result


def _duration_seconds_via_stored_string(duration_string, stop):
    if (-1 == (pos := duration_string.find(':'))):
        stop(f"strange duration value, expecting ':': {self.duration!r}")
    min_s, sec_s = duration_string.split(':', 1)

    def go(int_s):
        try:
            return int(int_s)
        except ValueError as err:
            stop(str(err))

    min_i, sec_i = (go(s) for s in (min_s, sec_s))
    return (60 * min_i) + sec_i

# #born

module Skylab::DocTest

  module Models_::TestFileContext

    # at present this exists only to assist shared setup of the
    # "defined constant" variety [#010]:C (see).
    # its essential function is to be given a path like:
    #
    #     PATH = "test/1-abc-def/ghi-jkl_speg.kode"
    #
    # and produce a stem like this:
    #
    #     o = Home_::Models_::TestFileContext.via_path PATH
    #     o.short_hopefully_unique_stem  # => "ad_gj"
    #
    # which is the first "letter" of every "word" where etc (three things)
    #
    # the astute reader would be correct to guess that we have written the
    # above examples a bit less directly than we normally would, *so that*
    # we can test *both* the subject *and* the facility described at that
    # document reference (that is, both deriving a short, hopefully unique
    # stem from a path *and* "defined constant" as shared setup WHEW!)

    class << self

      def default_instance__
        @___default_instance ||= ViaString__.new "xkcd"
      end

      def via_path local_path

        _String = Home_.lib_.basic::String

        _scn = _String.line_stream local_path, ::File::SEPARATOR

        via_entry_scanner _scn
      end

      def via_entry_scanner scn

        begin
          scn.unparsed_exists || break
          if HARDCODED___ == scn.current_token
            scn.advance_one
            break
          end
          scn.advance_one
          redo
        end while above

        if ! scn.unparsed_exists
          self._FAIL_etc
        end

        _st = scn.to_stream
        _ = _st.join_into_with_using_by "", UNDERSCORE_, :concat do |entry|

          _stem = THING_DING_RX___.match( entry )[ :stem ]

          _stem.split( DASH_ ).reduce "" do |m, s|
            m.concat s[0]
          end
        end

        ViaString__.new _
      end
    end  # >>

    # ==

    HARDCODED___ = 'test'
    THING_DING_RX___ = /\A(\d+-)?(?<stem>[^_]+)/

    class ViaString__

      def initialize s
        @short_hopefully_unique_stem = s
      end

      attr_reader(
        :short_hopefully_unique_stem,
      )
    end

    # ==

    DASH_ = '-'
    UNDERSCORE_ = '_'
  end
end
# #history: abstracted from a stub in tests

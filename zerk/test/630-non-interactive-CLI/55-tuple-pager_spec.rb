require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - tuple pager" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject
    end

    it "minimal representative" do

      _input_tuples do
        _header 'bingo', 'flingo', 'xyz abc', 'hi'
        _row 'Ingo', 'fuh lingo', 'hey', 'hello'

        _row 'x', 'x', 'XYZ ABC!', 'x'
      end

      _expect <<-HERE.unindent
        | bingo |    flingo | xyz abc |    hi |
        |  Ingo | fuh lingo |     hey | hello |
        |     x |         x | XYZ ABC! |     x |
      HERE
    end

    cache = {}  # has fragility - if ever this file is re-run or ..

    define_method :_input_tuples do |&p|
      @__const_cache = cache
      p[]
    end

    def _header *s_a
      sym_a = s_a.map( & :intern )
      cache = remove_instance_variable :@__const_cache
      @_struct_class = cache.fetch sym_a do
        _const = :"X_nicli_tpager_#{ cache.length }"
        cls = TS_.const_set _const, ::Struct.new( * sym_a )
        cache[ sym_a ] = cls
        cls
      end
      @_tuples = []
      NIL
    end

    def _row * s_a
      @_tuples.push @_struct_class.new( * s_a ) ; nil
    end

    def _expect big_str

      st = Home_::Stream_[ remove_instance_variable :@_tuples ]
      x = st.gets || TS_._SANITY
      @session ||= __common_beginning
      @session.first_tuple = x
      @session.tuple_stream = st

      _act_st = @session.execute

      _exp_st = Basic_[]::String::LineStream_via_String[ big_str ]

      TestSupport_::Want_Line::Streams_have_same_content[ _act_st, _exp_st, self ]
      NIL
    end

    subject = -> do
      Home_::NonInteractiveCLI::TuplePager
    end

    prototype = Home_::Lazy_.call do
      o = subject[].begin
      o.page_size = 2
      o.freeze
    end

    define_method :__common_beginning do
      prototype[].dup
    end

    define_method :_subject do
      subject[]
    end
  end
end

require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] models - deliterate (and ping)" do

    TS_[ self ]
    use :expect_event

    it "ping" do

      call_API :ping

      _em = expect_neutral_event :ping

      black_and_white( _em.cached_event_value ).should eql(
        "hello from beauty salon." )

      expect_no_more_events

      @result.should eql :hello_from_beauty_salon
    end

    it "bad range (first term)" do

      _from_to( -1, 2 )

      _em = expect_not_OK_event_ :number_too_small

      black_and_white( _em.cached_event_value ).should eql(
        "'from-line' must be greater than or equal to 1, had -1" )

      expect_failed
    end

    it "bad range (second term) - epic error message" do

      _from_to 1, -2

      _em = expect_not_OK_event_(
        :actual_property_is_outside_of_formal_property_set )

      black_and_white( _em.cached_event_value ).should eql(
        "'to-line' must be -1 or greater than or equal to 1. had -2" )

      expect_failed
    end

    it "bad range (relative)" do

      _from_to 3, 2

      _em = expect_not_OK_event :upside_down_range

      black_and_white( _em.cached_event_value ).should eql (
        "'to-line' (2) cannot be less than 'from-line' (3)" )

      expect_failed
    end

    def _from_to from_d, to_d

      call_API( * _subject_action,
        * _dummy_args,
        :from_line, from_d,
        :to_line, to_d,
      )
    end

    def _dummy_args

      [ :comment_line_downstream, :_x_,
        :code_line_downstream, :_xx_,
        :line_upstream, :_xxx_, ]
    end

    it "work" do

      cls = ::Class.new ::Array

      me = self
      cls.send :define_method, :<< do | s |

        if me.do_debug
          me.debug_IO.puts "#{ @__moniker }: #{ s }"
        end

        super( s )
      end

      cls.send :define_method, :initialize do | mnkr |
        @__moniker = mnkr
      end

      sout = cls.new :sout
      serr = cls.new :serr

      st = Home_.lib_.basic::String.line_stream <<-HERE.unindent
        howza
        wowza # commentie
        nowza
        gowza # fommentie
        lowza # zomentie
        bowza
      HERE

      call_API( * _subject_action,

        :comment_line_downstream, serr,
        :code_line_downstream, sout,
        :line_upstream, st,
        :from_line, 2,
        :to_line, 4,
      )

      sout.should eql [ "wowza\n", "nowza\n", "gowza\n"]
      serr.should eql [ "commentie", "fommentie" ]

      expect_succeeded
    end

    def _subject_action
      :deliterate
    end
  end
end

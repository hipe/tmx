require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Regret::API::Actions::DocTest::RS_

  ::Skylab::TestSupport::TestSupport::Regret::API::Actions::DocTest[ self, :expect ]

  describe "[ts] regret API actions doc-test recursive", wip: true do

    extend TS__

    it "the API loads" do
      _API
    end

    it "needs things" do
      invoke :recursive
      expect :err, %r(\Ainvalid mode value nil\. expecting #{
        }.*\bdo_list\b)
      # #expect_failed
    end

    it "(live test) some of ours, no hashtags" do  # :[#030]
      _path = TestSupport_::Regret::API::Actions::DocTest.dir_pathname.to_path
      invoke :recursive, path: _path, mode: :do_list
      expect :out, %r(/doc-test.rb\z)
      expect :out, %r(/doc-test/specer--.rb\z)
      expect_succeeded
    end

    it "(live test) \"special path\" (hashtags)" do  # :[#030]
      _path = TS_TS_::TestLib_::Face_module[].dir_pathname.to_path
      invoke :recursive, path: _path, mode: :do_list
      rx = /#[-a-z]+/ ; hashtag_count = 0
      while (( em = shift_emission ))
        :out == em.channel_i or fail "expected out"
        rx =~ em.payload_x and hashtag_count += 1
      end
      hashtag_count > 0 or fail "expected to find hashtags in the [fa] files"
      expect_succeeded
    end

    def invoke i, h={}
      h[ :out ] = initial_writable_out_spy
      h[ :err ] = initial_writable_err_spy
      @result = _API.invoke i, h
    end

    def initial_writable_out_spy
      @out = initial_writable_spy
    end

    def initial_writable_err_spy
      @err = initial_writable_spy
    end

    def initial_writable_spy
      TestSupport_::IO.spy.new(
        :do_debug_proc, -> { do_debug },
        :debug_IO, debug_IO )
    end

    def build_baked_em_a
      y = @err.string.split( LINE_SEPARATOR_ ).map do |s|
        Emission_.new :err, s
      end
      y.concat (( @out.string.split( LINE_SEPARATOR_ ).map do |s|
        Emission_.new :out, s
      end ))
      y
    end

    def expect * a  # i can't believe that whatever rspec does makes this necessary..
      ts_expect( * a )
    end

    def _API
      TestSupport_::Regret::API
    end

    class Emission_
      def initialize i, s
        @channel_i = i ; @payload_x = s
      end
      attr_reader :channel_i, :payload_x
    end

    LINE_SEPARATOR_ = "\n".freeze
  end
end

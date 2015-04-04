require_relative 'test-support'

module Skylab::TMX::TestSupport::CLI::L2P

  ::Skylab::TMX::TestSupport::CLI[ TS_ = self ]

  include Constants

  extend TestSupport::Quickie

  describe "[tmx] CLI level 2 pings" do

    extend TS_

    def self.client_class
      TMX::CLI
    end

    def self.with i
      define_singleton_method :with_value do i end
    end

    FLAG_ = '--ping'.freeze
    PING_ARG_ = 'ping'.freeze

    it "beauty salon" do
      go :beauty_salon
    end

    it "bnf2treetop" do
      go :bnf2treetop, FLAG_
    end

    it "breakup - capture3" do
      capture3 :breakup, FLAG_, 0
    end

    it "callback" do
      go :'callback'
    end

    it "citxt - capture3" do
      capture3 :citxt, FLAG_, 0
    end

    it "css-convert" do
      go :'css-convert', FLAG_
    end

    it "cull" do
      go :cull
    end

    it "file metrics" do
      go :file_metrics
    end

    it "flex2treetop" do
      go :flex2treetop
    end

    it "git" do
      go :git
    end

    it "permute" do
      go :permute
    end

    it "quickie" do
      go :'quickie', FLAG_
    end

    it "slicer" do
      go :slicer
    end

    it "snag" do
      go :snag
    end

    it "sub tree" do
      go :sub_tree
    end

    it "test support" do
      go :"test-support"
    end

    it "tan man" do
      go :tan_man
    end

    it "treemap" do
      go :treemap
    end

    it "uncommit - capture3" do
      capture3 :uncommit, FLAG_, 0
    end

    it "unsplit - capture3 - FROM BASH" do
      capture3 :unsplit, FLAG_, 0
    end

    it "xargs-ish-i" do
      capture3 :'xargs-ish-i', FLAG_, 0
    end

    it "yacc2treetop" do
      go :'yacc2treetop', FLAG_
    end

    def go sym, *a
      if a.length.zero?
        _hack_write sym
      end
      _go sym, *a
    end

    def _go sym, *a
      _x = _confirm_out_and_err_streams sym, *a
      _x.should eql :"hello_from_#{ sym }"
      nil
    end

    def capture3 i, ping_arg, exitstatus

      argv = [
        TMX.bin_pathname.join( TMX.supernode_binfile ).to_path,
        i.id2name, ping_arg ]

      o, e, st = TestSupport::Library_::Open3.capture3( * argv )
      o.should eql EMPTY_S_
      e.should eql "#{ hellomsg i }\n"

      st.exitstatus.should eql exitstatus
      nil
    end

    def _confirm_out_and_err_streams i, arg=PING_ARG_
      x = invoke "#{ i.to_s.gsub UNDERSCORE_, DASH_ }", arg
      iog = @__memoized.fetch :io_spy_triad  # dear future - i am sorry:
      # calling `lines` does hackery that won't work with our hackery, maybe.

      oa, ea = [ :outstream, :errstream ].map do |ii|
        io = iog[ ii ]
        str = io.string
        a = str.split NEWLINE_  # then:
        io.rewind
        io.truncate 0
        a
      end

      s = ea.fetch 0
      s.gsub! SIMPLER_STYLE_RX_, EMPTY_S_
      s.should eql hellomsg( i )

      ea.length.should eql( 1 )
      oa.length.should eql( 0 )
      x
    end

    def hellomsg i
      "hello from #{ i.to_s.gsub( UNDERSCORE_, SPACE_ ) }."
    end

    -> do  # hacklund..
      a = []
      define_method :_hack_write do |i|
        a << i
        nil
      end
      define_method :_hack_read do a end
    end.call

    # # THIS IS A BAD TEST. ok to erase or whatever if you don't like it.
    # the point is to shake the client up a bit with more than one request.

    it "ridiculous hack to test long-running capabilities" do
      a = _hack_read
      a.each do |i|
        2.times do |x_|
          _go i
        end
      end
    end
  end
end

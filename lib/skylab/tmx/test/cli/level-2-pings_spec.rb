require_relative 'test-support'

module Skylab::TMX::TestSupport::CLI::L2P

  ::Skylab::TMX::TestSupport::CLI[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ TMX }::CLI level 2 pings" do

    extend TS_

    def self.client_class
      TMX::CLI
    end

    def self.with i
      define_singleton_method :with_value do i end
    end

    it "beauty salon" do
      go :beauty_salon
    end

    it "cull" do
      go :cull
    end

    it "cov tree" do
      go :cov_tree
    end

    it "file metrics" do
      go :file_metrics
    end

    it "permute" do
      go :permute
    end

    it "regret" do
      go :regret
    end

    it "slicer" do
      go :slicer
    end

    it "snag" do
      go :snag
    end

    it "tan man" do
      go :tan_man
    end

    it "treemap" do
      go :treemap
    end

    def go i
      _hack_write i
      _go i
    end

    def _go i
      x = invoke "#{ i.to_s.gsub '_', '-' }", "ping"
      x.should eql( :"hello_from_#{ i }" )

      iog = @__memoized.fetch :io_spy_group  # dear future - i am sorry:
      # calling `lines` does hackery that won't work with our hackery, maybe.

      oa, ea = [ :outstream, :errstream ].map do |ii|
        io = iog[ ii ]
        str = io.string
        a = str.split "\n"  # then:
        io.rewind
        io.truncate 0
        a
      end

      ea.fetch( 0 ).should eql( "hello from #{ i.to_s.gsub( '_', ' ' ) }." )
      ea.length.should eql( 1 )
      oa.length.should eql( 0 )
    end

    -> do  # hacklund..
      a = [ ]
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

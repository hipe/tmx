require_relative 'test-support'

module Skylab::TestSupport::TestSupport::IO_Spy::Core

  ::Skylab::TestSupport::TestSupport::IO_Spy[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ts] IO spy" do

    it "loads" do
      Subject_[]
    end

    it "builds, spies on some writes" do
      io = Subject_[].new
      io.puts 'foo'
      io.write 'bar'
      io.puts ' baz'
      io.string.should eql "foo\nbar baz\n"
    end

    it "a bunch of debugging options" do

      string_IO = TestSupport_::Library_::StringIO.new
      d = -1
      io = Subject_[].new :do_debug_proc, -> { ( ( d += 1 ) % 2 ).zero? },
        :debug_IO, string_IO,
        :debug_prefix, '•',
        :puts_map_proc, -> s do
          "_#{ s }_"
        end

      io.puts "one"
      io.puts "two"
      io.puts "three"
      string_IO.string.should eql "•_one_\n•_three_\n"

    end

    Subject_ = -> { TestSupport_::IO.spy }

  end
end

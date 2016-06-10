require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] IO spy" do

    it "loads" do
      _subject_module
    end

    it "builds, spies on some writes" do
      io = _subject_module.new
      io.puts 'foo'
      io.write 'bar'
      io.puts ' baz'
      io.string.should eql "foo\nbar baz\n"
    end

    it "a bunch of debugging options" do

      string_IO = Home_::Library_::StringIO.new
      d = -1
      io = _subject_module.new :do_debug_proc, -> { ( ( d += 1 ) % 2 ).zero? },
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

    def _subject_module
      Home_::IO.spy
    end
  end
end

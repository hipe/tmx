require_relative '../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] CLI - synopsis lines" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module || fail
    end

    it "just a usage line - synopsis is as-is" do

      this_line = "usage: tmz test-support cover [ <white-path-fragment> #{
        }[ <white-path-fragment> [..] ] -- ] <a-ruby-file>"

      _lines = _by do |io|
        io.puts this_line
      end
      _lines == [ this_line ]
    end

    it "two sections, ideal section not found, uses 2 lines of 2nd section" do

      _lines = _by do |io|
        io.puts "usage: xx"
        io.puts  # #coverpoint-2-2 agent can puts nil for blank line
        io.puts "description: line 1"
        io.puts "line 2"
        io.puts "line 3"
      end

      _lines == [ "line 1", "line 2" ] || fail
    end

    it "works when the header is on its own line" do  # #coverpoint-2-1

      lines = _against 'test-support-quickie.output'
      1 == lines.length || fail
      lines.first =~ /\Aquickie \[-[a-z-]+\]/ || fail
    end

    it "works when color, when um nasty throw" do  # #coverpoint-2-3

      lines = _against 'git-citxt.output'
      1 == lines.length || fail
      lines.first.length.zero? && fail
    end

    it "the agent can put a newline in the string and it works as expected" do
      # #coverpoint-2-4

      _lines = _by do |io|
        io.puts "synopsis: syno line 1\n#{
          }          syno line 2\n\n"
        io.puts "never see: never see"
      end

      _lines == [ "syno line 1", "syno line 2" ] || fail
    end

    it "dangling indented lines (look like they aren't in a section)" do
      # #coverpoint-2-5

      lines = _against 'tan-man-stack.output'
      lines.length == 2 || fail
      # (make sure that no line looks indented)
      lines.grep( /\A[^[:blank:]]/ ).length == 2 || fail
    end

    it "section names (\"headers\") in their on line in all caps (manpage style)" do

      # #coverpoint-2-6 - be case insensitive to how we compare section names
      # against target section names (by coverting it to downcase for a key)

      lines = _against 'tmx-xargs-ish-i.output'
      1 == lines.length || fail
      lines.first[ 0, 8 ] == "tmz tmx " || fail  # #todo bug in (ancient) client
    end

    def _against entry

      _path = ::File.join _thing_directory, entry
      upstream = ::File.open _path, ::File::RDONLY
      x = _by do |downstream|
        while line=upstream.gets
          downstream.puts line
        end
      end
      upstream.close
      x
    end

    def _by & p

      if do_debug
        listener = -> * chan, & msg_p do
          io = debug_IO
          if :expression == chan[1]
            msg_p[ io ] ; io.puts
          else
            io.puts "(dbg: #{ chan.inspect })"
          end
          NIL
        end
      end

      _subject_module.define do |o|
        o.number_of_synopsis_lines = 2
        o.listener = listener
      end.synopsis_lines_by( & p )
    end

    memoize :_thing_directory do
      ::File.join TS_.dir_path, 'fixture-directories', 'dir-03-one-off-help-screen-dumps', 'generated'
    end

    def _subject_module
      Home_::CLI::Magnetics_::SynopsisLines_via_HelpScreen
    end
  end
end

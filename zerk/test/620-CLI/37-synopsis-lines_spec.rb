require_relative '../test-support'

module Skylab::Zerk::TestSupport

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
        io.puts  # #coverpoint2.2 agent can puts nil for blank line
        io.puts "description: line 1"
        io.puts "line 2"
        io.puts "line 3"
      end

      _lines == [ "line 1", "line 2" ] || fail
    end

    it "works when the header is on its own line" do  # #coverpoint2.1

      lines = _against 'test-support-quickie.output'
      1 == lines.length || fail
      lines.first =~ /\Aquickie \[-[a-z-]+\]/ || fail
    end

    it "works when color, when um nasty throw" do  # #coverpoint2.3

      lines = _against 'git-citxt.output'
      1 == lines.length || fail
      lines.first.length.zero? && fail
    end

    it "the agent can put a newline in the string and it works as expected" do
      # #coverpoint2.4

      _lines = _by do |io|
        io.puts "synopsis: syno line 1\n#{
          }          syno line 2\n\n"
        io.puts "never see: never see"
      end

      _lines == [ "syno line 1", "syno line 2" ] || fail
    end

    it "dangling indented lines (look like they aren't in a section)" do
      # #coverpoint2.5

      lines = _against 'tan-man-stack.output'
      lines.length == 2 || fail
      # (make sure that no line looks indented)
      lines.grep( /\A[^[:blank:]]/ ).length == 2 || fail
    end

    it "section names (\"headers\") in their on line in all caps (manpage style)" do

      # #coverpoint2.6 - be case insensitive to how we compare section names
      # against target section names (by coverting it to downcase for a key)

      lines = _against 'tmx-xargs-ish-i.output'
      1 == lines.length || fail
      lines.first[ 0, 8 ] == "tmz tmx " || fail  # #todo bug in (ancient) client
    end

    it "(edge case coverage: one line)" do
      # #coverpoint2.7

      _invo = _build_invocation_by do |o|
        o.number_of_synopsis_lines = 1
      end

      lines = _lines_via_invocation_against_file _invo, 'git-breakout.output'

      lines.length == 1 || fail
      lines.first.include? 'break up one large commit' or fail
    end

    def _against entry

      _invo = _build_common_invocation
      _lines_via_invocation_against_file _invo, entry
    end

    def _lines_via_invocation_against_file invo, entry

      _path = ::File.join _thing_directory, entry
      upstream = ::File.open _path, ::File::RDONLY
      x = invo.synopsis_lines_by do |downstream|
        while line=upstream.gets
          downstream.puts line
        end
      end
      upstream.close
      x
    end

    def _by & p
      _build_common_invocation.synopsis_lines_by( & p )
    end

    def _build_common_invocation
      _build_invocation_by do |o|
        o.number_of_synopsis_lines = 2
      end
    end

    def _build_invocation_by
      _subject_module.define do |o|
        yield o
        o.listener = _listener
      end
    end

    def _listener
      if do_debug
        -> * chan, & msg_p do
          io = debug_IO
          if :expression == chan[1]
            msg_p[ io ] ; io.puts
          else
            io.puts "(dbg: #{ chan.inspect })"
          end
          NIL
        end
      end
    end

    memoize :_thing_directory do
      ::File.join TS_.dir_path, 'fixture-directories', 'dir-01-one-off-help-screen-dumps', 'generated'
    end

    def _subject_module
      Home_::CLI::SynopsisLines_via_HelpScreen
    end
  end
end

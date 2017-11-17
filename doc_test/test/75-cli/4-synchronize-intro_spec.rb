require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] CLI - synchronize intro" do

    TS_[ self ]
    use :memoizer_methods
    use :fixture_files
    use :my_non_interactive_CLI

    _OP = 'synchronize'

    context "1.4) help screen" do

      given do
        argv _OP, '-h'
      end

      it "usage" do
        section( :usage ).first_line.unstyled_styled ==
          "usage: xyzi synchronize [-o X] [-r] <asset-path>\n" || fail
      end

      it "help option" do
        _op = _option '-h'
        _op.long == '--help[=named-argument]' || fail
      end

      it "original test path option" do
        op = _option '-o'
        op.long == '--original-test-path X' || fail
        op.desc.include?( 'use the bytes in this file' ) || fail
        op.additional_lines || fail
      end

      it "recursive option" do
        _op = _option '-r'
        _op.desc.include?( 'coming soon' ) || fail
      end

      it "lone argument - asset-path" do
        _sect = section :argument
        _string = _sect.items.first.head_line.string
        _string =~ /\A[ ]{2,}asset-path[ ]{2,}[^[:space:]]/ or fail
      end

      it "succeeded" do
        exitstatus.zero? || fail
      end

      def _option switch
        ___option_index_hash.fetch switch
      end

      dangerous_memoize :___option_index_hash do
        section( :options ).to_option_index.h_
      end

      def section sym
        niCLI_help_screen.section sym
      end

      dangerous_memoize :niCLI_help_screen do
        _lines = niCLI_state.lines
        Home_::Zerk_::TestSupport::CLI::Want_Section_Coarse_Parse.new _lines
      end
    end

    # context "0.0) no args"

    context "1.2) strange opt" do

      given do
        argv _OP, '-x'
      end

      it "whine" do
        first_line_string == "invalid option: -x\n" || fail
      end

      it "invite" do
        _be_this = be_line :styled, :e,
          %r(\Asee 'xyzi synchronize -h' for more about options\b)
        last_line.should _be_this
      end

      it "failed" do
        exitstatus.nonzero? || fail
      end
    end

    context "1.1) no ent (obliquely cover [hu] c15n)" do

      given do
        _noent = TestSupport_::Fixtures.file :not_here
        argv _OP, _noent
      end

      it "says no ent" do
        _md || fail
      end

      it "path looks OK" do
        path = _md[ :path ]
        ::File.basename( path ) == 'not-here.file' || fail
        ::File::SEPARATOR == path[ 0 ] || fail
      end

      it "head contextualization is right" do
        _md[ :head ] == "failed to synchronize because " || fail
      end

      it "no invite! (for now)" do
        1 == number_of_lines || fail
      end

      dangerous_memoize :_md do
        /\A(?<head>.*)no such file or directory @ rb_sysopen - (?<path>.+)$/.match first_line.string
      end

      alias_method :this_filesystem_, :the_real_filesystem_
    end

    _END_LINE = "end\n"

    context "output the lines from just an asset file" do

      given do
        argv _OP, _same_file
      end

      it "around 23 lines" do
        ( 20 .. 25 ).include? _lines.length or fail
      end

      it "probably all on stdout" do
        a = _lines
        a.first.stream_symbol == :o || fail
        a.last.stream_symbol == :o || fail
      end

      it "content is probably OK" do
        a = _lines
        a.first.string.include?( 'require' ) || fail
        a.last.string == _END_LINE || fail
      end

      dangerous_memoize :_lines do
        niCLI_state.lines
      end

      alias_method :this_filesystem_, :the_real_filesystem_
    end

    context "output the lines from an asset file and an original test file" do

      # (we tested & confirmed visually noent test path :P)

      given do
        argv _OP, _same_file, '--original-test-pa', __original_test_file
      end

      _TEN = %r(^[ ]{10})

      it "ending is same" do

        _exp = <<-HERE.gsub! _TEN, EMPTY_S_

              it "jambalaya" do
                1 == 1 or fail
              end

              def __mister_fixit
                hi
              end
            end
          end
        HERE
        _act = _string_at_lines( -10..-1 )
        _act == _exp || fail
      end

      it "beginning is same" do

        _exp = <<-HERE.gsub! _TEN, EMPTY_S_
          reqoore 'something-crazy.ziz'

          module Floorlab::Donglewhooter

            describe "anigo montoya" do

        HERE
        _act = _string_at_lines 0..5
        _act == _exp || fail
      end

      it "description of first test is good" do

        _exp = "    it \"here is the minimal interesting example for calling the API\" do\n"
        _act = _lines[6].string
        _act == _exp || fail
      end

      def _string_at_lines r

        _lines[ r ].reduce "" do |m, o|
          m << o.string
        end
      end

      def _lines
        niCLI_state.lines
      end

      alias_method :this_filesystem_, :the_real_filesystem_
    end

    def __original_test_file
      fixture_file_  '51-some_speg.rb'
    end

    def _same_file
      home_asset_file_path_
    end
  end
end
# #tombstone: rewrite from pre-zerk to post-zerk

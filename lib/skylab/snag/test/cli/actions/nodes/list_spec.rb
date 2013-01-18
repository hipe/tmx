require_relative 'test-support'


module Skylab::Snag::TestSupport::CLI::Actions

  # has Quickie - try running this with just `ruby -w foo_spec.rb`

  describe "#{ Snag::CLI } Actions - Show" do

    extend Actions_TestSupport

    shared_setup = -> ctx do
      ctx.tmpdir_clear.patch <<-O.unindent
        diff --git a/doc/issues.md b/doc/issues.md
        --- /dev/null
        +++ b/doc/issues.md
        @@ -0,0 +1,4 @@
        +[#003] #open feep my deep
        +[#002]       #done wizzle bizzle 2013-11-11
        +               one more line
        +[#001]       #done
      O
      shared_setup = -> _ { }
    end

    it "with `list -n 1` - shows only the first one it finds" do
      shared_setup[ self ]
      invoke_from_tmpdir 'list', '-n', '1'

      infos = []
      pays = []
      output.lines.each do |line|
        case line.name
        when :info ; infos.push line.string
        when :pay  ; pays.push line.string.chomp
        else       ; fail "wat? - #{ line.name }"
        end
      end
      infos.length.should eql(1)
      infos.first.should match( %r{ \./doc/issues\.md }x ) # has this in it
      pays.length.should eql(3)
      o = -> { pays.shift }
      o[].should eql('---')
      o[].should match( /\Aidentifier_body +: +003\z/ )
      o[].should match( /\Afirst_line_body +: #open feep my deep\z/ )
      o[].should eql(nil)
    end

    context "if you ask to see a particular one" do
      it "with `show 002 --no-verbose` - it shows it tersely" do
        shared_setup[ self ]
        invoke_from_tmpdir 'show', '002', '--no-verbose'
        names, strings = output.unzip
        names.count{ |x| x == :pay }.should eql( 2 ) # i don't care about info
        act = output.lines.select{ |x| :pay == x.name }.map(&:string).join ''
        exp = <<-O.unindent
          [#002]       #done wizzle bizzle 2013-11-11
                         one more line
        O
        act.should eql( exp )
      end
    end
  end
end

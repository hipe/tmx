require_relative 'test-support'


module Skylab::Issue::TestSupport::CLI::Actions

  # has Quickie - try running this with just `ruby -w foo_spec.rb`

  describe "#{ Issue::CLI } Actions - Show" do

    extend Actions_TestSupport

    it "if you ask to see only the first one, it shows that" do

      tmpdir_clear.patch <<-HERE.unindent
        diff --git a/doc/issues.md b/doc/issues.md
        --- /dev/null
        +++ b/doc/issues.md
        @@ -0,0 +1,4 @@
        +[#003] #open feep my deep
        +[#002]       #done wizzle bizzle 2013-11-11
        +               one more line
        +[#001]       #done
      HERE

      from_tmpdir do
        client_invoke 'list', '-l1'
      end

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
      pays.length.should eql(4)
      o = -> { pays.shift }
      o[].should eql('---')
      o[].should match( %r{\Aidentifier +: +003\z} )
      o[].should match( %r{\Adate +: +#open feep\z} ) # !
      o[].should match( %r{\Amessage +: +my deep\z} )
      o[].should eql(nil)
    end
  end
end

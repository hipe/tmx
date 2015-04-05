require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node-collection - actions - to-node-stream", wip: true do

    extend TS_

    with_invocation 'nodes', 'list'

    with_tmpdir_patch do

      <<-O.unindent
        diff --git a/#{ manifest_file } b/#{ manifest_file }
        --- /dev/null
        +++ b/#{ manifest_file }
        @@ -0,0 +1,4 @@
        +[#003] #open feep my deep
        +[#002]       #done wizzle bizzle 2013-11-11
        +               one more line
        +[#001]       #done
      O
    end

    it "with `list -n 1` - shows only the first one it finds" do
      setup_tmpdir_read_only
      invoke '-n', '1'

      infos = []
      pays = []
      output.lines.each do |line|
        case line.stream_symbol
        when :info ; infos.push line.string
        when :pay  ; pays.push line.string.chomp
        else       ; fail "wat? - #{ line.stream_symbol }"
        end
      end
      infos.length.should eql 2
      infos.first.should match( %r{ doc/issues\.md }x ) # has this in it
      pays.length.should eql(3)
      o = -> { pays.shift }
      o[].should eql('---')
      o[].should match( /\Aidentifier_body +: +003\z/ )
      o[].should match( /\Afirst_line_body +: #open feep my deep\z/ )
      o[].should eql(nil)
    end

    it "with `list -2` - also works (-<n> option yay)" do
      setup_tmpdir_read_only
      invoke '-2'
      output.lines.last.string.should match( /found 2 nodes with validity/ )
    end

    context "if you ask to see a particular one" do

      it "with `show 002 --no-verbose` - it shows it tersely" do
        setup_tmpdir_read_only
        invoke '002', '--no-verbose'
        names, = output.unzip
        names.count{ |x| x == :pay }.should eql( 2 ) # i don't care about info
        act = output.lines.select{ |x| :pay == x.stream_symbol }.map(&:string).join ''
        exp = <<-O.unindent
          [#002]       #done wizzle bizzle 2013-11-11
                         one more line
        O
        act.should eql( exp )
      end
    end
  end
end

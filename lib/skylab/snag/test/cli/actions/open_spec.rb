require_relative 'test-support'


module Skylab::Snag::TestSupport::CLI::Actions

  # Quickie compatible - just load this file with `ruby -w`

  describe "[sg] CLI Actions - Open" do

    extend Actions_TestSupport

    shared_setup = -> ctx do      # differently just for fun
                                  # (one time we memoized it but oh lawd)

      ctx.tmpdir_clear.write manifest_path, <<-O.unindent
        [#004.2] #open this is #feature-creep but meh
        [#004] #open here's an open guy
                        with two lines
        [#003]        not open because no such tag
        [#002]       look for job #openings somewhere else
        [#leg-001]   this is an old ticket that is still #open
                       it has a prefix which will hopefully be ignored
      O
      nil                         # (hopefully you don't need the pn from above)
    end

    context "with no arguments show a report of open tickets!" do

      it "`open` (with no options) - shows a subset of lines from the file" do

        shared_setup[ self ]
        invoke_from_tmpdir 'o'
        a = output.lines
        :info == a.first.stream_name and a.shift
        a.map(& :stream_name).should eql(
          [:pay, :pay, :pay, :pay, :pay, :info] )
        exp = <<-O.unindent
          [#004.2] #open this is #feature-creep but meh
          [#004] #open here's an open guy
                          with two lines
          [#leg-001]   this is an old ticket that is still #open
                         it has a prefix which will hopefully be ignored
        O
        act = a[0..-2].map(&:string).join
        act.should eql( exp )
      end

      it "`open -v` - show it verbosely (the yaml report)" do
        shared_setup[ self ]
        invoke_from_tmpdir 'open', '-v'
        act = output.lines.reduce( [] ) do |m, (x, _)|
          if :pay == x.stream_name
            m.push x.string
            if 4 == m.length
              break( m )
            end
          end
          m
        end.join
        exp = <<-O.unindent
          ---
          identifier_body   : 004.2
          first_line_body   : #open this is #feature-creep but meh
          ---
        O
        exp.should eql( act )
      end
    end

    context "with one argument" do

      it "`open foo` opens a ticket" do
        shared_setup[ self ]
        invoke_from_tmpdir 'open', 'foo'
        output.lines.first.string.should match(
          /new line: \[#005\] #open foo/ )
        output.lines.clear
        invoke_from_tmpdir 'open', # eighty characters:
<<-O.chop
1234 6789 2234 6789 3234 6789 4234 6789 5234 6789 6234 6789 7234 6789 8234 6789
O

        next_raw_line = -> do  # not exatcly raw.. we chop exactly one char
          line = output.lines.shift.string
          line.chop!
          line
        end

        cutlen = 'while adding node, '.length

        cut = -> str { str[ cutlen .. -1 ] }

        next_cut_line = -> do
          cut[ next_raw_line[] ]
        end

        next_cut_line[].should eql( 'new lines:' )

        next_raw_line[].should eql(
 "[#006] #open 1234 6789 2234 6789 3234 6789 4234 6789 5234 6789 6234 6789 7234"
        ) # 78 chars wide yay
        next_raw_line[].should eql( "             6789 8234 6789" )  # DAMN STRA
        next_cut_line[].should eql( 'done.' )
        output.lines.length.should eql( 0 )
      end
    end
  end
end

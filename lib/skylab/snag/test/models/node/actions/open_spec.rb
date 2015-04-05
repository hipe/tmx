require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node - actions - open", wip: true do

    extend TS_

    with_tmpdir do |o|
      o.clear.write manifest_file, <<-O.unindent
        [#004.2] #open this is #feature-creep but meh
        [#004] #open here's an open guy
                        with two lines
        [#003]        not open because no such tag
        [#002]       look for job #openings somewhere else
        [#leg-001]   this is an old ticket that is still #open
                       it has a prefix which will hopefully be ignored
      O
      nil
    end

    context "with options that don't make sense for that form" do
      it '"foo is for X not Y"' do
        do_not_setup_tmpdir
        invoke 'open', '--dry-run'
        expect %r(\Asorry - --dry-run is used for opening issues, not #{
          }listing open issues\z)i
        expect %r(\Asn0g open -h might have more information\z)i
      end
    end

    context "with no arguments show a report of open tickets!" do

      it "`open` (with no options) - shows a subset of lines from the file" do
        setup_tmpdir_read_only
        invoke 'o'
        a = output.lines
        :info == a.first.stream_symbol and a.shift
        a.map(& :stream_symbol ).should eql(
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
        setup_tmpdir_read_only
        invoke 'open', '-v'
        act = output.lines.reduce( [] ) do |m, (x, _)|
          if :pay == x.stream_symbol
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
        invoke 'open', 'foo'
        output.lines.first.string.should match(
          /new line: \[#005\] #open foo/ )
        output.lines.clear
        do_not_setup_tmpdir
        invoke 'open', # eighty characters:
<<-O.chop
1234 6789 2234 6789 3234 6789 4234 6789 5234 6789 6234 6789 7234 6789 8234 6789
O
        set_cut_width 'while opening, '.length

        next_cut_line.should eql 'added new lines:'

        next_chopped_line.should eql(
 "[#006] #open 1234 6789 2234 6789 3234 6789 4234 6789 5234 6789 6234 6789 7234"
        ) # 78 chars wide yay
        next_chopped_line.should eql "             6789 8234 6789"  # DAMN STRA

        next_chopped_line.should eql 'done opening.'
        output.lines.length.should be_zero
      end

      def set_cut_width d
        @cut = -> str do
          str[ d .. -1 ]
        end ; nil
      end

      def next_cut_line
        s = next_chopped_line
        s and @cut[ s ]
      end

      def next_chopped_line
        s = output.lines.shift.string
        s.chop!
        s
      end
    end
  end
end

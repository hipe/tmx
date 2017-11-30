require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI - want section magnetics (might be #feature-island)" do

    # #legacy-coverpoint-1

    it "no lines" do
      _parse <<-O
      O
      expect( @sections.length ).to be_zero
    end

    it "one normal line" do
      _parse <<-O  # note we leave the indent just for giggles
        one line to rule them all
      O
      expect( @sections.length ).to eql( 1 )
      sect = @sections[0]
      expect( sect.header ).to eql( nil )
      expect( sect.lines.length ).to eql( 1 )
      expect( sect.lines[0][1] ).to eql "        one line to rule them all"
    end

    it "two normal lines" do
      _parse <<-O.unindent
        one  two
         three  four  five
      O
      expect( @sections.length ).to eql( 1 )
      sect = @sections[0]
      expect( sect.lines.length ).to eql( 2 )
      expect( sect.lines.first[1] ).to eql( 'one  two' )
      expect( sect.lines.last[1] ).to eql( ' three  four  five' )
    end

    it "normal / sect" do
      _parse <<-O.unindent
        beefus boqueefus
        nothing:
      O
      expect( @sections.length ).to eql( 2 )
      s1 = @sections[0]
      expect( s1.header ).to eql( nil )
      expect( s1.lines.length ).to eql( 1 )
      expect( s1.lines[0][1] ).to eql( 'beefus boqueefus' )
      s2 = @sections[1]
      expect( s2.header ).to eql( 'nothing:' )
      expect( s2.lines.length ).to eql( 0 )
    end

    it "sect / normal" do
      _parse <<-O.unindent
        some thing:
        bojangles in shangles
      O
      expect( @sections.length ).to eql( 1 )
      sect = @sections[0]
      expect( sect.header ).to eql( 'some thing:' )
      expect( sect.lines.length ).to eql( 1 )
      expect( sect.lines[0][1] ).to eql( 'bojangles in shangles' )
    end

    it "sect / normal / normal / sect" do
      _parse <<-O.unindent
        s1:
        one
        two
        s2:
        three
      O
      str = @sections.map { |s| "[<#{ s.header }>(#{
        }#{ s.lines.map(&:last).join ',' })]" }.join
      expect( str ).to eql( '[<s1:>(one,two)][<s2:>(three)]' )
    end

    context "items" do
      it "sect / item" do
        _parse <<-O.unindent
          bliple:
           meep  beep
        O
        expect( @sections.length ).to eql( 1 )
        sect = @sections[0]
        expect( sect.lines.length ).to eql( 1 )
        expect( sect.lines.first ).to eql( [ :item, 'meep', 'beep' ] )
      end
    end

    context "subitems" do
      it "sect / item / subitem / subitem / item / normal / sect" do
        _parse <<-O.unindent
          blearg:
           nargle
             mingus
               miniscous
           nagle
          nimble
          bloofis:
        O
        fmt = "%8s | %8s |%10s"
        act = @sections[0].lines.map do |l|
          ( fmt % (3.times.map { |x| l[x] }) ).strip
        end.join "\n"
        exp = <<-O.unindent.chop
          item |   nargle |
          item |          |    mingus
          item |          | miniscous
          item |    nagle |
          line |   nimble |
        O
        expect( act ).to eql( exp )
      end
    end

    def _parse s

      _scn = Basic_[]::String::LineStream_via_String[ s ]

      @sections =
        TS_::CLI::Want_Section_Magnetics::SectionsOldSchool_via_LineStream.call(
        _scn )

      NIL
    end
  end
end

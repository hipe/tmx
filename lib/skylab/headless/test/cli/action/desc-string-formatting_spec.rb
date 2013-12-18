require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Desc__

  ::Skylab::Headless::TestSupport::CLI::Action[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[hl] CLI help sections" do

    it "no lines" do
      parse <<-O
      O
      @sections.length.should be_zero
    end

    def parse s
      _scn = Headless::Services::String::Lines::Producer.factory s
      Headless::CLI::Action::Desc::Parse_sections[ @sections=[], _scn ] ; nil
    end

    it "one normal line" do
      parse <<-O  # note we leave the indent just for giggles
        one line to rule them all
      O
      @sections.length.should eql( 1 )
      sect = @sections[0]
      sect.header.should eql( nil )
      sect.lines.length.should eql( 1 )
      sect.lines[0][1].should eql( '        one line to rule them all' )
    end

    it "two normal lines" do
      parse <<-O.unindent
        one  two
         three  four  five
      O
      @sections.length.should eql( 1 )
      sect = @sections[0]
      sect.lines.length.should eql( 2 )
      sect.lines.first[1].should eql( 'one  two' )
      sect.lines.last[1].should eql( ' three  four  five' )
    end

    it "normal / sect" do
      parse <<-O.unindent
        beefus boqueefus
        nothing:
      O
      @sections.length.should eql( 2 )
      s1 = @sections[0]
      s1.header.should eql( nil )
      s1.lines.length.should eql( 1 )
      s1.lines[0][1].should eql( 'beefus boqueefus' )
      s2 = @sections[1]
      s2.header.should eql( 'nothing:' )
      s2.lines.length.should eql( 0 )
    end

    it "sect / normal" do
      parse <<-O.unindent
        some thing:
        bojangles in shangles
      O
      @sections.length.should eql( 1 )
      sect = @sections[0]
      sect.header.should eql( 'some thing:' )
      sect.lines.length.should eql( 1 )
      sect.lines[0][1].should eql( 'bojangles in shangles' )
    end

    it "sect / normal / normal / sect" do
      parse <<-O.unindent
        s1:
        one
        two
        s2:
        three
      O
      str = @sections.map { |s| "[<#{ s.header }>(#{
        }#{ s.lines.map(&:last).join ',' })]" }.join
      str.should eql( '[<s1:>(one,two)][<s2:>(three)]' )
    end

    context "items" do
      it "sect / item" do
        parse <<-O.unindent
          bliple:
           meep  beep
        O
        @sections.length.should eql( 1 )
        sect = @sections[0]
        sect.lines.length.should eql( 1 )
        sect.lines.first.should eql( [ :item, 'meep', 'beep' ] )
      end
    end

    context "subitems" do
      it "sect / item / subitem / subitem / item / normal / sect" do
        parse <<-O.unindent
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
        act.should eql( exp )
      end
    end
  end
end

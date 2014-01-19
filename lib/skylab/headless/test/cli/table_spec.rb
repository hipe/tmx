require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Table

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

  Headless = Headless ; Table = Headless::CLI::Table

  extend TestSupport::Quickie

  describe "[hl] CLI table" do

    def outstream
      @outstream ||= Headless::Library_::StringIO.new
    end

    def outstr
      @outstream.rewind
      @outstream.read
    end

    def render_table *a, &b  # we seem to like to change the interface a lot
      Table.render( *a, &b )
    end

    # --*--

    it "render_table( [] ){ .. } - renders the empty table" do
      a = [ ]
      res = render_table [ ] do |o|
        o.on_text do |txt|
          a << txt
        end
      end
      a.join.should eql( "(empty)" )
      res.should eql( nil )
    end

    it "without the block - string result" do
      render_table( [] ).should eql( "(empty)\n" )
    end

    it "2 x 2 table - align left (trailing blanks in cels!)" do
      data = [ %w(derp mcderperson),
               %w(herper mcderpertino) ]
      render_table( data ).should eql( <<-O.unindent )
        derp   mcderperson 
        herper mcderpertino
      O
    end

    it "options as param_h - works" do
      s = render_table [['a','b'], ['c','dd']],
        head: '<<', tail: '>>', separator: ' | '

      s.should eql( <<-O.unindent )
        <<a | b >>
        <<c | dd>>
      O
    end

    it "options via the proxy knob thing - works" do
      render_table [['a','b'], ['c','dd']] do |o|
        o.head = '<<' ; o.tail = '>>' ; o.separator = ' | '
        o.on_text do |txt|
          outstream.puts txt
        end
      end

      outstr.should eql( <<-O.unindent )
        <<a | b >>
        <<c | dd>>
      O
    end

    context 'infers types of columns and renders accordingly' do

      it "with everyday ordinary strings - aligns left" do
        row_enum =
         [['meep', 'mop'],
          ['pee',  'poo']]

        render_table( row_enum ).should eql( <<-O.unindent )
          meep mop
          pee  poo
        O
      end

      it "if column's *every value* is an integer-like string - align right" do

        row_enum =
         [['123', '4567'],
          ['6789', '-0']]

        render_table( row_enum ).should eql( <<-O.gsub( /^[ ]{10}/, '' ) )
           123 4567
          6789   -0
        O
      end

      it "when you have floating-point like doo-hahs - #{
          }something magical happens" do

        row_enum =
         [['-1.1122', 'blah'],
          ['1', '2'],
          ['34.5','56'],
          ['1.348', '-3.14'],
          ['1234.567891', '0']]

        render_table( row_enum ).should eql( <<-O.gsub( /^[ ]{10}/, '' ) )
            -1.1122    blah
             1            2
            34.5         56
             1.348    -3.14
          1234.567891     0
        O
      end

      it "when you have a mixed \"type\" column - IT USES THE MODE" do

        row_enum =
         [['0123',  '0123',    '01233', '3.1415'],
          ['',      'meeper',  'eff',   '3.14'],
          ['012',   '01.2',    'ef',    '23.1415'],
          ['01',    '01',      'e',     '0']]

        render_table( row_enum ).should eql( <<-O.unindent )
          0123   0123 01233  3.1415
               meeper eff    3.14  
           012   01.2 ef    23.1415
            01     01 e      0     
        O
      end
    end

    it "optionally format input dynamically with e.g. ascii escape sequences" do

      row_enum = [
        [[:header, 'name'], 'hipe'],
        [[:header, 'favorite fruits'], 'banana'],
        [nil, 'pear']
      ]

      a = []
      render_table row_enum, separator: "\t" do |o|
        o.field!( :header ).style = Headless::CLI::Pen::MINIMAL.method(:hdr)
        o.on_row do |txt|
          a << Headless::CLI::Pen::FUN.unstyle[ txt ]
        end
      end
      lengths = a.map { |s| s.match(/^[^\t]*/)[0].length }
      lengths.uniq.size.should eql(1)
    end
  end
end

require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - table - inferrential" do

    it "_when_rendering( [] ){ .. } - renders the empty table" do

      y = []
      x = _when_rendering [] do | o |
        o.on_text do | s |
          y.push s
        end
      end

      y.join.should eql "(empty)"
      x.should be_nil
    end

    it "without the block - string result" do

      _when_rendering( [] ).should eql "(empty)\n"
    end

    it "2 x 2 table - align left (trailing blanks in cels!)" do

      data = [ %w(derp mcderperson),
               %w(herper mcderpertino) ]

      _when_rendering( data ).should eql( <<-O.unindent )
        derp   mcderperson 
        herper mcderpertino
      O
    end

    it "options as param_h - works" do

      s = _when_rendering [['a','b'], ['c','dd']],
        head: '<<', tail: '>>', separator: ' | '

      s.should eql( <<-O.unindent )
        <<a | b >>
        <<c | dd>>
      O
    end

    it "options via the proxy knob thing - works" do

      y = []
      _when_rendering [['a','b'], ['c','dd']] do |o|

        o.head = '<<'
        o.separator = ' | '
        o.tail = '>>'

        o.on_text do | s |
          y.push "#{ s }#{ Home_::NEWLINE_ }"
        end
      end

      y.join.should eql <<-O.unindent
        <<a | b >>
        <<c | dd>>
      O
    end

    context 'infers types of columns and renders accordingly' do

      it "with everyday ordinary strings - aligns left" do
        row_enum =
         [['meep', 'mop'],
          ['pee',  'poo']]

        _when_rendering( row_enum ).should eql( <<-O.unindent )
          meep mop
          pee  poo
        O
      end

      it "if column's *every value* is an integer-like string - align right" do

        row_enum =
         [['123', '4567'],
          ['6789', '-0']]

        _when_rendering( row_enum ).should eql( <<-O.gsub( /^[ ]{10}/, '' ) )
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

        _when_rendering( row_enum ).should eql( <<-O.gsub( /^[ ]{10}/, '' ) )
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

        _when_rendering( row_enum ).should eql( <<-O.unindent )
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

      _when_rendering row_enum, separator: "\t" do |o|

        o.field!( :header ).style =
          Home_::CLI.expression_agent_instance.method( :hdr )

        o.on_row do |txt|
          a.push Home_::CLI_Support::Styling.unstyle txt
        end
      end

      rx = /^[^\t]*/
      _lengths = a.map { |s| rx.match( s )[0].length }

      _lengths.uniq.length.should eql 1
    end

    def _when_rendering * ea_and_h, & edit_p

      Home_::CLI_Support::Table::Inferential.
        render( * ea_and_h, & edit_p )
    end
  end
end

require_relative 'core-help/test-support'

module Skylab::Headless::TestSupport::CLI::Action::Dsc_Intgrtd__

  ::Skylab::Headless::TestSupport::CLI::Action[ TS__ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe "[hl] CLI action desc integration" do

    extend TS__

    context "a description if desired may be as simple as" do

      action_class_with_DSL :Desc_One_String do

        desc "i am one string"

        def default_action_i ; :run_land end
        def run_land
          enqueue :help ; true
        end
      end

      it "..one string" do
        invoke
        expect_the_lines_before_the_description
        _x = crunchify
        _x.should eql [[:strong_green, 'description:'], ' i am one string']
        expect_succeeded
      end
    end

    def expect_the_lines_before_the_description
      x = crunchify
      x.shift.should eql [ :strong_green, 'usage:' ]
      x.shift.should match %r(\A yerp [-a-z]+\z)
      x.length.zero? or fail "expected no more: #{ x.first.inspect }"
      expect_blank
    end


    context "an arbitrary number of description lines may be defined in .." do

      action_class_with_DSL :Zweibert do

        desc do |y|
          y << "it's like #{ say { em 'that' } } y'all"
          y << "it's like that." ; nil
        end

        option_parser do |op|
          op.on '-g',  '--gelp' do
            enqueue :help
          end
        end

        def default_action_i ; :zwiggy end
        def zwiggy flim, flam=nil
          self._wat_
          :_ok_
        end
      end

      it ".. a yielder block executed in the context of the view controller" do
        invoke '-g'
        expect :styled, 'usage: yerp zweibert [-g] <flim> [<flam>]'
        expect_blank
        expect_header :description
        expect :styled, /\A {2,}it's like that y'all\z/
        expect %r(\A {2,}it's like that\.\z)
        expect_blank
        expect_header :options
        expect %r(\A {2,}-g, --gelp\z)
        expect_succeeded
      end
    end

    context "multiple description blocks are the same as one and.." do

      action_class_with_DSL :Cryburger do

        desc do |y|
          y << 'normal line single'
          y << "additionally this:"
          y << "  this is  interesting"
        end

        desc do |y|
          y << "  why  hello there"
          y << "    i don't even"
        end

        def default_action_i ; :funki end
        def funki
          enqueue :help
          true
        end
      end

      it "..an an INSANE 'markdown'-like list formatting is supported" do
        invoke
        expect :styled, / yerp cryburger\z/
        expect_blank
        expect :styled, 'description: normal line single'
        expect_blank
        expect_header 'additionally this'
        _x = crunchify
        _x.should eql [ '  ', [ :green, 'this is'], 'interesting' ]
        _x = crunchify
        _x.should eql [ '  ', [ :green, 'why '], 'hello there' ]
        expect %r( {2,}i don't even\z)
        expect_succeeded
      end
    end
  end
end

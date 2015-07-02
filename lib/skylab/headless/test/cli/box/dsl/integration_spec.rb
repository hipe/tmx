require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  describe "[hl] CLI box DSL integration" do

    extend TS__

    context "override the default o.p that is built with your own `bop`" do

      box_DSL_class :Tricknata_INTGR do

        build_option_parser do
          o = Home_::Library_::OptionParser.new
          o.on '-x', '--xylophone <foo>' do |x|
            @xylo = x
          end
          o
        end
        with_DSL_off do
          attr_reader :xylo
        end
        def palooza
        end
      end

      it "your custom op can parse opts" do
        invoke 'palooza', '-x', 'ok'
        @box_action.xylo.should eql 'ok'
      end

      it "your custom op appears in syntax and help screen" do
        invoke '-h', 'palooza'
        expect_usage_line_ending_with 'tricknata-intgr palooza [-x <foo>]'
        expect_blank
        expect_header :options
        expect %r( {2,}-x, --xylophone <foo>\z)
        expect_succeeded
      end
    end

    context "append a proc to the existing normal o.p with `o.p`" do

      box_DSL_class :Jazz_Fat_Nasties do
        option_parser do |o|
          o.on '-y', '--ylophone <var>' do |x|
            @ylophone = x
          end
        end
        def dinkle
          :_yes_
        end
      end

      it "opt parse param value - gets a box context" do
        invoke 'dinkle', '-y', 'sure'
        @box_action.instance_variable_get( :@ylophone ).should eql 'sure'
        @result.should eql :_yes_
      end

      it "you still get the builtin -h which is appended to the end" do
        invoke 'dinkle', '-h'
        expect_usage_line_ending_with 'jazz-fat-nasties dinkle [-y <var>] [-h]'
        expect_blank
        expect_header :options
        expect %r( {2,} -y, --ylophone <var>\z)
        expect %r( {2,} -h, --help {2,}this screen\z)
        expect_succeeded
      end
    end

    context "(unlike possibly elsewhere) the o.p gets built.." do
      box_DSL_class :Autechre do
        build_option_parser do
          @did_do_this = :_yep_
          :_never_use_
        end
        def hello_thar
          :_ok_
        end
      end

      it "even when it is not needed" do
        invoke 'hello-thar'
        @box_action.instance_variable_get( :@did_do_this ).should eql :_yep_
        @result.should eql :_ok_
      end
    end
  end
end

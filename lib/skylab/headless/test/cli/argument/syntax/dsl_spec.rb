require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Argument::Syntax

  describe "[hl] CLI argument syntax DSL" do

    extend TS__

    context "syntax 1" do

      define_method :arg_syntax,Headless_::Library_::Memoize[ -> do

        Headless_::CLI.argument.syntax.DSL do

          o :optional, :literal, 'node-names'
          alternation do
            series do
              o :required, :literal, 'script'
              o :required, :value, :script
            end
          end
        end
      end ]

      it "3.1 'expecting script at foo'" do
        process_args 'foo', 'bar', 'baz'
        render_any_miss.should eql "expecting script at foo"
        expect_no_xtra
        expect_no_result_struct
        @result.should eql false
      end

      it "0   'expecting script'" do
        process_args
        render_any_miss.should eql "expecting script"
        expect_no_xtra
        expect_no_result_struct
        @result.should eql false
      end

      it "1.3 'expecting script' (provided optional name)" do
        process_args 'node-names'
        render_any_miss.should eql "expecting script"
        expect_no_xtra
        @result_struct.should be_nil
        @result.should eql false
      end

      it "1.3 'expecting <script>'" do
        process_args "script"
        render_any_miss.should eql "expecting <script>"
        @result.should eql false
      end

      it "2.3 \"script foo\" ok (opt flag not passed, not in result)" do
        process_args "script", "foo"
        expect_no_xtra ; expect_no_miss
        nn, sc = @result_struct.to_a
        nn.should be_nil
        sc.should eql 'foo'
        @result.should eql true
      end

      it "3.3 \"node-names script foo\" ok (opt flag passed, recognized)" do
        process_args "node-names", "script", "foo"
        expect_no_xtra ; expect_no_miss
        nn, sc = @result_struct.to_a
        nn.should eql true
        sc.should eql 'foo'
        @result.should eql true
      end

      def expect_no_xtra
        @extra.should be_nil
      end

      def expect_no_result_struct
        @result_struct.should be_nil
      end

      def expect_empty_result_struct
        if @result_struct
          @result_struct.to_a.should eql [ nil, nil ]
        end
      end

      def expect_no_miss
        @missing.should be_nil
      end

      def render_any_miss
        @missing and render_miss
      end
      def render_miss
        if (( set = @missing.any_at_token_set ))
          _at = " at #{ set.first }"
        end
        "expecting #{ @missing.syntax_slice[ 0 ].as_moniker }#{ _at }"
      end

      def render_any_xtra
        @extra and render_xtra
      end
      def render_xtra
        "unexpected: #{ @extra.s_a * ' ' }"
      end
    end

    def process_args * s_a
      ag = arg_syntax
      @extra = @missing = @result_struct = nil
      @result = ag.process_args s_a do |o|
        o.on_missing do |x|
          do_debug and debug_IO.puts "got missing: #{ x.inspect }"
          @missing = x
          false
        end
        o.on_extra do |x|
          do_debug and debug_IO.puts "got undexpected: #{ x.inspect }"
          @extra = x
          false
        end
        o.on_result_struct do |x|
          do_debug and debug_IO.puts "got result: #{ x.inspect }"
          @result_struct = x
          false
        end ; nil
      end
    end
  end
end

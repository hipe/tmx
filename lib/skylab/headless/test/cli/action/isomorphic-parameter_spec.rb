require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Action::Iso_Param__

  ::Skylab::Headless::TestSupport::CLI::Action[ TS__ = self ]

  include CONSTANTS

  Headless = Headless

  extend TestSupport::Quickie  # :[#136] also covers arg syntax

  describe "[hl] CLI action isomorphic params spec" do

    extend TS__

    context "the zero arg syntax ()" do

      klass :Syn_O do
        Headless::CLI::Client::DSL[ self ]
        default_action :noink
        def noink
          :ok
        end
      end

      it "0 args - no output, result is result" do
        invoke
        expect_no_more_serr_lines
        @result.should eql :ok
      end

      it "1 args - whines of unexpected, result is multi line" do
        invoke 'foo'
        expect %r(\bunexpected argument[^a-z]+foo[^a-z]*\z)i
        expect_a_few_more_serr_lines
        expect_neutral_result
      end
    end

    context "the one arg req syntax (foo)" do

      klass :Syn_req do
        Headless::CLI::Client::DSL[ self ]
        default_action :naples
        def naples mono_arg
          "->#{ mono_arg }<-"
        end
      end

      it "0 args - first line is styled whine of missing arg" do
        invoke
        expect :styled, /\bexpecting[^a-z]+mono-arg[^a-z]*\z/
        expect_a_few_more_serr_lines
        expect_neutral_result
      end

      it "1 args - no output, result is result" do
        invoke 'foo'
        expect_no_more_serr_lines
        @result.should eql '->foo<-'
      end

      it "2 args - whines of unexpected" do
        invoke 'aa', 'bb'
        expect %r(\bunexpected argument[^a-z]+bb[^a-z]*\z)
        expect_a_few_more_serr_lines
        expect_neutral_result
      end
    end

    context "the simple glob syntax (*args)" do

      klass :Syn_rest do
        Headless::CLI::Client::DSL[ self ]
        default_action :zeeple
        def zeeple *parts
          "{{ #{ parts.join ' -- ' } }}"
        end
      end

      it "0 args - no output, result is reesult" do
        invoke
        expect_no_more_serr_lines
        @result.should eql '{{  }}'
      end

      it "1 args - o" do
        invoke 'foo'
        expect_no_more_serr_lines
        @result.should eql '{{ foo }}'
      end

      it "2 args - o" do
        invoke 'foo', 'blearg'
        expect_no_more_serr_lines
        @result.should eql '{{ foo -- blearg }}'
      end
    end

    context "the trailing glob syntax (a, *b)" do

      klass :Syn_req_rest do
        Headless::CLI::Client::DSL[ self ]
        default_action :liffe
        def liffe apple, *annanes
          "_#{ annanes.unshift( apple ).join '*' }_"
        end
      end

      it "0 args - whines of missing" do
        invoke
        expect :styled, /\bexpecting[^a-z]+apple[^a-z]*\z/
        expect_a_few_more_serr_lines
        expect_neutral_result
      end

      it "1 args - o" do
        invoke 'foo'
        expect_no_more_serr_lines
        @result.should eql '_foo_'
      end

      it "2 args - o" do
        invoke 'x', 'y'
        expect_no_more_serr_lines
        @result.should eql '_x*y_'
      end

      it "3 args - o" do
        invoke %w( x y z )
        expect_no_more_serr_lines
        @result.should eql '_x*y*z_'
      end
    end

    context "weird syntax (*a, b)" do

      klass :Syn_rest_req do
        Headless::CLI::Client::DSL[ self ]
        default_action :feeples
        def feeples *lip, nip
          ( lip.push nip ).join '.'
        end
      end

      it "0 args - whines of missing" do
        invoke
        expect :styled, /\bexpecting[^a-z]+nip[^a-z]*\z/i
        expect_a_few_more_serr_lines
        expect_neutral_result
      end

      it "1 arg - o" do
        invoke 'sure'
        expect_no_more_serr_lines
        @result.should eql 'sure'
      end
    end

    context "weird syntax (a, *b, c)" do

      klass :Syn_req_rest_req do
        Headless::CLI::Client::DSL[ self ]
        default_action :fooples
        def fooples zing, *zang, zhang
          "(#{ [ zing, *zang, zhang ].join '|' })"
        end
      end

      it "0 args - whines of missing" do
        invoke
        expect :styled, /\bexpecting[^a-z]+zing[^a-z]*\z/i
        expect_a_few_more_serr_lines
        expect_neutral_result
      end

      it "1 arg - whines of missing" do
        invoke 'win'
        expect :styled, /\bexpecting[^a-z]+zhang[^a-z]*\z/i
        expect_a_few_more_serr_lines
        expect_neutral_result
      end

      it "2 args - o" do
        invoke 'one', 'two'
        expect_no_more_serr_lines
        @result.should eql '(one|two)'
      end

      it "3 args - o" do
        invoke 'A', 'B', 'C'
        expect_no_more_serr_lines
        @result.should eql '(A|B|C)'
      end
    end
  end
end

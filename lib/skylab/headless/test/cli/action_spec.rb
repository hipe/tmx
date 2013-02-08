require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Action
  ::Skylab::Headless::TestSupport::CLI[ Action_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Headless }::CLI::Action - invoke (parsing)" do

    extend Action_TestSupport

    context "the zero arg syntax ()" do
      klass :Syn_O do
        extend Headless::CLI::Client::DSL
        default_action :noink
        def noink
          :ok
        end
      end

      it "0 args - yes" do
        res = invoke []
        serr.should be_empty
        res.should eql( :ok )
      end

      it "1 args - complains of unexpected" do
        res = invoke ['foo']
        serr.first.should match( /unexpected argument[^a-z]+foo[^a-z]*\z/i )
        res.should be_nil
      end
    end

    context "the one arg req syntax (foo)" do
      klass :Syn_req do
        extend Headless::CLI::Client::DSL
        default_action :naples
        def naples mono_arg
          "->#{ mono_arg }<-"
        end
      end

      it "0 args - complains of missing" do
        res = invoke []
        styled( serr.first ).should match( /expecting[^a-z]+mono-arg[^a-z]*\z/ )
        res.should be_nil
      end

      it "1 args - yes" do
        res = invoke ['foo']
        serr.should be_empty
        res.should eql( '->foo<-' )
      end

      it "2 args - complains of unexpected" do
        res = invoke ['aa', 'bb']
        serr.first.should match( /unexpected argument[^a-z]+bb[^a-z]*\z/ )
        res.should be_nil
      end
    end

    context "the simple glob syntax (*args)" do
      klass :Syn_rest do
        extend Headless::CLI::Client::DSL
        default_action :zeeple
        def zeeple *parts
          "{{ #{ parts.join ' -- ' } }}"
        end
      end

      it "0 args - yes" do
        res = invoke []
        serr.should be_empty
        res.should eql( '{{  }}' )
      end

      it "1 args - yes" do
        res = invoke ['foo']
        serr.should be_empty
        res.should eql( '{{ foo }}' )
      end

      it "2 args - yes" do
        res = invoke ['foo', 'blearg']
        serr.should be_empty
        res.should eql( '{{ foo -- blearg }}' )
      end
    end

    context "the trailing glob syntax (a, *b)" do
      klass :Syn_req_rest do
        extend Headless::CLI::Client::DSL
        default_action :liffe
        def liffe apple, *annanes
          "_#{ annanes.unshift( apple ).join '*' }_"
        end
      end

      it "0 args - complains of missing" do
        res = invoke []
        styled( serr.first ).should match( /expecting[^a-z]+apple[^a-z]*\z/ )
        res.should be_nil
      end

      it "1 args - yes" do
        res = invoke ['foo']
        serr.should be_empty
        res.should eql( '_foo_' )
      end

      it "2 args - yes" do
        res = invoke ['x', 'y']
        serr.should be_empty
        res.should eql( '_x*y_' )
      end

      it "3 args - yes" do
        res = invoke %w( x y z )
        serr.should be_empty
        res.should eql( '_x*y*z_' )
      end
    end

    context "weird syntax (*a, b)" do

      klass :Syn_rest_req do
        extend Headless::CLI::Client::DSL
        default_action :feeples
        def feeples *lip, nip
          ( lip.push nip ).join '.'
        end
      end

      it "0 args - complains of missing" do
        res = invoke []
        styled( serr.shift ).should match( /expecting[^a-z]+nip[^a-z]*\z/i )
        res.should be_nil
      end

      it "1 arg - yes" do
        res = invoke ['sure']
        serr.should be_empty
        res.should eql( 'sure' )
      end
    end

    context "weird syntax (a, *b, c)" do

      klass :Syn_req_rest_req do
        extend Headless::CLI::Client::DSL
        default_action :fooples
        def fooples zing, *zang, zhang
          "(#{ [ zing, *zang, zhang ].join '|' })"
        end
      end

      it "0 args - complains of missing" do
        res = invoke []
        styled( serr.shift ).should match( /expecting[^a-z]+zing[^a-z]*\z/i )
        res.should be_nil
      end

      it "1 arg - complains of missing" do
        res = invoke ['win']
        styled( serr.shift ).should match( /expecting[^a-z]+zhang[^a-z]*\z/i )
        res.should be_nil
      end

      it "2 args - yes" do
        res = invoke ['one', 'two']
        serr.should be_empty
        res.should eql( '(one|two)' )
      end

      it "3 args - yes" do
        res = invoke ['A', 'B', 'C']
        serr.should be_empty
        res.should eql( '(A|B|C)' )
      end
    end
  end
end

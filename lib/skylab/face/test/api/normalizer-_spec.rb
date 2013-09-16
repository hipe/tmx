require_relative 'test-support'

module Skylab::Face::TestSupport::API::Normalizer_

  ::Skylab::Face::TestSupport::API[ TS_ = self ]

  include CONSTANTS

  Face = Face

  extend TestSupport::Quickie

  describe "#{ Face }::API::Normalizer_" do

    extend TS_

    context "with one (defacto) required field" do

      before :all do
        class X_Requirer < Base_Magic
          Face::API::Params_[ :client, self, :param, :x ]
          Face::API::Normalizer_.enhance_client_class self, :all
          def execute
            @x
          end
        end
      end

      it "missing the required field" do
        ag = X_Requirer.new infostream
        r = ag.flush
        only_line.should match(
          /\Amissing required parameter ['"]x['"] for .+::X_Requirer\z/ )
        r.should eql( false )
      end

      it "one unrecognized field" do
        ag = build X_Requirer
        ag.param_h[ :foo ] = nil
        r = ag.flush
        only_line.should match(
          /\Aundeclared parameter ['"]foo['"] for .+X_Requirer.+macro\?\)\z/ )
        r.should eql( false )
      end

      it "two unrecognized fields" do
        r = build( X_Requirer ).with( :foo, :bar, :bing, :bang ).flush
        r.should eql( false )
        only_line.should match(
          /\Aundeclared parameters ['"]foo['"] and ['"]bing['"] for.+X.+them with `pa/ )
      end

      let :agent_class do X_Requirer end

      it "x as symbol - ok" do
        r = build.with( :x, :foo ).flush
        r.should eql( :foo )
        there_should_be_no_lines
      end

      it "x as empty array - LOOK it craps out" do
        r = build.with( :x, [] ).flush
        only_line.should match_this_message
        r.should eql( false )
      end

      def match_this_message
        match( /\Amultiple arguments were provided for \"x\" but only #{
            }one can be accepted/i )
      end

      it "x as the one-length array - LOOK it still craps out" do
        r = build.with( :x, [ :one_thing ] ).flush
        only_line.should match_this_message
        r.should eql( false )
      end
    end

    context "with one polyadic required field" do

      before :all do
        class A_Requirer < Base_Magic
          Face::API::Params_[ :client, self, :param, :arr, :arity, :one_or_more ]
          Face::API::Normalizer_.enhance_client_class self, :all
          def execute
            @arr
          end
        end
      end

      let :agent_class do A_Requirer end

      it "no args at all - borks" do
        r = build.flush
        only_line.should match( /\Amissing required parameter ['"]arr['"] for / )
        r.should eql( false )
      end

      it "one non-array" do
        r = build.with( :arr, :zippers ).flush
        only_line.should match( /\Astrange shape for ['"]arr['"] - when arity #{
          }is many and argument arity is one, expected array-like, had #{
          }['"]zippers['"]\z/ )
        r.should eql( false )
      end

      it "one empty array" do
        r = build.with( :arr, [] ).flush
        only_line.should match( /must have one or more \"arr\"/ )
        r.should eql( false )
      end

      it "one one array with nil as the element" do
        r = build.with( :arr, [ nil ] ).flush
        there_should_be_no_lines
        r.should eql( [ nil ] )
      end
    end

    class Base_Magic
      def initialize e
        @infostream = e
        @param_h = { }
      end
      attr_reader :param_h
      def field_box
        self.class::FIELDS_
      end
      attr_accessor :any_expression_agent
      def with *a
        ( 0.step( a.length - 1 , 2 ) ).each do |i|
          @param_h[ a[ i ] ] = a[ i + 1 ]
        end
        self
      end
    end

    def build cls=agent_class
      cls.new infostream
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end
end

require_relative '../test-support'

module Skylab::Brazen::TestSupport::Mo_Ent

  o = ::Skylab::Brazen::TestSupport

  o[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[br] model entity" do

    class << self

      def _with_class & p

        tcm = self

        before :all do
          _THE_CLASS_ = nil.instance_exec( & p )
          tcm.send :define_method, :_subject_class do
            _THE_CLASS_
          end
        end
      end
    end

    it "loads" do
      Subject_[]
    end

    context "defaulting" do

      _with_class do

        class E__Small_Agent_With_Defaults

          include Test_Instance_Methods_

          Subject_.call self do
            o :default, :yay, :property, :foo
          end

          self
        end
      end

      it "(with defaulting)" do
        ok = nil
        ent = _subject_class.new do
          ok = process_and_normalize_for_test_
        end
        ok.should eql true
        ent.bx.fetch( :foo ).should eql :yay
      end

      it "(without defaulting)", f:true do
        ok = nil
        ent = _subject_class.new do
          ok = process_and_normalize_for_test_ :foo, :bar
        end
        ent.bx.fetch( :foo ).should eql :bar
      end
    end

    context "integer-related metaproperty (this covers some ad-hoc n11n)" do

      _with_class do

        class E__Integer

          def initialize
            @on_event_selectively = nil
            super
          end

          include Test_Instance_Methods_

          Subject_.call self do
            o :integer_greater_than_or_equal_to, -2, :property, :zoip
          end

          def handle_event_selectively
            @on_event_selectively
          end

          self
        end
      end

      it "when yes" do

        ok = nil
        ent = _subject_class.new do
          ok = process_and_normalize_for_test_ :zoip, -2
        end
        ent.bx.fetch( :zoip ).should eql( -2 )
        ok.should eql true
      end

      it "when no", f:true do
        _i_a = ev = nil
        p = -> * i_a, & ev_p do
          _i_a = i_a
          ev = ev_p[]
          false
        end
        ok = nil

        _subject_class.new do
          @on_event_selectively = p
          ok = process_and_normalize_for_test_ :zoip, -3
        end
        ok.should eql false
        _i_a.should eql [ :error, :invalid_property_value ]
        ev.terminal_channel_i.should eql :number_too_small
      end
    end

    context "required fields" do

      _with_class do

        class E__Small_Agent_With_Required_Properties

          include Test_Instance_Methods_

          Subject_.call self,
            :required, :property, :foo,
            :required, :property, :bar,
            :properties, :bif, :baz

          self
        end
      end

      it "loads agent class" do
        _subject_class
      end

      it "when all requireds are provided" do
        ok = nil
        ent = _subject_class.new do
          ok = process_and_normalize_for_test_ :foo, :a, :bar, :b, :baz, :c
        end
        ok.should eql true
        ent.bx.at( :foo, :bar, :baz ).should eql [ :a, :b, :c ]
      end

      it "when required args are missing, throws exception with same msg as app" do

        begin
          _subject_class.new do
            process_and_normalize_for_test_ :bif, :x, :baz, :y
          end
        rescue ::ArgumentError => e
        end

        e.message.should eql "missing required properties 'foo' and 'bar'"
      end
    end

    Subject_ = -> * a, & p do

      if a.length.nonzero? || p
        Brazen_::Model.common_entity( * a, & p )
      else
        Brazen_::Model.common_entity_module
      end
    end

    Brazen_ = Brazen_
    Enhance_for_test_ = o::Enhance_for_test_
    NIL_ = nil
    WITH_MODULE_METHOD_ = o::WITH_MODULE_METHOD_
    Test_Instance_Methods_ = o::Test_Instance_Methods_
  end
end

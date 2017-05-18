require_relative '../test-support'

module Skylab::Brazen::TestSupport

  module Modelesque_Entity_Namespace____  # <-

  TS_.describe "[br] modelesque - entity" do

    class << self

      def _with_class & p

        tcc = self

        before :all do
          _THE_CLASS_ = nil.instance_exec( & p )
          tcc.send :define_method, :_subject_class do
            _THE_CLASS_
          end
        end
      end
    end  # >>

    it "loads" do
      Subject_[]
    end

    context "defaulting" do

      _with_class do

        class E__Small_Agent_With_Defaults

          include TheseMethods__

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

          include TheseMethods__

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
        ev.terminal_channel_symbol == :number_too_small || fail
      end
    end

    context "required fields" do

      _with_class do

        class E__Small_Agent_With_Required_Properties

          include TheseMethods__

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
        rescue Home_::Field_::MissingRequiredAttributes => e
        end

        e.message.should eql "missing required attributes 'foo' and 'bar'"
      end
    end

    # ==

    module TheseMethods__

      def initialize & edit_p
        instance_exec( & edit_p )
      end

      # -- to be an entity (model or action) you have to:

      def _read_knownness_ prp  # :+#cp

        if bx
          had = true
          x = bx.fetch prp.name_symbol do
            had = false
          end
        end

        if had
          Common_::KnownKnown[ x ]
        else
          Common_::KNOWN_UNKNOWN
        end
      end

      def as_entity_actual_property_box_
        @bx ||= Home_::Box_.new
      end

      def handle_event_selectively
        NIL_
      end

      # -- for these tests

      attr_reader :bx

      private def process_and_normalize_for_test_ * x_a

        _st = Common_::Scanner.via_array x_a
        _ok = process_argument_scanner_fully _st
        _ok && normalize
      end
    end

    # ==

    Subject_ = -> * a, & p do

      if a.length.nonzero? || p
        Home_::Modelesque.entity( * a, & p )
      else
        Home_::Modelesque::Entity
      end
    end

    # ==
    # ==
  end
# ->
  end
end
# #history-A: a big support module of instance methods moved here from top test-support

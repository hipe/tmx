require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - normalization (progressive edit sessions)" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :attributes

    # ==

      context "for requireds" do

        shared_subject :entity_class_ do

          class X_a_n_NoSee_A

            attrs = Attributes.lib.call(
              first_name: :optional,
              last_name: nil,
              soc: nil,
            )

            attr_writer( * attrs.symbols )

            ATTRIBUTES = attrs

            self
          end
        end

        context "lowlevel normalization session" do

          it "using box instead of the default ivar-based store" do

            bx = Common_::Box.new
            bx.add :_strange_, :_no_see_
            bx.add :soc, false  # not nil, i.e is provided

            _ = _normalize_by do |o|
              o.box_store = bx
            end

            false == _ or fail

            _rx = %r(\Amissing required \w+ 'last-name')i

            expect_event :missing_required_attributes do |ev|
              black_and_white( ev ).should match _rx
            end
          end

          it "using the empty store" do

            _ = _normalize_by do |o|
              o.WILL_USE_EMPTY_STORE  # [ta] only
            end

            false == _ or fail

            _rx = %r(\Amissing required \w+s 'last-name' and 'soc')i

            expect_event :missing_required_attributes do |ev|
              black_and_white( ev ).should match _rx
            end
          end

          def _normalize_by

            _ = event_log.handle_event_selectively

            _wat = entity_class_::ATTRIBUTES.AS_ATTRIBUTES_NORMALIZE_BY do |o|
              yield o
              o.listener = _
            end

            _wat  # hi. #todo
          end
        end

        context "when some missing" do

          shared_subject :state_ do

            _ = build_empty_entity_

            _against_this_entity _
          end

          it "fails" do
            this_false_or_nil_ == state_.result || fail
          end

          it "emits" do

            _rx = /\bmissing required attributes 'last-name' and 'soc'/

            _be_this = be_emission :error, :missing_required_attributes do |ev|
              _msg = black_and_white ev
              _msg.should match _rx
            end

            only_emission.should _be_this
          end
        end

        it "when none missing oK" do

          o = build_empty_entity_
          o.last_name = false  # treated as required
          o.soc = :yeah
          _against_this_entity_expect_OK_normalization o
        end
      end

      context "defaulting" do

        shared_subject :entity_class_ do

          class X_a_n_NoSee_B

            attrs = Attributes.lib.call(
              a: [ :default, :one ],
              b: nil,
              c: [ :default, :three, ],
            )

            attr_writer( * attrs.symbols )
            attr_reader( * attrs.symbols )

            ATTRIBUTES = attrs

            self
          end
        end

        it "doesn't overwrite already provided (non-nil) values" do

          o = build_empty_entity_
          o.a = false
          o.b = false
          o.c = :hi

          _against_this_entity_expect_OK_normalization o

          false == o.a or fail
          :hi == o.c or fail
        end

        it "does default only one nil value" do

          o = build_empty_entity_
          o.a = :hello
          o.b = :howdy

          o.instance_variable_defined?( :@c ).should eql false

          _against_this_entity_expect_OK_normalization o

          :hello == o.a or fail
          :howdy == o.b or fail
          :three == o.c or fail
        end

        it "does default all nil values" do

          o = build_empty_entity_
          o.a = nil
          o.b = false
          _against_this_entity_expect_OK_normalization o
          :one == o.a or fail
          :three == o.c or fail
        end
      end

      context "(synthesis)" do

        shared_subject :entity_class_ do

          class X_a_n_NoSee_C

            attrs = Attributes.lib.call(

              a: :optional,
              b: nil,
              c: [ :default, :three ],
              d: [ :default, :four ],
            )

            attr_writer( * attrs.symbols )
            attr_reader( * attrs.symbols )

            ATTRIBUTES = attrs

            self
          end
        end

        it "when ok" do

          o = build_empty_entity_

          o.instance_variable_set :@b, true

          _against_this_entity_expect_OK_normalization o

          :three == o.c or fail
          :four == o.d or fail
        end

        context "when missing (note all defaulting is effected regardless)" do

          shared_subject :_state_tuple do

            o = build_empty_entity_

            _ = event_log.handle_event_selectively

            x = entity_class_::ATTRIBUTES.normalize_entity o, & _

            a = remove_instance_variable( :@event_log ).flush_to_array

            [ x, a, o ]
          end

          it "fails (with nil)" do
            this_false_or_nil_ == _state_tuple.fetch( 0 ) or fail
          end

          it "emits" do

            _rx = /\Amissing required attribute 'b'$/

            _be_this = be_emission :error, :missing_required_attributes do |ev|

              black_and_white( ev ).should match _rx

            end

            only_emission.should _be_this
          end

          it "event has details" do

            _em = emission_array.fetch( 0 )

            _ev = _em.cached_event_value

            a = _ev.reasons

            a.length.should eql 1

            a.first.name_symbol.should eql :b
          end

          it "did NOT write defaults!" do

            o = _state_tuple.fetch 2

            o.instance_variable_defined?( :@c ) and fail
            o.instance_variable_defined?( :@d ) and fail
          end

          def emission_array
            _state_tuple.fetch 1
          end
        end
      end

      def _against_this_entity_expect_OK_normalization o

        _x = entity_class_::ATTRIBUTES.normalize_entity o
        true == _x or fail
      end

      def _against_this_entity o

        _ = event_log.handle_event_selectively

        _x = entity_class_::ATTRIBUTES.normalize_entity o, & _

        flush_event_log_and_result_to_state _x
      end
    # ==
  end
end

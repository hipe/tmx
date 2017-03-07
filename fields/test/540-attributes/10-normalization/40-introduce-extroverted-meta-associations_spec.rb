require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - normalization - extroverted features" do

    # defaulting & re

    TS_[ self ]
    use :memoizer_methods
    use :attributes

    # ==

      context "(those that are not optional are required.)" do

        shared_subject :_guy do

          class X_a_nudar_NoSee_A

            ATTRIBUTES = Attributes.lib.call(
              alpha: :optional,
              beta: nil,
              gamma: :optional,
              delta: nil,
            )

            attr_writer( * ATTRIBUTES.symbols )

            self
          end
        end

        it "raises argument error" do
          _msg = "missing required attributes 'beta' and 'delta'"

          o = _guy.new
          begin
            _subject[ o ]
          rescue Home_::ArgumentError => e
          end

          e.message.should eql _msg
        end
      end

    # ==
    # ==

    context "(E.K)" do

      context "unrec" do

        it "messages splays" do  # :#coverpoint1.7

          a = _N_things

          expect_channel_ a, :error, :argument_error, :primary_not_found

          _lines = black_and_white_lines_via_event_ a[1].call
          expect_these_lines_in_array_ _lines do |y|
            y << 'unrecognized attribute :aa'
            y << 'did you mean :alpha, :beta or :gamma?'
          end
        end

        shared_subject :_N_things do
          call_thru_normalize_ :aa, :bb
        end

        def entity_class_
          _entity_class_B
        end
      end

      context "missing requireds" do

        it "use the very new against the very old. use the word \"parameter\"" do
          # #coverpoint1.2: `id2name` is a necessary thing, and "parameter" the word

          a = _N_things
          expect_channel_looks_like_missing_required_ a
          _line = black_and_white_line_via_event_ a[1].call
          _line == "missing required parameters 'beta' and 'delta'\n" || fail
        end

        shared_subject :_N_things do

          call_thru_normalize_ :alpha, :A1, :gamma, :G1
        end

        def entity_class_
          _entity_class_B
        end
      end

      it "what if ivar set and param passed and was nil?"

      shared_subject :_entity_class_B do

        class X_a_nudar_NoSee_B

          include Attributes::EK_ModelMethods

          def _definition_ ; [
            :property, :alpha,
            :required, :property, :beta,
            :property, :gamma,
            :required, :property, :delta,
          ] end

          self
        end
      end
    end

    # (counterpart E.K test about defaulting is in dedicated defaults)

    # ==
    # ==

    def _subject
      subject_library_::Normalization::Normalize_via_Entity_with_StaticAssociations
    end
  end
end

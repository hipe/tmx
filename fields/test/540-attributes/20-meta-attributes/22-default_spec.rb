require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attributes - meta-attributes - default" do

    TS_[ self ]
    use :memoizer_methods
    use :attributes_meta_attributes

    # ==

      context "intro" do

        shared_subject :entity_class_ do

          class X_a_ma_d_NoSee_1A

            attrs = Attributes::Meta_Attributes.lib.call(
              starts_as_true: [ :default, true ],
            )

            ATTRIBUTES = attrs

            attr_reader :starts_as_true

            self
          end
        end

        it "has `default_proc`" do
          _attr.default_proc or fail
        end

        it "..which produces the value" do
          true == _attr.default_proc.call or fail
        end

        it "in a call to `init` without the value, it is set" do

          _against_expect Home_::EMPTY_A_, true
        end

        it "in a call to `init` with the value as false, default is NOT applied" do

          _against_expect [ :starts_as_true, false ], false
        end

        it "but if you set the thing to nil, the default is still applied.." do

          # #coverpoint1.9

          _against_expect [ :starts_as_true, nil ], true
        end

        def _attr
          entity_class_::ATTRIBUTES.attribute :starts_as_true
        end

        def _against_expect a, x

          _ = build_by_init_via_sexp_ a
          _.starts_as_true.should eql x
        end
      end

      context "`default_proc` is also a thing (more low-level, same effect)" do

        shared_subject :entity_class_ do

          class X_a_ma_d_NoSee_1B

            d = 0

            attrs = Attributes::Meta_Attributes.lib.call(
              wahoo: [ :default_proc, -> { "wahootie: #{ d += 1 }" } ],
              other: nil,
            )

            ATTRIBUTES = attrs

            attr_reader( * attrs.symbols )

            self
          end
        end

        it "don't" do

          o = build_by_init_ :wahoo, :xx, :other, :hi
          :hi == o.other or fail
          :xx == o.wahoo or fail
        end

        it "do" do
          o = build_by_init_ :other, :hi
          :hi == o.other or fail
          "wahootie: 1" == o.wahoo or fail
        end
      end

    # ==
    # ==

    context "(E.K)" do

      context "(against this one entity class)" do

        it "defaulting happens in this semi-normal case" do

          ent = call_thru_normalize_(
            :secret_horrible_dont_do_this, :_make_the_default_OK_,
            :jamooka, :J1,
          )

          ent.jamooka == :J1 || fail
          ent.faflooka == :always_sunny || fail
        end

        it "(obv you can set the other one too)" do

          ent = call_thru_normalize_(
            :secret_horrible_dont_do_this, :_make_the_default_OK_,
            :faflooka, :F1
          )

          ent.faflooka == :F1 || fail
          ent.jamooka == :JAMOOKA || fail
        end

        it "but defaulting can fail, which is when required defaultant makes sense" do

          a = call_thru_normalize_(
            :secret_horrible_dont_do_this, :_make_the_default_not_OK_,
            :faflooka, :F1
          )
          expect_channel_looks_like_missing_required_ a
          _ev = a[1].call
          _ev.reasons.to_a == [ :jamooka ] || fail
        end

        def entity_class_
          _entity_class_2A
        end
      end

      shared_subject :_entity_class_2A do

        class X_a_ma_d_NoSee_2A

          include Attributes::EK_ModelMethods

          # (the below nastiness is so we have a defaulting proc
          # that "flickers" - under some conditions it appears to fail)

          def _definition_ ; [

            :property, :faflooka, :default_by, -> _xx do
              Common_::KnownKnown[ :always_sunny ]
            end,

            :required, :property, :jamooka, :default_by, -> ent do

              case ent.secret_horrible_dont_do_this
              when :_make_the_default_OK_
                Common_::KnownKnown[ :JAMOOKA ]
              when :_make_the_default_not_OK_
                NIL  # NOTHING_
              else ; fail
              end
            end,

            :property, :secret_horrible_dont_do_this,
          ] end

          attr_reader(
            :jamooka, :faflooka, :secret_horrible_dont_do_this,
          )

          self
        end
      end
    end

    # ==
    # ==
  end
end

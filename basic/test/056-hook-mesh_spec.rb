require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] hook mesh" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module
    end

    context "define a minimal conditional branch (no ELSE)" do

      it "builds" do
        _instance || fail
      end

      it "when test passes, calls the \"when true\" proc" do

        _require_local_classes

        _x = _instance.against_value X_hm_SkyDetails.new :water
        _x == :_use_umbrella_ || fail
      end

      it "when test fails, nothing" do

        _require_local_classes

        _x = _instance.against_value X_hm_SkyDetails.new :snow
        _x == NOTHING_ || fail
      end

      shared_subject :_instance do

        _subject_module.define :main do |defn|

          defn.main do |o|
            if :water == o.value.what_is_falling_from_the_sky
              :_use_umbrella_
            end
          end
        end
      end
    end

    context "has a \"when true\" proc and a \"when false\" proc" do

      it "builds" do
        _instance || fail
      end

      it "test reaches first terminal" do

        _x = _instance.against_value X_hm_SkyDetails.new :hail
        _x == :_yes_it_is_hailing_ || fail
      end

      it "test reaches second terminal (recursive-ish-ly)" do

        _x = _instance.against_value X_hm_SkyDetails.new :sleet
        _x == :_yes_it_is_sleeting_ || fail
      end

      it "test reaches the third case (no \"when false\" present)" do

        _x = _instance.against_value X_hm_SkyDetails.new :frogs
        _x == NOTHING_ || fail
      end

      context "redefine" do

        it "builds" do
          _other_instance || fail
        end

        it "works" do

          _require_local_classes

          o = _other_instance

          o.against_value( X_hm_SkyDetails.new :golf_balls ) == :_golf_balls_ || fail

          o.against_value( X_hm_SkyDetails.new :xx ) == :_not_hail_or_golf_balls_ || fail
        end

        shared_subject :_other_instance do

          _orig = _instance

          _other = _orig.redefine do |defn|

            defn.replace :not_hailing do |o|
              if :golf_balls == o.value.what_is_falling_from_the_sky
                :_golf_balls_
              else
                o.when( :not_hail_or_golf_balls )[ o ]
              end
            end

            defn.add :not_hail_or_golf_balls do |o|
              :_not_hail_or_golf_balls_
            end
          end

          _orig.instance_variable_get( :@_hook_box ).h_.
            key?( :not_hail_or_golf_balls ) && fail

          _other
        end
      end

      shared_subject :_instance do

        _subject_module.define :main do |defn|

          defn.main do |o|
            if :hail == o.value.what_is_falling_from_the_sky
              :_yes_it_is_hailing_
            else
              o.when( :not_hailing )[ o ]
            end
          end

          defn.add :not_hailing do |o|

            if :sleet == o.value.what_is_falling_from_the_sky
              :_yes_it_is_sleeting_
            end
          end
        end
      end
    end

    shared_subject :_require_local_classes do

      class X_hm_SkyDetails

        def initialize sym
          @what_is_falling_from_the_sky = sym
        end

        attr_reader(
          :what_is_falling_from_the_sky,
        )
      end

      NIL
    end

    def _subject_module
      Home_::HookMesh
    end
  end
end
# #born during unification to [tab] gem.

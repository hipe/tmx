require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] depdendencies - argument demux" do

    TS_[ self ]
    use :dependencies

    rxs = '[A-Za-z0-9_:]+'

    context "(one)" do

      before :all do

        module DeA_Mod1

          class Breader

            ARGUMENTS = [ :argument_arity, :one, :property, :is_diet ]

            DeA_subject_module[]::Has_arguments[ self ]
          end

          class Vegetabler

            ARGUMENTS = [ :argument_arity, :zero, :property, :is_diet ]

            DeA_subject_module[]::Has_arguments[ self ]
          end
        end
      end

      it "at argument parse time, arities are reconciled" do

        o = subject_class_.new
        o.emits = [ :argument_bid_for ]
        o.index_dependencies_in_module DeA_Mod1

        st = Callback_::Polymorphic_Stream.via_array [ :is_diet ]

        begin
          o.process_polymorphic_stream_fully st
        rescue subject_class_::Definition_Conflict => e
        end

        e.message.should match(
          /\Athe arity in the first encountered definition for #{
            }'is_diet' was 'one', #{
             }but then encountered a definition with an arity of 'zero' \(#{
              }respectively by #{ rxs }Breader then #{ rxs }Vegetabler\)\z/ )
      end
    end

    context "(two)" do

      before :all do

        module DeA_Mod2

          class Breader

            ARGUMENTS = [
              :argument_arity, :one, :property, :color,
              :argument_arity, :zero, :property, :is_diet,
              :argument_arity, :one, :property, :for_bread,
            ]

            ROLES = [ :brd ]

            DeA_subject_module[]::Has_arguments[ self ]

            attr_reader :brd_is_diet

            def receive__is_diet__flag
              @brd_is_diet = true
              true
            end

            attr_reader :brd_color

            def receive__color__argument x
              @brd_color = x
              true
            end
          end

          class Vegetabler

            ARGUMENTS = [
              :argument_arity, :one, :property, :color,
              :argument_arity, :zero, :property, :is_diet,
              :argument_arity, :zero, :property, :flag_for_veg
            ]

            ROLES = [ :veg ]

            DeA_subject_module[]::Has_arguments[ self ]

            attr_reader :veg_is_diet

            def receive__is_diet__flag
              @veg_is_diet = true
              true
            end

            attr_reader :veg_color

            def receive__color__argument x
              @veg_color = x
              true
            end
          end
        end
      end

      share_subject :_common_guy do
        _common_guy_against DeA_Mod2
      end

      it "\"flag\"-style arguments are de-muxed (when definitions OK)" do

        o = _common_guy
        st = argument_stream_via_ :is_diet
        _kp = o.process_polymorphic_stream_fully st

        true == _kp or fail
        o[ :brd ].brd_is_diet or fail
        o[ :veg ].veg_is_diet or fail
        st.no_unparsed_exists or fail
      end

      it "mondaic arguments are de-muxed (ditto)" do

        o = _common_guy
        st = argument_stream_via_ :color, :red
        _kp = o.process_polymorphic_stream_fully st

        true == _kp or fail
        o[ :brd ].brd_color.should eql :red
        o[ :veg ].veg_color.should eql :red
        st.no_unparsed_exists or fail
      end

      it "passive parsing works" do

        o = _common_guy
        st = argument_stream_via_ :is_diet, :color, :red, :howzaa
        _kp = o.process_polymorphic_stream_passively st

        st.current_token.should eql :howzaa
        _kp.should eql true
      end

      it "active parsing barfs on unrec" do

        o = _common_guy
        st = argument_stream_via_ :is_diet, :color, :red, :howzaa

        begin
          o.process_polymorphic_stream_fully st
        rescue ::ArgumentError => e
        end

        e.message.should eql "unrecognized property 'howzaa'"
      end
    end

    context "(three)" do

      before :all do

        module DeA_Mod3

          class Breader

            ARGUMENTS = [
              :argument_arity, :custom, :property, :x
            ]

            ROLES = [ :brd ]

            DeA_subject_module[]::Has_arguments[ self ]

          end

          class Vegetabler

            ARGUMENTS = [
              :argument_arity, :custom, :property, :x
            ]

            ROLES = [ :veg ]

            DeA_subject_module[]::Has_arguments[ self ]

          end
        end
      end

      share_subject :_common_guy do

        _common_guy_against DeA_Mod3
      end

      it "if a dependency wants to 'custom' parse, this cannot be shared" do

        o = _common_guy
        st =  argument_stream_via_ :x
        begin
          o.process_polymorphic_stream_fully st
        rescue subject_class_::Definition_Conflict => e
        end

        e.message.should match(
          /\A#{ rxs }Vegetabler cannot also declare that it parses 'x'#{
           } because #{ rxs }Breader has already declared a custom parser #{
            }for it\z/ )
      end
    end

    def _common_guy_against mod

      o = subject_class_.new
      o.emits = [ :argument_bid_for ]
      o.roles = [ :brd, :veg ]
      o.index_dependencies_in_module mod
      o
    end

    DeA_subject_module = -> do
      Home_::Dependencies::Argument
    end
  end
end

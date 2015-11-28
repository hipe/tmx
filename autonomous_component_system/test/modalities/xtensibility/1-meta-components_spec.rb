require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[br] ACS - [e]xtensibility - meta components" do

    # (what is accomplished here is referenced elsewhere as :[#003]#X1)

    extend TS_
    use :memoizer_methods
    use :future_expect

    context "(one model)" do

      it "you can use meta-components as flags" do

        st = _the_stream.reduce_by do | qkn |
          qkn.association._is_pokemon
        end

        st.gets.association._is_pokemon or fail
        st.gets.association._is_pokemon or fail
        st.gets.should be_nil
      end

      it "meta-components can take arguments" do

        _the_memoized_array.fetch( 1 ).association._color.should eql :red
      end

      it "even an association with no use of the special DSL gets the class" do

        _the_memoized_array.last.association._color.should be_nil
      end

      def _the_stream
        Callback_::Stream.via_nonsparse_array _the_memoized_array
      end

      dangerous_memoize :_the_memoized_array do

        _hi = ___the_ACS_class.new
        _st = ACS_X_1::ACS_::For_Interface::Infer_stream[ _hi ]
        _st.to_a
      end

      memoize :___the_ACS_class do

        module ACS_X_1

          ACS_ = Home_

          class Donkulous

            def __one__component_association

              yield :pokemon
              :x
            end

            def __two__component_association

              yield :color, :red
              :x
            end

            def __three__component_association

              yield :pokemon
              :x
            end

            def __four__component_association
              :x
            end

            def component_association_reader

              Require_it___[]

              My_Comp_Assoc.method_based_reader_for self
            end
          end

          Require_it___ = Callback_.memoize do

            class My_Comp_Assoc < ACS_::Component_Association

              def accept__pokemon__meta_component
                @_is_pokemon = true ; nil
              end

              def accept__color__meta_component x
                @_color = x ; nil
              end

              attr_reader(
                :_color,
                :_is_pokemon,
              )
            end

            nil
          end

          Donkulous
        end
      end
    end
  end
end

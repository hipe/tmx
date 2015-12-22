require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] primitives with operations" do

    TS_[ self ]
    use :memoizer_methods
    use :future_expect
    use :modalities_reactive_tree

    context "several component association with proc-like models.." do

      it "one with no assoc-operations is not exposed to the UI" do

        _init_fresh_setup

        @_shoe._did_run_.should be_nil

        future_expect_only :error, :no_such_action

        call_ :ugg, :looks_like_proc_but_no_operations

        @_shoe._did_run_.should eql true

        @result.should eql false
      end

      it "omg the hypothetic `get` would work" do

        _init_fresh_setup

        call_ :ugg, :shoestring_length, :abrufen

        @result.should eql :_was_not_known_

        @_shoe.instance_variable_set :@shoestring_length, :zizzy

        call_ :ugg, :shoestring_length, :abrufen

        @result.should eql [ :_was_known_huddaugh_, :zizzy ]
      end

      it "and check out this `set` that takes an invalid" do

        _init_fresh_setup

        future_expect_only :error, :expression, :nope do | s_a |
          [ "doesn't look like integer: \"98 degrees\"" ]
        end

        @_shoe._recv_etc( & fut_p )

        call_ :ugg, :shoestring_length, :stellen, :length, '98 degrees'

        @result.should eql false
      end

      it "and yes, yay, take valid" do

        _init_fresh_setup

        call_ :ugg, :shoestring_length, :stellen, :length, '98'

        @_shoe.instance_variable_get( :@shoestring_length ).should eql 98

        @result.should eql :_you_did_it_
      end

      def _init_fresh_setup  # who needs before blocks! make it explicit

        @_shoe = _shoe_model.new

        ds = new_dynamic_source_for_unbounds_

        ds.add :Shoe, @_shoe

        @kernel_ = build_kernel_from_seed_and_module_ ds, ACS_RT_3

        NIL_
      end

      attr_reader :kernel_

      shared_subject :_shoe_model do

        module ACS_RT_3

          ACS_ = Home_

          class Ugg_Shoe_with_Laces

            def initialize
              @_nf = Callback_::Name.via_variegated_symbol :ugg
              @_oes_p = nil
            end

            def _recv_etc & p
              @_oes_p = p
            end

            def build_unordered_index_stream & x_p

              RT__::Subject[]::Self_as_unbound_stream[ @_nf, self, & x_p ]
            end

            attr_reader :_did_run_

            def __looks_like_proc_but_no_operations__component_association

              @_did_run_ = true

              -> x do
                self._this_is_never_run_
              end
            end

            def __shoestring_length__component_association

              yield :can, :abrufen, :stellen   # (german for 'get' and 'set' MAYBE)

              -> st, & oes_p do

                x = st.gets_one

                via_integer = -> d do
                  # (more validation here .. etc)
                  ACS_::Value_Wrapper[ d ]
                end

                if x.respond_to? :bit_length
                  via_integer[ x ]
                else
                  md = /\A-?[0-9]+\z/.match x
                  if md
                    via_integer[ md[ 0 ].to_i ]
                  else
                    oes_p.call :error, :expression, :nope do | y |
                      y << "doesn't look like integer: #{ x.inspect }"
                    end
                    false
                  end
                end
              end
            end

            def __abrufen__primitivesque_component_operation_for qkn

              -> do

                if qkn.is_known_known
                  if qkn.is_effectively_known
                    [ :_was_known_huddaugh_, qkn.value_x ]
                  else
                    :_nilff_
                  end
                else
                  :_was_not_known_
                end
              end
            end

            def __stellen__primitivesque_component_operation_for qkn

              -> length do

                _vp = ACS_::Interpretation::Value_Popper[ length ]

                wv = qkn.association.component_model[ _vp, & @_oes_p ]
                if wv
                  instance_variable_set qkn.name.as_ivar, wv.value_x
                  :_you_did_it_
                else
                  wv
                end
              end
            end
          end

          Ugg_Shoe_with_Laces
        end
      end
    end

    module ACS_RT_3
      RT__ = TS_::Modalities::Reactive_Tree
    end
  end
end

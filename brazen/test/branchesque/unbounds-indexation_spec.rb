require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] branchesque - unbounds indexation - promotions" do

    extend TS_
    use :memoizer_methods

    context "full minimal example (scene 1)" do

      it "reach simple action at level 1" do

        _lookup :node_1_action
        _name_symbol.should eql :node_1_action
      end

      it "index level one and see total of three nodes" do

        _list
        _expect :node_1_action, :node_3_act_3, :node_2_which_is_module
      end

      it "index level 2 and see one node" do

        _list :node_2_which_is_module
        _expect :node_3_act_2
      end

      it "reach promoted action at level 1" do

        _lookup :node_3_act_3
        _name_symbol.should eql :node_3_act_3
      end

      it "reach normal deep action at level 2" do

        _lookup :node_2_which_is_module, :node_3_act_2
        _name_symbol.should eql :node_3_act_2
      end

      it "reach branch node at level 1" do

        _lookup :node_2_which_is_module
        _name_symbol.should eql :node_2_which_is_module
      end

      dangerous_memoize_ :_kernel do

        module BUI_App1

          module Models_

            class Node_1_Action < Home_::Action

            end

            module Node_2_which_is_Module

              module Actions

                class Node_3_Act_2 < Home_::Action

                end

                class Node_3_Act_3 < Home_::Action

                  @is_promoted = true
                end
              end
            end
          end
        end

        Home_::Kernel.new BUI_App1
      end
    end

    def _lookup * sym_a

      _lookup_via sym_a
    end

    def _name_symbol

      @_found_node.name_function.as_lowercase_with_underscores_symbol
    end

    def _list * sym_a

      _lookup_via sym_a
    end

    def _expect * sym_a

      st = @_found_node.build_unordered_selection_stream
      a = []
      begin
        unb = st.gets
        unb or break
        a.push unb.name_function.as_lowercase_with_underscores_symbol
        redo
      end while nil

      a.should eql sym_a
    end

    def _lookup_via sym_a

      unb = _kernel
      begin
        sym = sym_a.shift
        if ! sym
          break
        end

        st = unb.build_unordered_selection_stream

        begin
          unb_ = st.gets
          unb_ or break

          if sym == unb_.name_function.as_lowercase_with_underscores_symbol
            break
          end
          redo
        end while nil

        if unb_
          unb = unb_
          redo
        end
        fail "did not find: '#{ sym }' under [etc]"
      end while nil

      @_found_node = unb
      nil
    end
  end
end

require_relative 'test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] model-centric obperator branch" do

    TS_[ self ]
    use :memoizer_methods

    # the subject started life as a anything-goes attempt to make a classic
    # [br]-powered app ([sg]) work under [ze]. the thrust was to blah

    it "loads" do
      _subject_module || fail
    end

    context "hi" do

      it "builds" do
        _feature_branch || fail
      end

      it "to LT stream - loadable references know their name based on filename alone" do

        lt = _this_one_scanner_expect_one_item
        lt.name_symbol == :zib_flib || fail
      end

      it "make that call" do

        _rsx = _build_resources :inigo_montoya, :wahoo
        lt = _this_one_scanner_expect_one_item
        bc = lt.bound_call_of_operator_via_invocation_resouces _rsx
        _wat = bc.receiver.send bc.method_name, * bc.args, & bc.block
        _wat == [ :woohoo, :wahoo ] || fail
      end

      it "when failure strikes" do  # (used to lend coverage to [ze]. might still.)

        chan = nil ; msg_p = nil

        _rsx = _build_resources :not_nigo_montonya, :wahoo do |*a, &p|
          chan = a ; msg_p = p
        end

        lt = _this_one_scanner_expect_one_item

        _bc = lt.bound_call_of_operator_via_invocation_resouces _rsx

        _bc.nil? || fail

        chan == %i( error expression parse_error unknown_operator ) || fail

        # (at writing it worked (it splayed). let's avoid the dependency)

        #_expag = Zerk_lib_[]::No_deps[]::API_InterfaceExpressionAgent.instance

        #_wee = _expag.calculate [], & msg_p
      end

      def _this_one_scanner_expect_one_item
        scn = __this_one_scanner
        lref = scn.gets_one
        scn.no_unparsed_exists || fail  # or not
        lref
      end

      def __this_one_scanner
        Home_::Zerk_no_deps_[]  # while #open [#ze-068] unify scanners
        _hi = _feature_branch
        _hi.to_symbolish_reference_scanner
      end

      shared_subject :_feature_branch do

        _subject_module.define do |o|

          o.models_branch_module = X_mcob_PrentendModels

          o.add_actions_module_path_tail "zib-flib/zub-flub"

          o.filesystem = :_no_filesystem_used_in_this_test_PL_

          o.bound_call_when_operation_with_definition_by = -> oo do
            TS_._NEVER_CALLED
          end
        end
      end
    end

    # ==

    def _build_resources * x_a, & p

      _scn = Zerk_lib_[]::No_deps[]::API_ArgumentScanner.narrator_for x_a, & p

      X_mcob_Resources.new _scn
    end

    # ==

    module X_mcob_PrentendModels

      module Zib_Flib  # the classic dumb way, just to avoid fuzzy search

        module ZubFlub  # pretend it's `Actions`

          class Inigo_Montoya

            def initialize
              o = yield
              o.__HELLO_MY_OWN_RESOURCES__
              @__as = o.argument_scanner_narrator
            end

            def execute
              [ :woohoo, @__as.token_scanner.head_as_is ]
            end

            ZubFlub = nil  # new - say it has no sub-actions ..
          end

          # (because this doesn't define `dir_path`, it does not recurse)
        end
      end

      def self.dir_path
        "fake/dir/path"
      end
    end

    X_mcob_Resources = ::Struct.new :argument_scanner_narrator do
      def __HELLO_MY_OWN_RESOURCES__
        NIL
      end
    end

    context "full minimal example (scene 1)" do

      it "reach simple action at level 1" do

        _lookup :node_1_action
        expect( _name_symbol ).to eql :node_1_action
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
        expect( _name_symbol ).to eql :node_3_act_3
      end

      it "reach normal deep action at level 2" do

        _lookup :node_2_which_is_module, :node_3_act_2
        expect( _name_symbol ).to eql :node_3_act_2
      end

      it "reach branch node at level 1" do

        _lookup :node_2_which_is_module
        expect( _name_symbol ).to eql :node_2_which_is_module
      end

      dangerous_memoize :_kernel do

        module X_LEGACY_BR_FAKE_APP

          module Models_

            class Node_1_Action < BRAZEN[]::ActionToolkit

            end

            module Node_2_which_is_Module

              module Actions

                class Node_3_Act_2 < BRAZEN[]::ActionToolkit

                end

                class Node_3_Act_3 < BRAZEN[]::ActionToolkit

                  @is_promoted = true
                end
              end
            end
          end
        end

        BRAZEN[]::Kernel.new X_LEGACY_BR_FAKE_APP
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

      expect( a ).to eql sym_a
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

    # ==
    # ==

    def _subject_module
      Home_::ModelCentricFeatureBranch
    end

    # ==
    # ==
  end
end

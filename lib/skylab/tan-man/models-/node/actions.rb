module Skylab::TanMan

  class Models_::Node

    class << self

      def collections_controller_class
        Node_::Collections_Controller__
      end
    end

    Brazen_::Model_::Entity[ self, -> do

      o :persist_to, :node,

        :required,
        :ad_hoc_normalizer, -> * a do
          Node_::Controller__::Normalize_name[ self, a ]
        end,
        :property, :name

    end ]

    class << self

      remove_method :get_unbound_lower_action_scan

      alias_method :get_unbound_lower_action_scan, :orig_gulas

    end

    public :with

    O__ = Action_Factory.create_with self, Action_, Entity_

    module Actions

      Add = O__.make :Add

      class Add

        Model_::Entity[ self, -> do
          o :required, :property, :input_string,
            :required, :property, :output_string,

            :flag, :property, :ping

        end ]

        def produce_any_result
          produce_any_result_when_dependencies_are_met
        end

        attr_reader :ping

      private

        def produce_any_bound_call_while_processing_iambic x_a
          x = super
          x or ping && do_ping
        end

        def do_ping
          _ev = build_success_event_with :ping_from_action, :name_i,
             name.as_lowercase_with_underscores_symbol
          x = send_event _ev  # see #very-interesting
          Brazen_.bound_call -> { x }, :call
        end

      public

        def receive_model_parser_loading_info_event ev
          # receive_event ev  #dbg
        end
      end

      Ls = O__.make :List

      class Ls

        Model_::Entity[ self, -> do
          o :required, :property, :input_string
        end ]

        def produce_any_result
          produce_any_result_when_dependencies_are_met
        end
      end

      Rm = O__.make :Remove

    end

    class Collections_Controller__ < Model_::Document_Entity::Collections_Controller

    end

    Node_ = self
    STOP_ = false
  end

  if false

  class API::Actions::Graph::Node::Add < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :force, :name, :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        node = cnt.add_node name, dry_run, force, verbose,
          -> e do # error
            error e.to_h
          end,
          -> e do # success
            info e.to_h
          end
       if node
         res = cnt.write dry_run, force, verbose
       else
         res = false
       end
       res
      end while nil
      res
    end
  end

  class API::Actions::Graph::Node::List < API::Action

    extend API::Action::Parameter_Adapter

    PARAMS = [ :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        count = 0
        cnt.list_nodes verbose, -> node_stmt do
          count += 1
          payload "#{ lbl node_stmt.label }"
        end
        info "(#{ count } total)"
      end while nil
      res
    end
  end

  class API::Actions::Graph::Node::Rm < API::Action

    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :node_ref, :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        destroyed = cnt.rm_node node_ref,
          true, # always fuzzy for now
          -> e do
            error e.to_h
            res = false
          end,
          -> e do
            info e.to_h
            e # we gotta, it becomes `destroyed`
          end
        if destroyed
          res = cnt.write dry_run, true, verbose # always force here
        end
      end while nil
      res
    end
  end
  end
end

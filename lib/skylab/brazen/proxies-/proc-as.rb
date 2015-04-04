module Skylab::Brazen

  class Model_

    module Node_via_Proc

      # #todo - node via proc is covered elsewhere: [tm], [cu]

      class << self

        def produce_action_class_like p, const_sym, box_mod, parent_mod

          ActionClassLike__.new( p,
            "#{ box_mod.name }#{ CONST_SEP_ }#{ const_sym }",
            box_mod, parent_mod )
        end

        def produce_nodelike p, i, box_mod, model_class
          NodeLike__.new p, i, box_mod, model_class
        end
      end  # >>

      class NodeLike__

        def initialize p, i, mod, mc
          @name_s = "#{ mod.name }#{ CONST_SEP_ }#{ i }"
          @mc = mc
          @mod = mod
          @i = i
          @p = p
        end

        def name  # result is string only because we are emulating ::Module#name
          @name_s
        end

        def to_upper_unbound_action_stream
          Callback_::Stream.via_item ActionClassLike__.new( @p, @name_s, @mod, @mc )
        end
      end

      class ActionClassLike__

        include NAME.name_function_proprietor_methods

        def initialize p, name_s, box_mod, model_class
          @box_module = box_mod
          @model_class = model_class
          @name_s = name_s
          @p = p
        end

        def is_branch
          false
        end

        def is_actionable
          true
        end

        def is_promoted
          true  # meh
        end

        attr_reader :p, :box_module, :model_class

        def members
          [ :box_module, :model_class, :name_function ]
        end

        def name_function
          super
        end

        def name_function_class  # #hook-in
          Brazen_.model.action_class.name_function_class
        end

        def custom_action_inflection
          nil
        end

        def name
          @name_s
        end

        def new k , & oes_p
          Bound_Action_Like___.new k, self, & oes_p
        end

      private

        def some_name_stop_index
          @did_search_for_name_stop_index ||= search_for_name_stop_index
          @name_stop_index
        end

        def search_for_name_stop_index

          # assume the convention that somewhere there is an `Action_`
          # node "reference class" (probably base class) that has the
          # name stop index const.

          scn = LIB_.basic::List.line_stream(
            LIB_.module_lib.chain_via_module @box_module )

          # assume the convention that the current leaf of the chain is some
          # box module (either 'Actions' or 'Models_`), and the one above
          # that is either a model node or the application node.

          begin

            box_node = scn.rgets
            focus_node = scn.rgets

            focus_mod = focus_node.value_x

            if focus_mod.const_defined? :Action_
              reference_class = focus_mod::Action_
              break
            end

            if :Models_ == box_node.name_symbol
              break  # we always stop at this (perhaps local) top
            end

            redo
          end while nil

          if ! reference_class

            # if it wasn't found by there being an 'Action_' base class
            # defined somewhere, assume we are at the top and the focus
            # mod is the application class. to use procs in this way you
            # must define the following method.

            reference_class = focus_mod.action_class
          end

          @name_stop_index = reference_class::NAME_STOP_INDEX
          true
        end
      end

      class Bound_Action_Like___

        class << self
          def after_name_symbol
            # for now
          end

          def is_branch
            false
          end
        end

        def initialize k, action_class_like, & oes_p
          @action_class_like = action_class_like
          @kernel = k
          @on_event_selectively = oes_p
        end

        attr_reader :action_class_like, :kernel

        def members
          [ :action_class_like, :kernel, :maybe_receive_event ]
        end

        def is_visible
          true  # for now
        end

        def accept_parent_node_ _
        end

        def name
          @action_class_like.name_function
        end

        def has_description
          # for now
        end

        def formal_properties
          _parameter_box
        end

        def any_formal_property_via_symbol sym
          _parameter_box[ sym ]
        end

        def _parameter_box
          @pbx ||= bld_parameter_box
        end

        def bld_parameter_box

          params = @action_class_like.p.parameters

          params.pop  # because #here

          bx = Callback_::Stream::Mutable_Box_Like_Proxy.new [], {}
          params.each do | opt_req_rest, name_symbol |

            case opt_req_rest
            when :req
              argument_arity = :one
              parameter_arity = :one
            when :opt
              argument_arity = :one
              parameter_arity = :zero_or_one
            when :rest
              argument_arity = :zero_or_more
              parameter_arity = :zero_or_one # or not ..
            else
              raise ::NoMethodError, opt_req_rest
            end

            bx.add( name_symbol,

            Brazen_.model.entity::Entity_Property.new do

              @argument_arity = argument_arity
              @name = Callback_::Name.via_variegated_symbol name_symbol
              @parameter_arity = parameter_arity

            end )
          end
          bx
        end

        def bound_call_against_iambic_stream st  # #hook-out

          case 0 <=> @action_class_like.p.arity
          when -1 ; _bound_call_when_nonzero_arity_via_stream st
          when  0 ; bc_when_zero_arity
          when  1 ; __bound_call_when_glob st
          end
        end

        def __REDO_bc_when_zero_arity
          Brazen_.bound_call nil, @action_class_like.p, :call
        end

        def __bound_call_when_glob st

          # currently this gets its coverage by ( [ts], [gv] ) ping

          _bound_call_when_nonzero_arity_via_stream st
        end

        def _bound_call_when_nonzero_arity_via_stream st

          param_a = @action_class_like.p.parameters
          param_a[ -1, 1 ] = EMPTY_A_  # always 1 arg for the call used #here

          h = __hash_via_flushing_probably_iambic_stream st

          arglist = []
          miss_sym_a = nil
          param_a.each do | orr, name_sym |

            x = h.delete name_sym

            if :req == orr && x.nil?
              miss_sym_a ||= []
              miss_sym_a.push name_sym
            else
              arglist.push x
            end
          end

          if h.length.nonzero?
            extra_sym_a = h.keys
          end

          if extra_sym_a
            __bc_when_extra extra_sym_a
          elsif miss_sym_a
            __bc_when_miss miss_sym_a
          else
            bc_when_OK arglist
          end
        end

        def __hash_via_flushing_probably_iambic_stream st

          h = {}
          while st.unparsed_exists
            h[ st.gets_one ] = if st.unparsed_exists
              st.gets_one
            end
          end
          h
        end

        def __bc_when_extra extra_sym_a
          _x = maybe_send_event :error do
            __build_when_extra_arguments_event extra_sym_a
          end
          Brazen_.bound_call.via_value _x
        end

        def __build_when_extra_arguments_event extra_sym_a
          _sign_event Brazen_::Entity.properties_stack.
            build_extra_properties_event extra_sym_a, nil, 'argument', 'unexpected'
        end

        def __bc_when_miss miss_sym_a
          _x = maybe_send_event :error do
            __build_missing_arguments_event miss_sym_a
          end
          Brazen_.bound_call.via_value _x
        end

        def __build_missing_arguments_event miss_sym_a
          _sign_event Brazen_::Entity.properties_stack.
            build_missing_required_properties_event miss_sym_a, 'argument'
        end

        def bc_when_OK mutable_arglist

          mutable_arglist.push self  # :+#here is one place where we add the xtra arg

          Brazen_.bound_call mutable_arglist, @action_class_like.p, :call
        end

        def bc_when_custom_error err
          @custom_error = err
          send :"bc_when_#{ err.terminal_channel_i }_arguments"
        end






        private def maybe_send_event * i_a, & ev_p
          @on_event_selectively[ * i_a, & ev_p ]
        end

        def maybe_receive_event * i_a, & ev_p
          @on_event_selectively[ * i_a, & ev_p ]
        end



        def _sign_event ev
          _nf = @action_class_like.name_function
          Brazen_.event.wrap.signature _nf, ev
        end
      end
    end
  end
end

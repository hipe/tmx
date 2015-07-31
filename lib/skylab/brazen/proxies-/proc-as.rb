module Skylab::Brazen

    module Proxies_::Proc_As  # see [#083]

      # :+#by:tm, cu, sg

      class Unbound_Action

        def initialize p, const_sym, box_mod, model_cls

          @box_module = box_mod
          @model_class = model_cls
          @name_s = "#{ box_mod.name }#{ CONST_SEP_ }#{ const_sym }"
          @p = p
        end

        def members
          [ :box_module, :model_class, :name_function ]
        end

        def is_branch
          false
        end

        def is_actionable
          true
        end

        def is_promoted
          false  # :+[#065] procs are always not promoted
        end

        attr_reader :p, :box_module, :model_class

        def name_function
          @___nf ||= Concerns_::Name::Build_name_function[ self ]
        end

        def name
          @name_s
        end

        def name_function_class  # #hook-in

          Home_::Model.common_action_class.name_function_class
        end

        def custom_action_inflection
          NIL_
        end

        def to_upper_unbound_action_stream

          Callback_::Stream.via_item self
        end

        def new k, & oes_p

          @cx ||= Signature_Classifications___.new( @p )

          As_Bound_Action___.new @cx, k, self, & oes_p
        end
      end

      class Signature_Classifications___

        def initialize p

          a_a = p.parameters

          @accepts_block = false
          @accepts_support_argument = false

          if a_a.length.nonzero?

            if :block == a_a.last.first
              @accepts_block = true
              a_a.pop
            end

            if a_a.length.nonzero?
              send :"__#{ a_a.last.first }__", a_a
            end
          end

          @business_parameters = a_a.freeze
        end

        attr_reader :accepts_block, :accepts_support_argument,
          :business_parameters

        def members
          self.class.instance_methods false
        end

        def __req__ a_a
          a_a.pop
          @accepts_support_argument = true
          NIL_
        end
      end

      class As_Bound_Action___

        def initialize cx, k, action_class_like, & oes_p

          @action_class_like = action_class_like
          @kernel = k
          @on_event_selectively = oes_p
          @signature_classifications = cx
        end

        attr_reader :action_class_like, :kernel, :on_event_selectively

        def accept_parent_node_ _
        end

        def name
          @action_class_like.name_function
        end

        def formal_properties
          _parameter_box
        end

        def _parameter_box
          @pbx ||= __build_parameter_box
        end

        def __build_parameter_box

          bx = Callback_::Stream::Mutable_Box_Like_Proxy.new [], {}

          @signature_classifications.
              business_parameters.each do | opt_req_rest, name_symbol |

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

            Home_::Model.common_entity_module::Property.new do

              @argument_arity = argument_arity
              @name = Callback_::Name.via_variegated_symbol name_symbol
              @parameter_arity = parameter_arity

            end )
          end

          bx
        end

        def bound_call_against_polymorphic_stream st  # #hook-out

          arglist = []

          h = __hash_via_flushing_probably_polymorphic_stream st

          miss_prp_a = nil

          @signature_classifications.business_parameters.each do | orr, name_sym |

            x = h.delete name_sym

            if :req == orr && x.nil?

              _prp = Home_.lib_.basic::Minimal_Property.
                via_variegated_symbol name_sym

              miss_prp_a ||= []
              miss_prp_a.push _prp
            else
              arglist.push x
            end
          end

          if h.length.nonzero?
            extra_sym_a = h.keys
          end

          if extra_sym_a

            __bc_when_extra extra_sym_a

          elsif miss_prp_a

            __bc_when_miss miss_prp_a
          else

            __bc_via_arglist arglist
          end
        end

        def __hash_via_flushing_probably_polymorphic_stream st

          h = {}
          while st.unparsed_exists
            h[ st.gets_one ] = if st.unparsed_exists
              st.gets_one
            end
          end
          h
        end

        def __bc_when_extra extra_sym_a

          _x = _maybe_send_event :error do
            __build_when_extra_arguments_event extra_sym_a
          end

          Callback_::Bound_Call.via_value _x
        end

        def __build_when_extra_arguments_event extra_sym_a

          _sign_event Home_::Property.
            build_extra_values_event extra_sym_a, nil, 'argument', 'unexpected'
        end

        def __bc_when_miss miss_prp_a

          _x = _maybe_send_event :error do
            __build_missing_arguments_event miss_prp_a
          end

          Callback_::Bound_Call.via_value _x
        end

        def __build_missing_arguments_event miss_prp_a

          _sign_event Home_::Property.
            build_missing_required_properties_event miss_prp_a, 'argument'
        end

        def __bc_via_arglist arglist

          cx = @signature_classifications

          if cx.accepts_support_argument

            arglist.push self  # #mechanic-1
          end

          if cx.accepts_block

            p = @on_event_selectively
          end

          Callback_::Bound_Call.new arglist, @action_class_like.p, :call, & p
        end

        def _maybe_send_event * i_a, & ev_p

          @on_event_selectively[ * i_a, & ev_p ]
        end

        def _sign_event ev
          _nf = @action_class_like.name_function
          Callback_::Event.wrap.signature _nf, ev
        end

        def after_name_symbol
          NIL_
        end

        def has_description
          NIL_  # for now
        end

        def is_branch
          false  # :+ procs are never branches
        end

        def is_visible
          true  # for now
        end
      end
    end

end

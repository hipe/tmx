module Skylab::Basic

  module Function::As  # see [#052]

    # -> ; (covered here, also :+#by:ta, cu, sg)

      Brazen_ = ::Skylab::Brazen  # assumed

      class Unbound

        include Brazen_.actionesque_defaults::Unbound_Methods

        def initialize p, const_sym, source, parent_unbound

          @name_s = "#{ source.name }#{ CONST_SEP_ }#{ const_sym }"
          @_p = p
          @_parent_unbound = parent_unbound
        end

        def silo_module
          pu = @_parent_unbound
          if pu
            pu.silo_module
          end
        end

        def build_unordered_index_stream & _

          Common_::Stream.via_item self
        end

        def name_function
          @___nf ||= Brazen_::Actionesque::Name::Build_name_function[ self ]
        end

        def name
          @name_s
        end

        def new k, & oes_p

          @__cx ||= Signature_Classifications___.new( @_p )

          As_Bound_Action___.new @__cx, k, self, & oes_p
        end

        attr_reader(
          :_p,
        )
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

        include Brazen_.actionesque_defaults::Bound_Methods

        def initialize cx, k, unbound, & oes_p

          @kernel = k
          @on_event_selectively = oes_p
          @signature_classifications = cx
          @unbound = unbound
        end

        attr_reader :unbound, :on_event_selectively

        def accept_parent_node _
        end

        def name
          @unbound.name_function
        end

        def formal_properties
          _parameter_box
        end

        def _parameter_box
          @pbx ||= __build_parameter_box
        end

        def __build_parameter_box

          bx = Common_::Stream::As_Mutable_Box.new [], {}

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

            _prp = ::Skylab::Brazen::Modelesque::Entity::Property.new_by do

              @argument_arity = argument_arity
              @name = Common_::Name.via_variegated_symbol name_symbol
              @parameter_arity = parameter_arity
            end

            bx.add name_symbol, _prp
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

              _prp = Home_::Minimal_Property.
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

          _maybe_send_event :error do
            __build_when_extra_arguments_event extra_sym_a
          end

          UNABLE_  # the result of the above is unreliable  # #here
        end

        def __build_when_extra_arguments_event extra_sym_a

          _ev = Home_.lib_.fields::Events::Extra.
            new_via extra_sym_a, nil, 'argument', 'unexpected'

          _sign_event _ev
        end

        def __bc_when_miss miss_prp_a

          _maybe_send_event :error do
            __build_missing_arguments_event miss_prp_a
          end

          UNABLE_  # the result of the above is unreliable, same as #here
        end

        def __build_missing_arguments_event miss_prp_a

          _ev = Home_.lib_.fields::Events::Missing.via miss_prp_a, 'argument'

          _sign_event _ev
        end

        def __bc_via_arglist arglist

          cx = @signature_classifications

          if cx.accepts_support_argument

            arglist.push self  # #mechanic-1
          end

          if cx.accepts_block

            p = @on_event_selectively
          end

          Common_::Bound_Call[ arglist, @unbound._p, :call, & p ]
        end

        def _maybe_send_event * i_a, & ev_p

          @on_event_selectively[ * i_a, & ev_p ]
        end

        def _sign_event ev
          _nf = @unbound.name_function
          Common_::Event.wrap.signature _nf, ev
        end
      end
    # <-
  end
end

module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::Reactive_Tree  # notes in [#083]

      class Dynamic_Source_for_Unbounds  # [mt]

        def initialize
          @_bx = Callback_::Box.new
        end

        attr_writer(
          :fallback_module,
        )

        def add const, x
          @_bx.add const, x
        end

        def constants
          @_bx.get_names
        end

        def const_get const, inherit=true

          had = true
          x = @_bx.fetch const do
            had = false ; nil
          end

          if had
            x
          else
            @fallback_module.const_get const, inherit
          end
        end
      end

      Self_as_unbound_stream = -> nf, acs, & oes_p do  # t:1

        # don't promote yourself, just be yourself. for this to work from
        # a top model, we accept a name, not an association.

        _hy = Compound_as_Hybrid__.new nf, acs, & oes_p

        Callback_::Stream.via_item _hy
      end

      class Children_as_unbound_stream  # l:1 t:1

        # a true "top" has no parent ergo no name. hence the children
        # in our stream constitute the first level of elements for the app.

        class << self

          def _call acs, & x_p
            x_p or self._WHERE
            o = new( & x_p )
            o.ACS = acs
            o.execute
          end

          alias_method :[], :_call
          alias_method :call, :_call
        end  # >>

        def initialize & oes_p
          @stream_for_interface = nil
          @_oes_p = oes_p
        end

        attr_writer(
          :ACS,
          :stream_for_interface,
        )

        def execute

          @__read_component_value = ___component_value_reader

          _st = ___to_stream_for_component_interface

          # because the above is reduced to only component associations of
          # interface intent and operations, we need not reduce it further

          qkn = nil
          h = {

            association: -> do
              if qkn.is_effectively_known
                __unbound_for_association_with_knownish_value qkn
              else
                __unbound_for_association_with_unknownish_value qkn
              end
            end,

            operation: -> do
              # (operations are only ever for the interface intent)
              Operation_as_Hybrid___.new qkn, @ACS
            end
          }

          _st.map_by do | qkn_ |
            qkn = qkn_
            h.fetch( qkn.association.category ).call
          end
        end

        def ___to_stream_for_component_interface

          if @stream_for_interface
            @stream_for_interface
          else
            ACS_::For_Interface::To_stream[ @ACS ]
          end
        end

        def __unbound_for_association_with_unknownish_value qkn

          asc = qkn.association

          cmp = @__read_component_value[ asc ]

          # the component that was created above is typically bound to parent
          # through the "special" handler that routes "signals", but for the
          # below hybrid we only want the ordinary, unmodified handler

          if cmp
            Compound_as_Hybrid__.new asc.name, cmp, & @_oes_p
          else
            # if the model declined to build an empty component, then it
            # doesn't want to for whatever reason. reduce over it.
            cmp
          end
        end

        def ___component_value_reader

          if @ACS.respond_to? READER_METHOD__

            @ACS.send READER_METHOD__, & @_oes_p

          else

            -> asc do

              # :+#suspect - do we want touch or Read_or_write ?

              ACS_::For_Interface::Touch[ asc, @ACS, & @_oes_p ]
            end
          end
        end

        def __unbound_for_association_with_knownish_value qkn

          Compound_as_Hybrid__.new qkn.name, qkn.value_x, & @_oes_p
        end
      end

      READER_METHOD__ = :component_value_reader_for_reactive_tree

      class Hybrid__  # see "what is a hybrid?" (#note-RT-A)

        def accept_parent_node _

          # it is the adapter that wraps the parent node - we don't need it

          NIL_
        end
      end

      class Compound_as_Hybrid__ < Hybrid__

        defaults = Home_.branchesque_defaults

        def initialize nf, acs, & oes_p

          # it might be the top node so we can't assume association.

          @_acs = acs
          @_nf = nf
          @_oes_p = oes_p
        end

        # ~ as unbound

        include defaults::Unbound_Methods

        def name_function
          @_nf
        end

        def new k, & _same

          @kernel = k
          self
        end

        # ~ as bound

        include defaults::Bound_Methods

        # ~ desc & name

        def has_description
          @_acs.respond_to? :describe_into_under
        end

        def under_expression_agent_get_N_desc_lines expag, n=nil

          if n
            __N_description_lines n, expag
          else
            @_acs.describe_into_under [], expag
          end
        end

        def __N_description_lines n, expag

          o = Callback_::Event::N_Lines.session
          acs = @_acs
          o.describe_by do | y |
            acs.describe_into_under y, expag
          end
          o.downstream_yielder = []
          o.expression_agent = Home_::API.the_empty_expression_agent
          o.num_lines = n
          o.execute
        end

        # ~ op

        alias_method :name, :name_function

        # ~

        def to_unordered_selection_stream

          Children_as_unbound_stream[ @_acs, & @_oes_p ]
        end
      end

      class Operation_as_Hybrid___ < Hybrid__

        defaults = Home_.actionesque_defaults

        def initialize op, acs

          @_acs = acs
          @_op = op
        end

        # ~ as unbound

        include defaults::Unbound_Methods

        def name_function
          @_op.name
        end

        # ~ as bound

        include defaults::Bound_Methods

        def new _k, & _note_RT_B
          self
        end

        alias_method :name, :name_function

        # ~ desc

        def has_description
          @_desc_p = @_op.description_block
          ! @_desc_p.nil?
        end

        def under_expression_agent_get_N_desc_lines expag, n=nil

          if n
            __N_description_lines n, expag
          else
            expag.calculate [], & @_desc_p
          end
        end

        def __N_description_lines n, expag

          o = Callback_::Event::N_Lines.session

          o.describe_by( & @_desc_p )
          o.downstream_yielder = []
          o.expression_agent = expag
          o.num_lines = n

          o.execute
        end

        # ~ execution

        def bound_call_against_polymorphic_stream st

          o = ACS_::Operation::Preparation::Session.new

          o.arg_st = st
          o.operation = @_op

          o.process_named_arguments or self._SANITY   # all errors must raise

          Callback_::Bound_Call.new(
            o.args,
            @_op.callable,
            :call,
          )  # see #note-OPER-A for why no blocks
        end

        # ~ parameters

        def formal_properties
          @_op.formal_properties
        end

        # ~ boring, maybe go up,

        def silo_module  # will maybe go up to anc.
          NIL_
        end
      end
    end
  end
end

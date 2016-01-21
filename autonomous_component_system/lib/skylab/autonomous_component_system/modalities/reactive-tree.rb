module Skylab::Autonomous_Component_System
  # ->
    module Modalities::Reactive_Tree  # notes in [#003]

      self._REACITVE_TREE_IS_OFF_till_phase_1

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

              Operation_as_Hybrid___.new qkn, @ACS, & @_oes_p
            end
          }

          @__read_component_value = __build_read_component_value

          st = ___to_stream_for_component_interface

          # the above stram is reduced to only those component associations
          # of interface intent and operations, but we may need to reduce it
          # further per a comment #here.

          Callback_.stream do  # (hand-written map-reduce for clarity)

            begin

              qkn = st.gets
              qkn or break
              x = h.fetch( qkn.association.category ).call
              x and break

              # - #trueish-note: components here must be controller-like
              # so they must be true-ish so we *can* map-reduce here
              redo
            end while nil
            x
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

          cmp = @__read_component_value[ qkn ]

          # the component that was created above is typically bound to parent
          # through the "special" handler that routes "signals", but for the
          # below hybrid we only want the ordinary, unmodified handler

          if cmp
            Compound_as_Hybrid__.new qkn.association.name, cmp, & @_oes_p
          else
            # if the model declined to build an empty component, then it
            # doesn't want to for whatever reason. reduce over it. (:#here)
            cmp
          end
        end

        def __build_read_component_value

          if @ACS.respond_to? READER_METHOD__

            @ACS.send READER_METHOD__, & @_oes_p

          else

            -> qkn do

              ACS_::For_Interface::Touch[ qkn, @ACS ].value_x
            end
          end
        end

        def __unbound_for_association_with_knownish_value qkn

          Compound_as_Hybrid__.new qkn.name, qkn.value_x, & @_oes_p
        end
      end

      READER_METHOD__ = :component_value_reader_for_reactive_tree

      class Hybrid__  # see "what is a hybrid?" [#]hybrid

        def accept_parent_node _

          # it is the adapter that wraps the parent node - we don't need it

          NIL_
        end
      end

      class Compound_as_Hybrid__ < Hybrid__

        defaults = Home_.lib_.brazen.branchesque_defaults

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

        def description_proc

          # for CLI we want loud failure. violate ACS passivity

          acs = @_acs
          if acs.respond_to? :describe_into_under  # the hand-written-convenient form
            -> y do
              acs.describe_into_under y, self
            end
          else
            acs.description_proc
          end
        end

        alias_method :name, :name_function

        # ~

        def to_unordered_selection_stream

          Children_as_unbound_stream[ @_acs, & @_oes_p ]
        end
      end

      class Operation_as_Hybrid___ < Hybrid__

        defaults = Home_.lib_.brazen.actionesque_defaults

        def initialize op, acs, & oes_p

          @_acs = acs
          @_oes_p = oes_p
          @_op = op
        end

        # ~ as unbound

        include defaults::Unbound_Methods

        def description_proc
          @_op.description_proc
        end

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

        # ~ execution

        def bound_call_against_polymorphic_stream st

          o = ACS_::Operation::Preparation::Session.new

          o.arg_st = st
          o.operation = @_op

          o.process_named_arguments_ or self._SANITY   # all errors must raise

          Callback_::Bound_Call[
            o.args,
            @_op.callable,
            :call,
            & @_oes_p  # see [#006]#Event-models:choice
          ]
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
  # -
end

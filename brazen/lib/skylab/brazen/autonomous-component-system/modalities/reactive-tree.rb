module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::Reactive_Tree  # notes in [#083]

      class Dynamic_Source_for_Unbounds

        def initialize
          @_bx = Callback_::Box.new
        end

        def add const, x
          @_bx.add const, x
        end

        def constants
          @_bx.get_names
        end

        def const_get const, _inherit=true

          had = true
          x = @_bx.fetch const do
            had = false ; nil
          end

          if had
            x
          else
            self._COVER_ME
          end
        end
      end

      Build_unordered_index_stream = -> nf, acs, & oes_p do

        # don't promote yourself, just be yourself. for this to work from
        # a top model, we accept a name, not an association.

        _hy = Compound_as_Hybrid__.new nf, acs, & oes_p

        Callback_::Stream.via_item _hy
      end

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

        def name
          @_nf
        end

        def to_unordered_selection_stream

          ACS_::Reflection::To_node_stream[ @_acs ].map_by do | qkn |

            if :association == qkn.association.category

              if qkn.is_known_known

                self._WRITE_ME__unbound_for_association_with_known_value qkn
              else
                __unbound_for_association_with_unknown_value qkn
              end
            else
              Operation_as_Hybrid___.new qkn, @_acs
            end
          end
        end

        def __unbound_for_association_with_unknown_value qkn

          # this part is kind of nasty - create & join children like these
          # for now we assume class-like model but this could be granulated

          asc = qkn.association

          _cmp = ACS_::Interpretation::Build_empty_child_bound_to_parent[
            asc, @_acs, & @_oes_p ]

          # the below hybrid does not get the "special" handler

          Compound_as_Hybrid__.new asc.name, _cmp, & @_oes_p
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
      end
    end
  end
end

module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::Reactive_Tree  # notes in [#083]

      class Dynamic_Source_for_Unbounds

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
          def [] acs, & x_p
            new( acs, & x_p ).__to_stream
          end
          private :new
        end  # >>

        def initialize acs, & oes_p
          @_acs = acs
          @_oes_p = oes_p
        end

        def __to_stream

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
            asc, @_acs, & @_oes_p ]  # #todo - why do we not assign child?

          # the below hybrid does not get the "special" handler

          Compound_as_Hybrid__.new asc.name, _cmp, & @_oes_p
        end
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

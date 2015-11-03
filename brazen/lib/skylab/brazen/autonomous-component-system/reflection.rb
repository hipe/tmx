module Skylab::Brazen

  module Autonomous_Component_System

    module Reflection  # notes in [#083]

      To_qualified_knownness_stream = -> acs do  #  1

        _p = Qualified_knownness_builder_for__[ acs ]

        To_association_stream[ acs ].map_by( & _p )
      end

      To_association_stream = -> acs do  # 1

        cab = Component_Association.builder_for acs

        To_entry_stream__[ acs ].map_reduce_by do | entry |

          if entry.is_association
            cab.build_association_for entry.name_symbol
          end
        end
      end

      To_node_stream = -> acs do  # l1 u1

        h = {}

        h[ :association ] = -> x do

          assoc = Component_Association.builder_for acs

          build_qkn = Qualified_knownness_builder_for__[ acs ]

          p = -> sym do
            build_qkn[ assoc.build_association_for( sym )  ]
          end
          h[ :association ] = p
          p[ x ]
        end

        h[ :operation ] = -> x do

          build_op = ACS_::Operation.builder_for acs

          p = -> sym do
            build_op[ sym ]
          end
          h[ :operation ] = p
          p[ x ]
        end

        To_entry_stream__[ acs ].map_by do | entry |

          h.fetch( entry.category )[ entry.name_symbol ]
        end
      end

      Qualified_knownness_builder_for__ = -> acs do

        p = Wrapped_value_reader_for___[ acs ]

        -> asc do

          vw = p[ asc ]
          if vw
            had = true
            x = vw.value_x
          else
            had = false
          end

          Callback_::Qualified_Knownness.via_value_and_had_and_association(
            x, had, asc )
        end
      end

      To_entry_stream__ = -> acs do

        # for now, we don't cache the reflection on the below 2 methods which
        # leaves the door open for some extreme hacking of singleton classes.
        # see "why so serious?" in [#doc]:#note-REFL-A for more.

        if acs.respond_to? :to_component_symbol_stream

          assocs_defined = true
          something_defined = true

          cmp_sym_st = acs.to_component_symbol_stream
          if cmp_sym_st
            as_st = cmp_sym_st.map_by do | sym |
              Entry__.new sym, :association
            end
          end
        end

        if acs.respond_to? :to_component_operation_symbol_stream

          ops_defined = true
          something_defined = true

          op_sym_st = acs.to_component_operation_symbol_stream
          if op_sym_st
            op_st = op_sym_st.map_by do | sym |
              Entry__.new sym, :operation
            end
          end
        end

        mi = -> do
          x = Method_index_of_class[ acs.class ]
          mi = -> { x }
          x
        end

        if something_defined

          # if one, the other, or both had method definitions; then the
          # aggregate order will be in "categories" (in our hard-coded)
          # order instead of by method definition order.

          if ! assocs_defined
            as_st = mi[].to_any_nonzero_length_association_entry_stream
          end

          if ! ops_defined
            op_st = mi[].to_any_nonzero_length_operation_entry_stream
          end

          if op_st
            if as_st
              op_st.concat_by as_st
            else
              op_st
            end
          elsif as_st
            as_st
          else
            Callback_::Stream.the_empty_stream
          end
        else
          mi[].to_entry_stream
        end
      end

      Method_index_of_class = -> cls do  # 2

        cls.class_exec do

          @___ACS_method_index ||=
            Method_Index___.new( cls.instance_methods( false ) )
        end
      end

      class Method_Index___

        def initialize meth_a

          # the below cacheing rationale is explored at #note-REFL-B

          @_entry_stream = -> do

            cache = []
            st = Callback_::Stream.via_nonsparse_array meth_a

            Callback_.stream do

              begin

                meth = st.gets

                if meth
                  md = RX___.match meth
                  md or redo
                  x = Entry__.new(
                    md[ :name ].intern,
                    md[ :which ].intern,
                  )
                  cache.push x
                  break
                end

                # the end was reached.

                @_entry_stream = -> do
                  Callback_::Stream.via_nonsparse_array cache
                end

                break
              end while nil
              x
            end
          end

          @_indexed = false
        end

        def to_any_nonzero_length_association_entry_stream
          _to_nonzero :@_association_symbols, :association
        end

        def to_any_nonzero_length_operation_entry_stream
          _to_nonzero :@_operation_symbols, :operation
        end

        def _to_nonzero ivar, sym
          @_indexed || _index
          if instance_variable_get( ivar )
            to_entry_stream.reduce_by do | ent |
              sym == ent.category
            end
          end
        end

        def association_symbols
          @_indexed || _index
          @_association_symbols
        end

        def operation_symbols
          @_indexed || _index
          @_operation_symbols
        end

        def to_entry_stream
          @_entry_stream[]
        end

        def _index

          @_indexed = true

          entry = nil
          freeze_me = []
          h = {}

          o = -> ivar, which do
            instance_variable_set ivar, nil
            h[ which ] = -> do
              a = []
              freeze_me.push a
              instance_variable_set ivar, a
              p = -> do
                a.push entry.name_symbol
              end
              h[ which ] = p
              p[]
            end
          end

          o[ :@_association_symbols, :association ]
          o[ :@_operation_symbols, :operation ]

          st = @_entry_stream[]
          while entry = st.gets
            h.fetch( entry.category ).call
          end

          freeze_me.each( & :freeze )

          ACHIEVED_
        end

        RX___ = /\A__(?<name>.+)__component_(?<which>association|operation)\z/
      end

      class Entry__

        def initialize name_symbol, cat_sym
          @category = cat_sym
          @name_symbol = name_symbol
        end

        def is_association
          :association == @category  # etc
        end

        attr_reader(
          :category,
          :name_symbol,
        )
      end

      # ~ encapsulate the fragile assumption about ivars

      Wrapped_value_for = -> asc, acs do  # 2

        ivar = asc.name.as_ivar
        if acs.instance_variable_defined? ivar
          Value_Wrapper[ acs.instance_variable_get( ivar ) ]
        end
      end

      Wrapped_value_reader_for___ = -> acs do

        -> asc do

          ivar = asc.name.as_ivar
          if acs.instance_variable_defined? ivar
            Value_Wrapper[ acs.instance_variable_get( ivar ) ]
          end
        end
      end

      # ~

      Model_is_compound = -> mdl do  # 2

        if mdl.respond_to? :method_defined?

          if mdl.method_defined? :to_component_symbol_stream
            true
          else
            ! Method_index_of_class[ mdl ].association_symbols.nil?
          end
        end
      end
    end
  end
end

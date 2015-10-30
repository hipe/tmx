module Skylab::Brazen

  module Autonomous_Component_System

    module Reflection  # notes in [#083]

      To_qualified_knownness_stream = -> acs do  #  1

        _p = Qualified_knownness_builder_for__[ acs ]

        To_association_stream[ acs ].map_by( & _p )
      end

      To_association_stream = -> acs do  # 1

        p = Component_Association.builder_for acs

        To_entry_stream__[ acs ].map_reduce_by do | entry |

          if entry.is_association
            p[ entry.name_symbol ]
          end
        end
      end

      To_node_stream = -> acs do  # 1

        h = {}

        h[ :association ] = -> x do

          build_asc = Component_Association.builder_for acs

          build_qkn = Qualified_knownness_builder_for__[ acs ]

          p = -> sym do
            build_qkn[ build_asc[ sym ] ]
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

        if acs.respond_to? :component_association_symbols

          assocs_defined = true
          something_defined = true

          assocs = acs.component_association_symbols
          if assocs
            as_st = Callback_::Stream.via_nonsparse_array assocs do | sym |
              Entry__.new sym, :@is_association
            end
          end
        end

        if acs.respond_to? :component_operation_symbols

          ops_defined = true
          something_defined = true

          ops = acs.component_operation_symbols
          if ops
            op_st = Callback_::Stream.via_nonsparse_array ops do | sym |
              Entry__.new sym, :@is_operation
            end
          end
        end

        mi = -> do
          x = Method_index_of_class__[ acs.class ]
          mi = -> { x }
          x
        end

        if something_defined

          # if one, the other, or both had method definitions; then the
          # aggregate order will be in "categories" (in our hard-coded)
          # order instead of by method definition order.

          if ! assocs_defined
            as_st = mi[].any_nonzero_length_operation_entry_stream
          end

          if ! ops_defined
            op_st = mi[].any_nonzero_length_association_entry_stream
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

      Method_index_of_class__ = -> cls do

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
        end

        def association_name_symbols
          @__did_index ||= __index
          @_association_name_symbols
        end

        def __index

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

          o[ :@_association_name_symbols, :association ]
          o[ :@_operation_name_symbols, :operation ]

          st = @_entry_stream[]
          while entry = st.gets
            h.fetch( entry.category ).call
          end

          freeze_me.each( & :freeze )

          ACHIEVED_
        end

        def to_entry_stream
          @_entry_stream[]
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

      Wrapped_value_for = -> asc, acs do  # 1

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

          if mdl.method_defined? :component_association_symbols
            true
          else
            ! Method_index_of_class__[ mdl ].association_name_symbols.nil?
          end
        end
      end
    end
  end
end

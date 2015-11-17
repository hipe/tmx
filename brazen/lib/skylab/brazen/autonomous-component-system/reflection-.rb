module Skylab::Brazen

  module Autonomous_Component_System

    module Reflection_  # notes in [#083]

      read_via_ivar = nil
      read_via_method = nil

      Reader = -> acs do

        if acs.respond_to? READ_METHOD__
          -> asc do
            read_via_method[ asc, acs ]
          end
        else
          -> asc do
            read_via_ivar[ asc, acs ]
          end
        end
      end

      Read = -> asc, acs do  # redunds with above

        if acs.respond_to? READ_METHOD__
          read_via_method[ asc, acs ]
        else
          read_via_ivar[ asc, acs ]
        end
      end

      read_via_method = -> asc, acs do

        wv = acs.send READ_METHOD__, asc
        if wv
          Callback_::Qualified_Knownness.via_value_and_association(
            wv.value_x,
            asc )
        else
          Callback_::Qualified_Knownness.via_association asc
        end
      end

      read_via_ivar = -> asc, acs do

        ivar = asc.name.as_ivar
        if acs.instance_variable_defined? ivar
          _x = acs.instance_variable_get ivar
          Callback_::Qualified_Knownness.via_value_and_association _x, asc
        else
          Callback_::Qualified_Knownness.via_association asc
        end
      end

      To_entry_stream = -> acs do

        # for now, we don't cache the reflection on the below 2 methods which
        # leaves the door open for some extreme hacking of singleton classes.
        # see [#]refl-A for more.

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
          # order instead of by method definition order. (more at [#]refl-B.)

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

      # ~ method index

      Method_index_of_class = -> cls do

        cls.class_exec do

          @___ACS_method_index ||=
            Method_Index___.new( cls.instance_methods( false ) )
        end
      end

      class Method_Index___

        def initialize meth_a

          # the below cacheing rationale is explained at [#]refl-C

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

      class Entry__  # entries are build by m.i and to entry stream

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

      READ_METHOD__ = :component_wrapped_value
    end
  end
end

module Skylab::Autonomous_Component_System

  class Method_Index___
    # 2 ->
        def initialize meth_a

          # see [#003]:"the moment at which we cache the entries"

          @_entry_stream = -> do

            cache = []
            st = Common_::Stream.via_nonsparse_array meth_a

            Common_.stream do

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
                  Common_::Stream.via_nonsparse_array cache
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
            to_entry_stream.reduce_by do |nt|
              sym == nt.node_reference_category
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
          while nt = st.gets
            h.fetch( nt.node_reference_category ).call
          end

          freeze_me.each( & :freeze )

          ACHIEVED_
        end

        RX___ = /\A__(?<name>.+)__component_(?<which>association|operation)\z/
        # 1 <-
      class Entry__  # entries are build by m.i and to entry stream

        def initialize name_symbol, cat_sym
          @entry_category = cat_sym
          @name_symbol = name_symbol
        end

        def is_association
          :association == @entry_category  # etc
        end

        attr_reader(
          :entry_category,
          :name_symbol,
        )
      end
    # 1 <-
  end
end

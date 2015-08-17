# encoding: UTF-8

module Skylab::Fields

  class Parameter

    class Bound

      PARAMETERS_METHOD = -> do  # typically `bound_parameters`

        @formal_parameters ||= self.class.parameters

        Models_::Collection.new self, @formal_parameters
      end

      Models_ = ::Module.new

      class Models_::Collection

        def initialize ent, foz

          @_entity = ent
          @_formal_parameters = foz
        end

        def at * sym_a

          foz = @_formal_parameters
          proto = _build_bound_prototype

          sym_a.map do | sym |

            proto.dup._init foz.fetch sym
          end
        end

        def fetch sym, & else_p

          if else_p
            no = nil
            prp = @_formal_parameters.fetch sym do
              no = true
            end
          else
            prp = @_formal_parameters.fetch sym
          end

          if no
            else_p[]
          else
            _build_bound_prototype._init prp
          end
        end

        def each
          st = to_value_stream
          begin
            bp = st.gets
            bp or break
            yield bp
            redo
          end while nil
        end

        def to_bound_item_stream  # like the next method, but flattens lists

          to_value_stream.expand_by do | bnd |  # mentor is in spec

            if bnd.parameter.is_list
              bnd.to_stream
            else
              Callback_::Stream.via_item bnd
            end
          end
        end

        def to_value_stream

          proto = _build_bound_prototype

          @_formal_parameters.to_value_stream.map_by do | prp |

            proto.dup._init prp
          end
        end

        def _build_bound_prototype
          Here_.new @_entity
        end
      end

      Here_ = self
      class Here_

        # ~ as bound parameter model

        attr_reader(
          :parameter,
        )

        def initialize ent
          @_ent = ent
        end

        # ~ special for (assume) list

        def to_stream

          a = value
          if a
            proto = Models_::For_Item.new a, @parameter

            Callback_::Stream.via_times a.length do | d |
              proto.dup.__init d
            end
          else
            Callback_::Stream.the_empty_stream
          end
        end

        # ~ normal

        def _init prp
          @parameter = prp
          self
        end

        def value
          @_ent.send :fetch, @parameter.name_symbol do
            NIL_
          end
        end

        def value= x
          @_ent.send @parameter.writer_method_name, x
          x
        end

        def name_symbol
          @parameter.name_symbol
        end

        def name
          @parameter.name
        end

        def is_item
          false
        end
      end

      class Models_::For_Item

        attr_reader :parameter

        def initialize a, para
          @_a = a
          @parameter = para
        end

        def __init d
          @_d = d
          self
        end

        def value
          @_a.fetch @_d
        end

        def value= x  # ..
          @_a[ @_d ] = x
        end

        def name_symbol
          @parameter.name_symbol
        end

        def name
          @parameter.name
        end

        def is_item
          true
        end
      end
    end
  end
end

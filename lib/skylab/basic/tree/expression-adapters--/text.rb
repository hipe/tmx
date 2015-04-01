module Skylab::Basic

  module Tree

    Expression_Adapters__ = ::Module.new

    module Expression_Adapters__::Text

      Actors = ::Module.new

      class Actors::Build_classified_stream

        Callback_::Actor.call self, :properties,

          :node,
          :glyphset_identifier_x

        def initialize
          @glyphset_identifier_x = DEFAULT_GLYPHSET_IDENTIFIER___
          super
        end

        DEFAULT_GLYPHSET_IDENTIFIER___ = :narrow

        def execute
          _ok = __resolve_glypshet
          _ok && __via_glyphset_produce_stream
        end

        def __resolve_glypshet

          @glyphset = Autoloader_.const_reduce(
            [ @glyphset_identifier_x ],
            Basic_.lib_.CLI_lib.tree.glyph_sets_module )

          @glyphset && begin
            __via_glyphset_init
            ACHIEVED_
          end
        end

        def __via_glyphset_init

          h = @glyphset
          @blank = h.fetch :blank
          @crook = h.fetch :crook
          @pipe = h.fetch :pipe
          @separator = h.fetch :separator
          @tee = h.fetch :tee
            # (yes, we used to, but viva readability & simplicity)
          NIL_
        end

        def __via_glyphset_produce_stream

          prefix_a = []

          @node.to_classified_stream.map_by do | cx |

            d = cx.depth

            if d.nonzero?

              shorter_d = d - 1

              if shorter_d < prefix_a.length
                prefix_a[ shorter_d .. -1 ] = EMPTY_A_
              end

              my_prefix = "#{ prefix_a * EMPTY_S_ }#{ cx.is_last ? @crook : @tee }"

              _future_prefix = cx.is_last ? @blank : @pipe

              prefix_a[ shorter_d ] = _future_prefix

            end

            Classifications___.new cx.node, my_prefix

          end
        end

        Classifications___ = ::Struct.new :node, :prefix_string
      end
    end
  end
end

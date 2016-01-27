module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class Ordered_path_stream_via_paths___ < Callback_::Actor::Monadic

        def initialize a
          @orig_paths = a
        end

        def execute

          # with [ba], turn the list of paths into an unordered tree.
          # then using visitor pattern visit every node of the tree, and
          # when that node is a branch, effectively descend into it and
          # mutate it (only at its level) reflecting the sort criteria.
          # then flatten this mutated tree back out into a stream of paths.

          tree = Home_.lib_.basic::Tree.via :paths, @orig_paths

          tree.accept do |node|  # as in visitor pattern
            if 1 < node.children_count
              Mutate___[ node ]
            end
            NIL_
          end

          tree.to_stream_of :paths, :do_branches, false
        end

        Mutate___ = -> node do

          pairs = node.to_pair_stream.to_a

          pairs.sort_by! do |pair|
            # back when it mattered: pair.value_x.has_children
            Comparer_for___[ pair ]
          end

          _new_order_ = pairs.map( & :name_x )

          node.a_.replace _new_order_

          NIL_
        end

        rx = /\A(?<digits>[0-9]+)?(?<rest>.*)\z/

        Comparer_for___ = -> pair do
          md = rx.match pair.name_x
          if md[ :digits ]
            Numbered_Comparer___.new md
          else
            Non_Numbered_Comparer___.new pair.name_x
          end
        end

        class Numbered_Comparer___

          def initialize md
            @_d = md[ :digits ].to_i
            # @_NOT_USED_s_for_compare = md[ :rest ]
          end

          def <=> otr
            if otr.has_digits
              d = @_d <=> otr._d
              if d.zero?
                self._FAIL_comparison_undefined_for_same_numbers
                # (easy enough to fix but the point is we don't want to)
              end
              d
            else
              -1  # I always come before others without digits
            end
          end

          def has_digits
            true
          end

          attr_reader :_d
          protected :_d
        end

        class Non_Numbered_Comparer___

          def initialize s
            @_s_for_compare = s
          end

          def <=> otr
            if otr.has_digits
              1  # then I always come after it
            else
              @_s_for_compare <=> otr._s_for_compare
            end
          end

          def has_digits
            false
          end

          attr_reader :_s_for_compare
          protected :_s_for_compare
        end
      end
    end
  end
end

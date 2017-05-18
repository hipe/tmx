module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class OrderedPathStream_via_Paths___ < Common_::Monadic

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
            # back when it mattered: pair.value.has_children
            Comparer_for___[ pair ]
          end

          _new_order_ = pairs.map( & :name_symbol )  # (strings actually)

          node.a_.replace _new_order_

          NIL_
        end

        rx = /\A
          (?<major_integer> \d+ )
          (?:  \. (?<sub_integers>  \d+ (?: \. \d+ )*  ) )?
          (?<rest>.*)
        \z/x

        Comparer_for___ = -> pair do

          # (kind of awful, we collaborate knowing that the keys are strings not symbols)
          md = rx.match pair.name_symbol
          if md
            Numbered_Comparer___.new md
          else
            Non_Numbered_Comparer___.new pair.name_symbol
          end
        end

        class Numbered_Comparer___

          def initialize md
            d_a = [ md[ :major_integer ].to_i ]
            s = md[ :sub_integers ]
            if s
              d_a.concat s.split( DOT_ ).map( & :to_i )
            end
            @_digits = d_a
            @_digits_depth = d_a.length
          end

          def <=> otr
            if otr.has_digits
              __do_number_comparision otr
            else
              -1  # I always come before others without digits
            end
          end

          def __do_number_comparision otr  # -1: you come first. 1: other does.

            digits = otr._digits
            digits_depth = otr._digits_depth

            depth_cmp = @_digits_depth <=> digits_depth
            _use_depth = case depth_cmp
            when -1
              @_digits_depth
            else
              digits_depth
            end

            cmp = 0
            _use_depth.times do |d|
              cmp_ = @_digits.fetch(d) <=> digits.fetch(d)
              cmp_.zero? && next
              cmp = cmp_
              break
            end

            if cmp.zero?
              if depth_cmp.zero?
                self._FAIL_comparison_undefined_for_same_numbers
              else
                depth_cmp
              end
            else
              cmp
            end
          end

          def has_digits
            true
          end

        protected
          attr_reader(
            :_digits,
            :_digits_depth,
          )
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

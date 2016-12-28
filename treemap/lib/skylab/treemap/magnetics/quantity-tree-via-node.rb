module Skylab::Treemap

  class Magnetics::QuantityTree_via_Node < Common_::Actor::Monadic

    # NOTE this node might go away, it adds very little.
    # but for now it's a stub for [#007.A] whitespace thing for [cm].

    # a quantity tree is derived quite directly from a node (tree).

    # the result tree is equivalent in structure to the input node (tree),
    # with one subject branch node being created to wrap every
    # corresponding branch node in the input tree. these subject branch
    # nodes merely add a `total` derivation for each branch:
    #
    # each terminal node of the argument tree must specify its
    # `main_quantity`.
    #
    # a branch node *may* specify a `main_quantity`, but if it does it
    # *must* be equal to or greater than the sum of its children's
    # quantities.
    #
    # if the node's declared totals is greater than the total of its
    # children, this is a thing (near whitespace).

    def initialize nt

      @main_quantity_method_name = :main_quantity
      @node_tree = nt
    end

    # -

      def execute

        m = @main_quantity_method_name

        recurse = -> node_that_is_branch do

          node_that_is_branch.has_children || self._SANITY  # #todo

          total = nil
          new_children = []

          st = node_that_is_branch.to_child_stream

          inc_total = -> num do
            total = num + total  # remote value can change local type
          end

          see_branch_normally = -> no do
            br = recurse[ no ]
            inc_total[ br.total ]
            br
          end

          see_terminal_normally = -> no do
            _num = no.send m
            inc_total[ _num ]
          end

          done_with_first = nil

          see_branch = -> no do
            br = recurse[ no ]
            total = br.total
            done_with_first[]
            br
          end

          see_terminal = -> no do
            total = no.send m
            done_with_first[]
          end

          done_with_first = -> do
            done_with_first = nil
            see_branch = see_branch_normally
            see_terminal = see_terminal_normally
          end

          begin
            no = st.gets
            no || break

            if no.has_children
              _bn = see_branch[ no ]
              new_children.push _bn
            else
              see_terminal[ no ]
              new_children.push no
            end

            redo
          end while above

          declared_total = node_that_is_branch.main_quantity
          if declared_total
            self._WHY_THO
            if total > declared_total
              self._COVER_ME__declared_total_is_less_than_derived_total__
            end
          end

          BranchNode___.new total, declared_total, new_children.freeze
        end

        recurse[ remove_instance_variable :@node_tree ]
      end
    # -

    # ==

    class BranchNode___

      def initialize num, num_, cx_a
        cx_a.length.zero? && self._SANITY  # #here
        @_children = cx_a  # frozen
        @children_count = cx_a.length
        @declared_total = num_
        @total = num
      end

      def first_child
        @_children.fetch 0
      end

      def to_child_stream
        Stream_[ @_children ]
      end

      def main_quantity
        @declared_total || @total  # ..
      end

      attr_reader(
        :children_count,
        :declared_total,
        :total,
      )

      def has_children  # #here
        true
      end

      def is_branch
        true
      end

      def IS_QUANTITY_TREE__  # temp sanity check
        true
      end
    end

    # ==
  end
end
# #born: for [cm] but hopefully more one day

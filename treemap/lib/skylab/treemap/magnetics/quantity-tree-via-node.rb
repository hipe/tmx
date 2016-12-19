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

        recurse = -> branch do

          total = nil
          new_children = []

          st = branch.to_child_stream

          see_terminal_normally = -> no do
            _num = no.send m
            total = _num + total  # remote value can change local type
          end

          see_terminal = -> no do
            total = no.send m
            see_terminal = see_terminal_normally
          end

          begin
            no = st.gets
            no || break

            if no.has_children
              ::Kernel._K
            else
              see_terminal[ no ]
              new_children.push no
            end

            redo
          end while above

          declared_total = branch.main_quantity
          if declared_total && total > declared_total
            self._COVER_ME__declared_total_is_less_than_derived_total__
          end

          BranchNode___.new total, declared_total, new_children.freeze
        end

        recurse[ remove_instance_variable :@node_tree ]
      end
    # -

    # ==

    class BranchNode___

      def initialize num, num_, cx_a
        @_children = cx_a  # frozen
        @child_count = cx_a.length
        @declared_total = num_
        @total = num
      end

      def first_child
        @_children.fetch 0
      end

      def to_child_stream
        Stream_[ @_children ]
      end

      attr_reader(
        :child_count,
        :declared_total,
        :total,
      )

      def has_children
        true
      end
    end

    # ==
  end
end
# #born: for [cm] but hopefully more one day

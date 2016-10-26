module Skylab::TMX

  class Magnetics_::GroupList_via_ItemList_and_Key_and_Options

    # (a popular way to sort)

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize a, k
        @key = k
        @node_array = a
      end

      attr_writer(
        :is_forwards,
      )

      def execute

        __init_a_list_of_groups_that_is_unsorted
        __sorty_the_dorty
      end

      def __sorty_the_dorty

        a = remove_instance_variable :@__unsorted_list_of_groups

        # exactly the use case for `sort_by`, by our measure - i.e, don't
        # do the below calculations multiple times on the same node.

        factory = @is_forwards ? Forwardsly___ : Reversely___

        a.sort_by do |group|
          factory[ group.name_x ]
        end
      end

      def __init_a_list_of_groups_that_is_unsorted

        # first, partition the array into a box of groups

        offset_via_value = {}
        groups = []

        key = @key
        @node_array.each do |node|

          x = node.box[ key ]

          d = offset_via_value.fetch x do

            d_ = groups.length
            groups.push Common_::Pair.via_value_and_name [], x  # note weird semantics
            offset_via_value[ x ] = d_
            d_
          end

          _group = groups.fetch d
          _group.value_x.push node
        end

        @__unsorted_list_of_groups = groups
        NIL
      end
    # -

    # ==

    Reversely___ = -> x do
      if x.nil?
        Reverse_when_unknown___[]
      else
        ReverseCommonly___.new x
      end
    end

    Forwardsly___ = -> x do
      if x.nil?
        Forwards_when_unknown___[]
      else
        ForwardsCommonly___.new x
      end
    end

    Forwards_when_unknown___ = Lazy_.call do
      class ForwardsWhenUnknown____ < Unknown__
        def <=> otr
          if otr.is_known
            -1
          else
            0
          end
        end
        self
      end.new
    end

    Reverse_when_unknown___ = Lazy_.call do
      class ReverseWhenUnknown___ < Unknown__
        def <=> otr
          if otr.is_known
            1
          else
            0
          end
        end
        self
      end.new
    end

    class Unknown__
      def is_known
        false
      end
    end

    class Known__

      def initialize x
        @value_x = x
      end

      attr_reader(
        :value_x,
      )

      def is_known
        true
      end
    end

    class ReverseCommonly___ < Known__
      def <=> otr
        if otr.is_known
          otr.value_x <=> @value_x
        else
          -1
        end
      end
    end

    class ForwardsCommonly___ < Known__
      def <=> otr
        if otr.is_known
          @value_x <=> otr.value_x
        else
          1
        end
      end
    end

    # ==
  end
end

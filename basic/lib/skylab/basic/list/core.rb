module Skylab::Basic

  module List  # :[#002].

    class << self

      # given a flat list of name-value pairs, produce an enumerator
      # that lets you `each_pair` over them:
      #
      #     _ea = Home_::List.build_each_pairable_via_even_iambic [ :a, :b, :c, :d ]
      #
      #     ::Hash[ _ea.each_pair.to_a ]  # => ( { a: :b, c: :d } )

      def build_each_pairable_via_even_iambic a
        Build_each_pairable_via_even_iambic__[ a ]
      end

      def classify actuals, symbols
        o = List_::Classifier.new
        o.actuals = actuals
        o.symbols = symbols
        o.execute
      end

      def index_of_deepest_common_element list_A_a, list_B_a

        deepest_index = nil

        [ list_A_a.length, list_B_a.length ].min.times do | d |

          if list_A_a.fetch( d ) == list_B_a.fetch( d )
            deepest_index = d
          else
            break
          end
        end

        deepest_index
      end

      def lowest_indexes_of_tail_anchored_common_element _A_a, _B_a

        _A_d = _A_a.length
        _B_d = _B_a.length

        stay = if _A_d < _B_d
          -> { _A_d.nonzero? }
        else
          -> { _B_d.nonzero? }
        end

        if stay[]
          begin
            _A_d_ = _A_d - 1
            _B_d_ = _B_d - 1

            if _A_a.fetch( _A_d_ ) == _B_a.fetch( _B_d_ )
              _A_d = _A_d_
              _B_d = _B_d_
              if stay[]
                redo
              end
            end
            x = [ _A_d, _B_d ]
            break
          end while nil
          x
        end
      end

      def pair_stream_via_even_iambic a
        Build_pair_stream_via_even_iambic__[ a ]
      end
    end  # >>

    class Linked

      class << self

        def via * x_a
          via_array x_a
        end

        def via_array a

          if a.length.nonzero?
            d = a.length - 1
            curr = nil
            begin
              curr = self[ curr, a.fetch( d ) ]
              if d.zero?
                break
              end
              d -= 1
              redo
            end while nil
            curr
          end
        end

        alias_method :[], :new
        private :new
      end  # >>

      def initialize next_LL, element_x
        @element_x = element_x
        @next = next_LL  # nil ok
      end

      def + x
        cls = self.class
        curr = cls[ nil, x ]
        stack = ___to_node_stack
        begin
          node = stack.pop
          node or break
          curr = cls[ curr, node.element_x ]
          redo
        end while nil
        curr
      end

      def ___to_node_stack
        a = [] ; curr = self
        begin
          a.push curr
          curr = curr.next
          curr or break
          redo
        end while nil
        a
      end

      def to_a
        a = []
        curr = self
        begin
          a.push curr.element_x
          curr = curr.next
          curr or break
          redo
        end while nil
        a
      end

      alias_method :to_array, :to_a  # if you want to be sure receiver is not nil

      def to_element_stream_assuming_nonsparse

        existent_linked_list = self

        p = -> do

          x = existent_linked_list.element_x

          next_linked_list = existent_linked_list.next
          if next_linked_list
            existent_linked_list = next_linked_list
          else
            p = EMPTY_P_
          end

          x
        end

        Common_.stream do
          p[]
        end
      end

      attr_reader(
        :element_x,
        :next,
      )
    end

    Build_each_pairable_via_even_iambic__ = -> a do
      _st = Build_pair_stream_via_even_iambic__[ a ]
      Common_::Stream::Magnetics::EachPairable_via_Stream[ _st ]
    end

    Build_pair_stream_via_even_iambic__ = -> a do

      Common_::Stream.via_times( a.length / 2 ).map_by do | d |
        d <<= 1
        Common_::Pair.via_value_and_name(
          a.fetch( d + 1 ),
          a.fetch( d ),
        )
      end
    end


    List_ = self
  end
end

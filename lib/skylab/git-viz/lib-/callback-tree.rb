module Skylab::GitViz

  module Lib_

    class Callback_Tree

      def initialize hash, identifier_x = self.class

        @identifier_x = identifier_x
        p = -> h do
          h.keys.each do |k|
            x = h[ k ]
            h[ k ] = case x
            when :handler
              Handler_Leaf__.new
            else
              p[ x ]
              Branch__.new x
            end
          end
        end
        p[ hash ]
        @root = Branch__.new hash
      end

      class Handler_Leaf__
        def initialize
          @p = nil
        end
        attr_accessor :p
        def type_i ; :handler end
        def to_handler_pair
          [ nil, @p ]
        end
      end

      class Branch__
        def initialize h
          @h = h ; @p = nil
        end
        attr_reader :h
        attr_accessor :p
        def to_handler_pair
          [ @h, @p ]
        end
      end

      Node__ = ::Struct.new :h, :p

      def set_handler * i_a, p
        node = ( 0 ... i_a.length ).reduce @root do |m, d|
          k = i_a.fetch d
          m.h.fetch k do
            raise ::KeyError, say_no_such_channel( d, i_a )
          end
        end
        node.p and raise ::KeyError, "won't clobber exiting '#{ i_a.last }'"
        node.p = p ; nil
      end

      def call_handler * i_a, & p
        exception = i_a.pop
        largest_d = last_seen_p = nil
        last = i_a.length
        ( 0 .. last ).reduce @root do |m, d|
          largest_d = d
          h_, p_ = m.to_handler_pair
          p_ and last_seen_p = p_
          h_ or break
          last == d and break
          k = i_a.fetch d
          _m_ = h_.fetch k do
            raise ::KeyError, say_no_such_channel( d, i_a )
          end
          _m_ or break
        end
        ( last_seen_p || p || ::Kernel.method( :raise ) )[ exception ]
      end

      def say_no_such_channel d, a
        bad_k = a.fetch d ; any_good_k_a = a[ 0, d ]
        node = any_good_k_a.reduce @root do |m, k|
          m.h.fetch k
        end
        trunk_s_a = any_good_k_a.map { |i| "#{ i }" }
        branch_s_a = node.h.keys.map { |i| "'#{ i }'" }
        article_adjective, verb, s = if 1 == branch_s_a.length
          [ 'the only ', 'is' ] else
          [ nil, 'are', 's' ] end
        _moniker = trunk_s_a.length.zero? ? 'root' : ( trunk_s_a * ' ' )
        "there is no '#{ bad_k }' channel #{
         }at the '#{ _moniker }' node. #{
          }#{ article_adjective }known channel#{ s } #{ verb } #{
           }#{ Oxford[ ', ', '[none]', ' and ', branch_s_a ] }#{
            } (for the #{ @identifier_x } callbacks)"
      end

      def glom other
        p = -> me, otr do
          p_ = otr.p and me.p = p_
          h = me.h ; h_ = otr.h
          h && h_ and h.each_pair do |i, me_|
            otr_ = h_[ i ]
            if otr_
              p[ me_, otr_ ]
            end
          end
        end
        p[ @root, other.root ] ; nil
      end
    protected
      attr_reader :root
    end
  end
end

module Skylab::MetaHell

  module Parse

    # like all others, this nonterminal parse function is an aggregation
    # composed of N other parse functions. it passes the input stream to
    # each constituent in order, stopping at any first one that succeeds
    # in parsing (the "winner").
    #
    # if a winner is found the resulting output node will contain a) any
    # output value produced by the function (some functions might ignore
    # this field) and b) the offset of the parse function in the grammar
    # (0 thru N-1 inclusive), expressed in the special output node field
    # `constituent_index`.
    #
    # so when a winner is found you have an ouput node with the index of
    # the constituent and its (any) output value. if no winner was found
    # the result of the `output_node_[..]` call is `nil`.
    #
    # allà packrat parsers, this parse is deterministic: there can be no
    # ambiguity because order matters; first match wins.
    #
    # this function is :+#empty-stream-safe.

    class Functions_::Alternation < Parse_::Function_::Currying

      def parse_

        in_st = @input_stream

        @function_a.each_with_index.reduce nil do | _, ( g, d ) |

          on = g.output_node_via_input_stream in_st

          if on

            break Parse_::Output_Node_.new_with on.value_x,
              :constituent_index, d

          end
        end
      end
    end
  end

  # minimally you can call it inine with (p_a, arg)
  #
  #     res = MetaHell_::Parse.alternation[ [
  #       -> ix { :a == ix and :A },
  #       -> ix { :b == ix and :B } ],
  #       :b ]
  #
  #     res  # => :B
  #

  # it may be more efficient to curry the parser in one place
  #
  #     P = MetaHell_::Parse.alternation.curry_with :pool_procs, [
  #       -> ix { :a == ix and :A },
  #       -> ix { :b == ix and :B } ]
  #
  #
  # and call it in another
  #
  #     P[ :a ]  # => :A
  #
  #
  # and another:
  #
  #     P[ :b ]  # => :B
  #     P[ :c ]  # => nil


  # in the minimal case, the empty parser always results in nil
  #
  #     p = MetaHell_::Parse.alternation.curry_with :pool_procs, []
  #
  #     p[ :bizzle ]  # => nil

  # maintaining parse state (artibrary extra arguments)
  #
  #     P_ = MetaHell_::Parse.alternation.curry_with :pool_procs, [
  #       -> output_x, input_x do
  #         if :one == input_x.first
  #           input_x.shift
  #           output_x[ :is_one ] = true
  #           true
  #         end
  #       end,
  #       -> output_x, input_x do
  #         if :two == input_x.first
  #           input_x.shift
  #           output_x[ :is_two ] = true
  #           true
  #         end
  #       end ]
  #
  #     Result = ::Struct.new :is_one, :is_two
  #
  #
  # it parses none:
  #
  #     P_[ Result.new, [ :will, :not, :parse ] ]  # => nil
  #
  #
  # it parses one:
  #
  #     r = Result.new
  #     P_[ r, [ :one ] ]  # => true
  #     r.is_one  # => true
  #     r.is_two  # => nil
  #
  #
  # it parses two:
  #
  #     r = Result.new
  #     P_[ r, [ :two ] ]  # => true
  #     r.is_one  # => nil
  #     r.is_two  # => true
  #
  #
  # but it won't parse two after one:
  #
  #     input_a = [ :one, :two ] ; r = Result.new
  #     P_[ r, input_a ]  # => true
  #     r.is_one  # => true
  #     r.is_two  # => nil
  #

end

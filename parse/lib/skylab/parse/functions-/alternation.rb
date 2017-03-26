module Skylab::Parse

  # ->

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
    # so when a winner is found you have an output node with the index of
    # the constituent and its (any) output value. if no winner was found
    # the result of the `output_node_[..]` call is `nil`.
    #
    # allà packrat parsers, this parse is deterministic: there can be no
    # ambiguity because order matters; first match wins.
    #
    # this function is :+#empty-stream-safe.

    class Functions_::Alternation < Home_::Function_::Currying

      def accept_function_ f
        maybe_send_sibling_sandbox_to_function_ f
        super
      end

      def parse_

        in_st = @input_stream

        @functions.each_with_index.reduce nil do | _, ( f, d ) |

          on = f.output_node_via_input_stream in_st

          if on

            break Home_::OutputNode.with on.value_x,
              :constituent_index, d

          end
        end
      end
    end
    # <-

begin  # :/

  # the output node reports the winning index. can be called inline.
  #
  #     on = Home_.function( :alternation ).with(
  #       :input_array, [ :b ],
  #       :functions,
  #         :trueish_single_value_mapper, -> x { :a == x and :A },
  #         :trueish_single_value_mapper, -> x { :b == x and :B } )
  #
  # the output node has the winning value:
  #
  #     on.value_x  # => :B
  #
  # the output node reports the index of the winning node:
  #
  #     on.constituent_index  # => 1
  #

  # you can curry the parser separately
  #
  #     p = Home_.function( :alternation ).with(
  #       :functions,
  #         :trueish_single_value_mapper, -> x { :a == x and :A },
  #         :trueish_single_value_mapper, -> x { :b == x and :B } ).
  #     method( :output_node_via_single_token_value )
  #
  # and call it in another
  #
  #     p[ :a ].value_x  # => :A
  #
  # and another:
  #
  #     p[ :b ].value_x  # => :B
  #     p[ :c ]  # => nil

  # in the minimal case, the empty parser always results in nil
  #
  #     g = Home_.function( :alternation ).with :functions
  #     g.output_node_via_single_token_value( :bizzie )  # => nil

  # maintaining parse state (artibrary extra arguments)
  #
  #     g = Home_.function( :alternation ).with(
  #       :functions,
  #         :trueish_single_value_mapper, -> x { :one == x and :is_one },
  #         :trueish_single_value_mapper, -> x { :two == x and :is_two } )
  #
  #     p = -> * x_a do
  #       g.output_node_via_input_array_fully x_a
  #     end
  #
  # it parses none:
  #
  #     p[ :will, :not, :parse ]  # => nil
  #
  # it parses one:
  #
  #     p[ :one ].value_x  # => :is_one
  #
  # it parses two:
  #
  #     p[ :two ].constituent_index  # => 1
  #
  # but it won't parse two after one:
  #
  #     p[ :one, :two ]  # => nil

end
end

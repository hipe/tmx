module Skylab::MetaHell

  module Parse

    # parse `input_x` using no more than one of the parsers from the ordered
    # pool `pool_a`, where 'parser' is defined as a function that takes two
    # parameters - `output_x` and `input_x` - and whose result's particular
    # true-ish-ness reflects whether or not the the parse/parser matched/
    # succeeded/was spent. the final result is nil if nothing matched,
    # otherwise the (true-ish) result of the parser/parse that matched (and
    # presumably parsed, and presumably wrote something to `input_x` if
    # desired). allà packrat parsers, parsing is deterministic (there is no
    # ambiguity) because order matters; first match wins.
    #
    # it is impossible for this function to result in false.
    #
    # this facility has absolutely no knowlege of the shape or behavior of
    # `input_x` and `output_x` - that is up to you and your functions. all
    # this function cares about on this end is the true-ish-ness of your
    # functions' result, at which point when found it short-circuits further
    # processing. in fact, forget we said anything about two parameters -
    # it's just `state_x_a`.

    Alternation__ = Parse::Curry_[
      :algorithm, -> parse, state_x_a do
        parse.get_pool_proc_a.reduce nil do |_, p|
          x = p[ * state_x_a ]
          break x if x
        end
      end,
      :uncurried_queue, [ :pool_procs, :state_x_a ],
      :call, -> parser_a, * state_x_a do
        absorb_along_curry_queue_and_execute parser_a, state_x_a
      end,
      :glob_extra_args ]
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

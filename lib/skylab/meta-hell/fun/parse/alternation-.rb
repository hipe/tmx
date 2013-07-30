module Skylab::MetaHell

  module FUN::Parse::Alternation_

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

    o = FUN_.o

    o[:parse_alternation] = FUN.parse_curry[
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

  # a normative example
  # like so:
  #
  #     res = MetaHell::FUN.parse_alternation[ [
  #       -> ix { :a == ix and :A },
  #       -> ix { :b == ix and :B } ],
  #       :b ]
  #
  #     res  # => :B
  #

  # it may be useful to curry your parser in one place
  # and then use it in another:
  #
  #     P = MetaHell::FUN.parse_alternation.curry[ :pool_procs, [
  #       -> ix { :a == ix and :A },
  #       -> ix { :b == ix and :B } ] ]
  #
  #     P[ :a ]  # => :A
  #
  # and another:
  #
  #     P[ :b ]  # => :B
  #     P[ :c ]  # => nil


  # the minimal case
  # the empty parser always result in nil
  #
  #     P = MetaHell::FUN.parse_alternation.curry[ :pool_procs, [] ]
  #
  #     P[ :bizzle ]  # => nil

  # maintaining parse state (artibrary extra arguments)
  # like so:
  #
  #     P = MetaHell::FUN.parse_alternation.curry[ :pool_procs, [
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
  #       end ] ]
  #
  #     Result = ::Struct.new :is_one, :is_two
  #
  #     P[ Result.new, [ :will, :not, :parse ] ]  # => nil
  #
  # it parses one:
  #
  #     r = Result.new
  #     P[ r, [ :one ] ]  # => true
  #     r.is_one  # => true
  #     r.is_two  # => nil
  #
  # it parses two:
  #
  #     r = Result.new
  #     P[ r, [ :two ] ]  # => true
  #     r.is_one  # => nil
  #     r.is_two  # => true
  #
  # but it won't parse two after one:
  #
  #     input_a = [ :one, :two ] ; r = Result.new
  #     P[ r, input_a ]  # => true
  #     r.is_one  # => true
  #     r.is_two  # => nil
  #

end

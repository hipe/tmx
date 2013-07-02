module Skylab::MetaHell

  module FUN::Parse::From_Set

    # more flexible, powerful and complex pool-based deterministic parsing
    #
    # each parsing node in `set_a` must respond to `[]` (e.g. `call` of a
    # ::Proc, which we will refer to as `parse` below), that results in
    # two arguments:
    #
    # the result of `parse` is assumed be a tuple of two boolean-ish values:
    # the first indicating whether anything was parsed, and the second
    # indicating whether the node was "spent" on that parse. whether or not
    # anything was parsed will be used to decide whether to continue the parse
    # after this pass. when a node reports that it is "spent" it is
    # effectively removed from the pool of nodes that will be used on
    # subsequent passes for the remainder of this parse.
    #
    # the parse is finished when either no node "parsed" during that pass,
    # or all nodes are "spent" (that is, there are no nodes left in the
    # running).
    #
    # this allows for nodes that parse by mutating the argv in undefined ways,
    # e.g possibly adding new elements or changing existing elements; rather
    # than just removing elements. Note too that this allows for the
    # possibility that any node could potentially make the parse loop forever,
    # if for e.g the node continually reports that it parsed the argv, and
    # that it is not spent. this is the liability that accompanies a power as
    # absolute as this.
    #
    # the *arguments* to `parse` are the reminder of whatever arguments you
    # pass to the entrypoint function. e.g typically they would be two
    # arguments, the first being a `memo` #output-argument, and the second
    # begin e.g `argv`.
    #
    # the result will be the the same two-element tuple with the same
    # semantics: the first indicating if anything was ever parsed (as reported
    # by the nodes) and the second indicating if *all* of the nodes were spent.
    # you are on your own to code the semantics of the parse itself into
    # your `memo` as an #output-argument.
    #
    # regardless of the input,
    # a parser with no nodes in it will always report 'no parse' and 'spent':
    #
    #     P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [ ] ]
    #
    #     P[ argv = [] ]  # => [ false, true ]
    #     argv # => []
    #
    # even if the input is rando calrissian:
    #
    #     P[ argv = :hi_mom ]  # => [ false, true ]
    #     argv  # => :hi_mom

    # with parser with one node that reports it always matches & always spends
    # it always reports the same as a final result:
    #
    #     P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [
    #      -> _input {  [ true, true ] }
    #     ]]
    #
    #     P[ :whatever ]  # => [ true, true ]

    # with a parser with one node that reports it never matches & always spends
    # it always reports the same as a final result:
    #
    #     P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [
    #       -> _input {  [ false, true ] }
    #     ]]
    #
    #     P[ :whatever ]  # => [ false, true ]

    # with a parser that parses any digits & any of 2 keywords (only once each):
    # it will do nothing to nothing:
    #
    #     keyword = -> kw do
    #       -> memo, argv do
    #         if argv.length.nonzero? and kw == argv.first
    #           argv.shift
    #           memo[ kw.intern ] = true
    #           [ true, true ]
    #         end
    #       end
    #     end
    #
    #     P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [
    #       keyword[ 'foo' ],
    #       keyword[ 'bar' ],
    #       -> memo, argv do
    #         if argv.length.nonzero? and /\A\d+\z/ =~ argv.first
    #           ( memo[:nums] ||= [ ] ) << argv.shift.to_i
    #           [ true, false ]
    #         end
    #       end
    #     ]]
    #
    #     P[ ( memo = { } ), [] ] # => [ false, false ]
    #     memo.length  # => 0
    #
    # parses one digit:
    #
    #     P[ ( memo = { } ), argv = [ '1' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :nums ]  # => [ 1 ]
    #
    # parses two digits:
    #
    #     P[ ( memo = { } ), argv = [ '2', '3' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :nums ]  # => [ 2, 3 ]
    #
    # parses one keyword:
    #
    #     P[ ( memo = { } ), argv = [ 'bar' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :bar ]  # => true
    #
    # parses two keywords:
    #
    #     P[ ( memo = { } ), argv = [ 'bar', 'foo' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :bar ]  # => true
    #     memo[ :foo ]  # => true
    #
    # will not parse multiple of same keyword:
    #
    #     P[ ( memo = { } ), argv = [ 'foo', 'foo' ] ]  # => [ true, false ]
    #     argv  # => [ 'foo' ]
    #     memo[ :foo ]  # => true
    #
    # will stop at first non-parsable:
    #
    #     argv = [ '1', 'foo', '2', 'biz', 'bar' ]
    #     P[ ( memo = { } ), argv ]  # => [ true, false ]
    #     argv  # => [ 'biz', 'bar' ]
    #     memo[ :nums ]  # => [ 1, 2 ]
    #     memo[ :foo  ]  # => true
    #     memo[ :bar  ]  # => nil

    o = FUN_.o

    o[:parse_from_set] = FUN.parse_curry[
      :algorithm, -> parse, input_x_a do
        did_parse_any = parsed_none_last_pass = false
        pool_a = parse.get_pool_proc_a
        while true
          if ( len = pool_a.length ).zero?
            did_spend_all = true
            break
          end
          parsed_none_last_pass and break
          spent_this_pass = parsed_this_pass = false
          len.times do |i|
            parsed, spent = pool_a.fetch( i )[ * input_x_a ]
            parsed and parsed_this_pass ||= true
            if spent
              spent_this_pass ||= true
              pool_a[ i ] = nil
            end
          end
          spent_this_pass and pool_a.compact!
          if parsed_this_pass
            did_parse_any ||= true
          else
            parsed_none_last_pass = true
          end
        end
        [ did_parse_any, did_spend_all || false ]
      end,
      :curry_queue, [ :argv ],
      :call, -> * input_x_a do
        absorb_along_curry_queue_and_execute input_x_a
      end
    ]
  end
end

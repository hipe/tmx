class Skylab::Task

  module Magnetics

    class Magnetics::Function_Stack_via_Collection_and_Parameters_and_Target  # currently 1x

      # this is the fifth implementation of [#005] pathfinding.

      # assume the target node is not solved. the end goal is to solve it.
      # there are two ways to solve for a node: the easy way and the fun way.
      # the easy way is that the node value is a given from the "start".
      # the "fun" way is by solving for a function that outputs that node.
      # if we succeed here, our result is a path (actually stack (that
      # represents a tree)) of function names that can be called in order:
      # the first function must be solved by what is given at the start, and
      # each next function is to be called assuming that the outputs of the
      # previous functions are now givens too.
      #
      # see [#005] "magnetic pipelines" about designing a well-formed acyclic
      # graph for your magnetic pipeline. for any given target and set of
      # (er) givens on a given pipeline, the outcomes that can occur fall
      # into (what we model as) three categories:
      #
      # one is that there's no path at all. this one is easy. there's nothing
      # you can do, folks. (helpful error structures is its own thing we
      # won't discuss here except to say that it is a thing.)
      #
      # another is that there is only one potential path (acutally tree) from
      # givens to target. this is nice and easy but it is not as fun as the
      # third category:
      #
      # there can be multiple different paths (or "solution trees") that
      # solve a given target given given givens. on the surface this may
      # seems like a useful novelty: like google maps we can offer the user
      # alternative routes to chose from. but in practice this is a non-
      # trivial design factor: because we use (necessarily, it would seem)
      # recursion to solve for targets, if we continually result in multiple
      # possible solution trees at each step then we have to take that
      # alternation into account when each next step solves for itself.
      #
      # this gets exponentionally out of hand if we don't make decisions
      # along the way to cull the tree. (see "contrived example" in the document.)

      class << self

        def call collection, given_x, target_x
          new._init( target_x, given_x, collection ).execute
        end
        alias_method :[], :call

        def begin_with collection, given_x, target_x
          new._init target_x, given_x, collection
        end

        private :new
      end  # >>

      def initialize
        @do_trace = nil
        @preferred_waypoint_node = nil  # just a sketch for now
      end

      def _init target_sym, given_sym_a, collection  # NOTE in volatility order
        @function_index = collection.function_index_
        @knownnesses = ::Hash[ given_sym_a.map { |i| [i, KNOWN_TO_BE_SOLVED__ ] } ]
        @target_symbol = target_sym
        @visiting = {}
        self
      end

      attr_writer(
        :do_trace,
        :preferred_waypoint_node,
      )

      def execute

        # this is the sole entrypoint from the outside. the first time you
        # can determine if this is a no-op is now:

        kn = @knownnesses[ @target_symbol ]
        if kn
          kn.is_solved || ::Kernel._SANITY
          [ SOLVED__, EMPTY_A_ ]
        else
          _common
        end
      end

      def _common

        # assume the solvability of the target node is unknown (but the fact
        # that the solvability is unknown is itself known.)

        # if there are no functions that produce the target node then it is a
        # "startpoint" node (see the document). that is, if we don't have it
        # then there is no way we can get it. ergo we now know that this node
        # is unsolvable.

        # otherwise (and there *are* functions that produce this node), what
        # we do depends on whether there's one function or more than one
        # function.

        # if there is exactly one function then we don't have to fork. we can
        # put all our existing resources (our "notespace") into trying to
        # solve only this function.

        # otherwise (and there's more than one function), see the called method.

        fit_a = @function_index.get_functions_that_produce_ @target_symbol
        if fit_a
          case 1 <=> fit_a.length
          when 0
            _solve_for_function_item_ticket fit_a.fetch 0
          when -1
            __branch_out_into_alternatives fit_a
          else
            never  # malformed function index
          end
        else
          @knownnesses[ @target_symbol ] = KNOWN_TO_BE_UNSOLVABLE__
          if @do_trace
            [ UNSOLVABLE__, [[ @target_symbol, :is_startpoint_but_is_not_a_given ]]]  # #here:result-tuple
          else
            UNSOLVABLE_RESULT_TUPLE__
          end
        end
      end

      def __branch_out_into_alternatives fit_a

        # we have multiple (i.e more than one) functions that formally output
        # the target node, but assume we don't yet know, of each of those
        # functions whether it is solved or unsolvable.
        #
        # to jump ahead for a moment, imagine we have tried solving each of
        # these functions. if we tried all of them and solved none (that is,
        # we determine that all of them are unsolvable) then that's easy, we
        # know that our target node is unsolvable and we're done.
        #
        # another easy case is that we solve only one function, this too is
        # easy - our solution should involve using that function.
        #
        # but the fun case is when we solve multiple functions. for now
        # we default to a sometimes wacky heuristic but this will be the
        # subject of API exposures as needed..
        #
        # this wacky heuristic requires that we try to solve for each
        # function from a "blank slate" - that is, don't assume that you
        # already solved those nodes of the graph under the other functions
        # when you try to solve for this one. there is a cost to this in
        # that we might solve the same branch nodes multiple times, but
        # a benefit too. this is a potential #optimization to be made, however
        #
        # there can only be one.

        do_trace = @do_trace
        failure_stacks = nil  # #here:debugging-feature
        solution_stacks = nil

        fit_a.each do |fit|
          _fork = __build_a_fork
          ok, x = _fork._solve_for_function_item_ticket fit
          if ok
            ( solution_stacks ||= [] ).push x
          elsif do_trace
            ( failure_stacks ||= [] ).push x
          end
        end

        if solution_stacks
          if 1 == solution_stacks.length
            [ SOLVED__, solution_stacks.fetch(0) ]
          else
            __attempt_tiebreak solution_stacks
          end
        elsif do_trace
          [ UNSOLVABLE__, [ :no_functions_solved, failure_stacks ] ]  # covered only by [hu]
        else
          UNSOLVABLE_RESULT_TUPLE__
        end
      end

      def __attempt_tiebreak solution_stacks
        sym = @preferred_waypoint_node
        if sym
          __attempt_tiebreak_via_preferred_waypoint_node sym, solution_stacks
        else
          _attempt_tiebreak_by_chosing_tallest_stack solution_stacks
        end
      end

      def __attempt_tiebreak_via_preferred_waypoint_node sym, solution_stacks

        # if we like this it may have to get a more articulated API..

        d_a = nil
        read = @function_index.proc_for_read_function_item_ticket_via_const_
        solution_stacks.each_with_index do |stack, d|
          stack.each do |function_sym|
            if read[ function_sym ].prerequisite_term_symbols.include? sym
              ( d_a ||= [] ).push d
              next
            end
          end
        end
        if d_a
          if 1 == d_a.length
            [ SOLVED__, solution_stacks.fetch( d_a.fetch 0 ) ]
          else
            self._COVER_ME_tiebreak_the_shorter_stack_list
          end
        else
          self._COVER_ME_fall_thru_to_ordinary_tie
        end
      end

      def _attempt_tiebreak_by_chosing_tallest_stack solution_stacks

        # when faced with multiple solution stacks, our wacky default
        # behavior is to chose the longest stack (if there is one).
        #
        # here's the rationale behind this wacky default tiebreaking behavior:
        #
        # taller stacks typically traverse (solve) more nodes than shorter
        # stacks. typically this means that taller stacks tend to take more
        # of the given arguments into account than the shorter stacks.
        #
        # typically, those stacks that take into account more givens have
        # behavior that is more custom-suited to those particular arguments.
        # so for these purposes, it is not shortest path we are after but the
        # longest. all of this may change.
        #
        # if the longest length of stack has multiple stacks that are this
        # length, then there's nothing you can do, folks (for now).

        max = 0
        by_number_of_steps = ::Hash.new { |h, k| x = [] ; h[k] = x ; x }
        solution_stacks.each do |stack|
          d = stack.length
          if max < d
            max = d
          end
          by_number_of_steps[ d ].push stack
        end

        winners = by_number_of_steps.fetch max  # LOOK
        if 1 == winners.length
          [ SOLVED__, winners.fetch(0) ]
        else
          self._NOW_you_need_an_external_tiebreaker  # (sweep this under the rug for now)
        end
      end

      def _solve_for_function_item_ticket fit

        # assume this is the only alternative we are investigating -
        # we can mutate the notespace toward this end.

        # all we care about is "can we solve this function?" and if so
        # what is the single path (solution tree) to solve it?

        # all functions have at least one argument (see document).

        # because every argument (node) is required, if we fail to solve
        # for one we know we will fail to solve the whole function. just
        # short-circuit to reduce search time (at cost of error message
        # detail.)

        do_trace = @do_trace
        known_to_be_unsolvable = false
        metadata_about_unsolvability = nil
        pending_call_stacks = nil

        fit.prerequisite_term_symbols.each do |sym|

          kn = @knownnesses[ sym ]
          if kn
            if kn.is_solved
              next
            end
            known_to_be_unsolvable = true
            break
          end

          # now we know that we don't know the solvability of this node.

          # (this must be the only place that we need to check/write this.
          #  we do this check right before we recurse into an argument.)

          if @visiting[ sym ]
            self._CYCLE  # #todo eventually cover this
          end
          @visiting[ sym ] = true

          ok, x = __recurse_into_argument sym

          if ! ok
            known_to_be_unsolvable = true
            if do_trace
              x.push [ @target_symbol, :via_function, fit.const, :has_argument_that_is_unsolvable, sym ]
              metadata_about_unsolvability = x
            end
            break
          end

          ( pending_call_stacks ||= [] ).push x
        end

        if known_to_be_unsolvable
          if do_trace
            [ UNSOLVABLE__, metadata_about_unsolvability ]  # #here:result-tuple
          else
            UNSOLVABLE_RESULT_TUPLE__
          end
        else
          mutable_path_stack = [ fit.const ]
          if pending_call_stacks
            if 1 == pending_call_stacks.length
              mutable_path_stack.concat pending_call_stacks.fetch 0
            else
              # see #here-arbitrariness: we've got to keep the same order
              # this spot is the most important spot
              pending_call_stacks.each do |stack_|
                mutable_path_stack.concat stack_
              end
            end
          end
          [ SOLVED__, mutable_path_stack ]
        end
      end

      # :#here-arbitrariness
      #
      # each argument of a function is processed in the order as expressed
      # by the function's "item ticket" which we can assume is determined by
      # the actual name of the function in the actual collection. (for
      # example, for a function named "X-via-A-and-B", assume we first see
      # argument "A", then "B".)
      #
      # by convention functions happen to be named with an alphabetical
      # ordering of their arguments (and output nodes when multiple) but
      # this should by no means be taken as given. assume the arguments come
      # at us in any arbitrary order.
      #
      # now, consider these two factors:
      #
      #   - when solving for the various arguments of a single function,
      #     we draw on (that is, read and mutate) *the same* notespace
      #     so that we don't repeat calculations for the same upstream
      #     nodes (our pipeline networks are not trees).
      #
      #   - for now we "flatten" the imaginary "solution tree" into
      #     a solution path (actually stack) rather early in this process,
      #
      # the concert of the above produces solution paths that have an
      # arbitrariness that is a reflection of the arbitrary ordering of the
      # arguments. for today this is OK with us but we will need to revisit
      # the whole algorithm near flattening when it comes time to look at
      # the #here:concurrency-feature.

      def __build_a_fork

        # this produces a new object whose "notespace" is a DEEP DUP of
        # the receiver's notespace. it's not cheap compared to the other.

        o = _begin_copy
        o.instance_variable_set :@knownnesses, @knownnesses.dup
        o.instance_variable_set :@target_symbol, @target_symbol
        o.instance_variable_set :@visiting, @visiting.dup
        o
      end

      def __recurse_into_argument sym

        # assume the solvability of this node is unknown (but this fact is
        # itself known). we do not deep-dup the notespace: we must draw on
        # the same notespace so that we don't repeat the same calculations
        # made for other, previous arguments. see #here:arbitrariness

        o = _begin_copy
        o.instance_variable_set :@knownnesses, @knownnesses
        o.instance_variable_set :@target_symbol, sym
        o.instance_variable_set :@visiting, @visiting
        o._common
      end

      def _begin_copy
        o = self.class.allocate
        o.instance_variable_set :@do_trace, @do_trace
        o.instance_variable_set :@function_index, @function_index
        o
      end

      # ==

      KNOWN_TO_BE_UNSOLVABLE__ , KNOWN_TO_BE_SOLVED__ = class Knownness____

        # this is really just a boolean value that is wrapped in an object
        # so that the object that we pass around that represents the boolean
        # is itself always true-ish, even though the value that it wraps
        # might be false-ish.

        # for our purposes, in our "mind" (or "notespace"), every node is
        # is one of three states:
        #   1) we know that we can solve it
        #   2) we know that we cannot sove it
        #   3) we know that we don't know yet whether we can or can't solve it

        # for the first two categories, we use the two singleton instances of
        # this class. the third category is outside the scope of this class.

        # in structure this is almost identical to our [#co-004] "knownness"
        # structure but we use business-customized names here to fit our
        # local semantics. (that referecepoint references others, including
        # the famous donald rumsfeld quote which is the idea's genetic origin.)

        # since we are only ever wrapping two values we just use singletons

        def initialize b
          @is_solved = b
          freeze
        end

        attr_reader(
          :is_solved,
        )

        a = [ new( false ), new( true ) ]
        class << self
          undef_method :new
        end  # >>
        a
      end

      # ==

      SOLVED__ = true
      UNSOLVABLE__ = false
      UNSOLVABLE_RESULT_TUPLE__ = [ UNSOLVABLE__ ].freeze
    end
  end
end
# #history: first rewrite.

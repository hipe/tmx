module Skylab::BeautySalon

  class CrazyTownMagnetics_::Hooks_via_HooksDefinition  # 1x

    # this is the moneyshot - this is the guy that traverses every sexp
    # of a document sexp and runs all the hooks.

    # a "hook" is a proc associated with a symbol from the grammar: each
    # time a sexp node is encountered corresponding to that symbol, the proc
    # is called, being passed the sexp. (the result of this call is ignored.)
    #
    # there need not be one hook for every symbol. even if a symbol does not
    # have an associated hook, our traversal will nonetheless descend into
    # those sexps that are branch-nodes (i.e "deep", recursive).
    #
    # currently there cannot be multiple hooks associated with one symbol.
    # (an exception will be thrown.) you could, however, hack such an
    # arrangement in your definition (because you can write arbitrary
    # code in your hook).

    # a "document hooks plan" is simply a collection of these hooks (just
    # a tuple). (we call it a "plan" and not "hooks" just because the former
    # sounds more singular and concrete.)
    #
    # you can have several plans in one definition, so for example you could
    # follow one set of behaviors for files that look like tests (based on
    # their filename), and another set of behaviors for files that look like
    # asset files. (really, this feature is just a cheap by-product of the
    # fact that for performance reasons we evaluate definitions before we
    # traverse files.)

    # we follow our own simple "prototype" pattern

    # primarily, in its current state, the bulk of the code here is for our
    # own "getting to know" the sexp's, and asserting their shape to be
    # used across our corpus.

    # developer's note: conventionally a variable called `s` is for holding
    # a string; however here `s` is used exclusively for `::Sexp` instances.

    # -

      def initialize
        @plans = {}
        @__mutex_for_on_each_file_path = nil
        @__mutex_for_after_last_file = nil
        yield self
        @plans.freeze
        freeze
      end

      def define_document_hooks_plan k, & two_p

        @plans[ k ] && fail
        @plans[ k ] = :__locked__

        _plan = DocumentHooksPlan___.new do |o|
          yield o  # hi.
        end

        @plans[ k ] = _plan ; nil
      end

      def on_each_file_path & p
        remove_instance_variable :@__mutex_for_on_each_file_path
        @receive_each_file_path__ = p ; nil
      end

      def after_last_file & p
        remove_instance_variable :@__mutex_for_after_last_file
        @proc_for_after_last_file__ = p ; nil
      end

      def flush_to_line_stream_via_file_path_upstream_resources rsx

        CrazyTownMagnetics_::LineStream_via_Resources_and_Hooks.call_by do |o|

          o.file_path_upstream_resources = rsx

          o.hooks = self
        end
      end

      attr_reader(
        :receive_each_file_path__,
        :plans,
        :proc_for_after_last_file__,
      )
    # -

    # ==

    class DocumentHooksPlan___

      def initialize

        # (prototype.)

        @_strict_hook_box = Common_::Box.new

        @__mutex_for_before_each_file = nil
        @before_each_file = MONADIC_EMPTINESS_

        @__mutex_for_after_each_file = nil
        @after_each_file = MONADIC_EMPTINESS_

        yield self

        bx = remove_instance_variable :@_strict_hook_box
        if bx.length.zero?
          @_has_hooks = false
        else
          @_has_hooks = true
          @__hook_via_symbol_symbol = bx.h_
        end

        freeze
      end

      private :dup

      def on_this_one_kind_of_sexp__ k, & p

        @_strict_hook_box.add k, p
      end

      def on_each_sexp & p

        bx = @_strict_hook_box

        GRAMMAR_SYMBOLS.each_key do |k|
          bx.add k, p  # ..
        end

        NIL
      end

      def before_each_file & p
        remove_instance_variable :@__mutex_for_before_each_file
        @before_each_file = p ; nil
      end

      def after_each_file & p
        remove_instance_variable :@__mutex_for_after_each_file
        @after_each_file = p ; nil
      end

      # -- read

      def execute_plan_against__ potential_sexp
        @before_each_file[ potential_sexp ]
        if @_has_hooks
          sexp = potential_sexp.sexp
          if sexp
            dup.__execute_against sexp
          end
        end
        @after_each_file[ potential_sexp ] ; nil
      end

      def __execute_against sexp  # assume dup

        # probably a file BEFORE hook ..

        _expression sexp

        # probably a file AFTER hook ..

        NIL
      end

      def _expression s

        sym = s.fetch 0
        p = @__hook_via_symbol_symbol[ sym ]
        if p
          p[ s ]  # ignore result - don't let hooks control our flow
        end
        _m = GRAMMAR_SYMBOLS.fetch sym
        send _m, s
      end

      CrazyTownMagnetics_::Hooks_via_HooksDefinition::GRAMMAR_SYMBOLS = {
        array: :__array,
        attrasgn: :__attrasng,
        block: :_block,
        block_pass: :__block_pass,
        break: :__break,
        call: :__call,
        case: :__case,
        cdecl: :__const_declaration,
        class: :__class,
        colon2: :__colon2,
        colon3: :__colon3,
        const: :__const,
        defn: :__defn,
        dstr: :__dstr,
        evstr: :__evstr,
        gvar: :__gvar,
        iasgn: :__iasgn,
        if: :__if,
        iter: :__iter,
        ivar: :__ivar,
        lasgn: :__lasgn,
        lit: :__lit,
        lvar: :__lvar,
        module: :__module,
        nil: :__nil,
        redo: :__redo,
        rescue: :__rescue,
        self: :__self,
        sclass: :__singleton_class_block,
        str: :__str,
        # when:  see #here1
        while: :__while,
        yield: :__yield,
        zsuper: :__zsuper,
      }

      def __class s
        d = s.length
        2 < d || interesting

        # s.fetch 1  # name thing - ignored for now
        # s.fetch 2  # parent class thing - ignored for now

        if 3 < d  # class can be empty
          _tapeworm 3, s
        end
      end

      def __singleton_class_block s  # this is the block

        # s.fetch 1  # the class we are mutating the singleton class of -
                     # it could be anything NOTE, but typically in our use it's just `s(:self)`

        if 2 < s.length  # (hypothetically could be empty)
          _tapeworm 2, s
        end
      end

      def __module s

        # s.fetch 1  # name thing - ignored for now

        if 2 < s.length
          _tapeworm 2, s
        end
      end

      def __iter s

        d = s.length
        4 == d || no_problem

        # [1]
        call = s.fetch 1
          :call == call.fetch(0) || interesting
          # call.fetch(1) - the receiver
          # call.fetch(2) - the method name (or :lambda for `->`)

        # [2]
        args = s.fetch 2
          # ignoring each of the args
          if 0 != args
            :args == args.fetch(0) || interesting
          end

        # [3]
        wat = s.fetch 3
        if :block == wat.fetch(0)
          _expression wat
        else
          _expression wat  # a proc with one statement
        end
      end

      def __defn s

        4 <= s.length || interesting
        # s.fetch 1  # name thing - ignored for now

        s.fetch( 2 ).first == :args || interesting  # ignored for now

        _tapeworm 3, s
      end

      def __rescue s
        3 == s.length || fail

        this = s.fetch(1)
        if :block == this.fetch(0)
          _block blk  # re-use the same thing used for an "ordinary" block
        else
          # (like with other blocks, this can be a single-expression instead)
          _expression this
        end

        bdy = s.fetch(2)
        :resbody == bdy.fetch(0) || fail
        _tapeworm 1, bdy
      end

      def _block s
        _tapeworm 1, s
      end

      def __call s

        # (NOTE if you're passing some crazy `iter` *as* an argument
        # then we'll miss important things here..) we know we do
        # this in some places, like old state machine specifications..

        # s.fetch 1  # receiver - ignored for now
        # s.fetch 2  # method name symbol - USE SOON

        d = s.length
        2 < d || never
        if 3 == d
          NOTHING_
        else
          _tapeworm 3, s
        end
      end

      def __block_pass s  # for when a proc is passed as a block argument,

        # as in:
        #     foomie.toumie( & xx(yy(zz)) )  # (the part beginning with `&` & ending with `zz))`
        #                    ^^^^^^^^^^^^

        2 == s.length || interesting
        _expression s.fetch 1
      end

      def __while s
        d = s.length
        4 == d || oops
        false == s.fetch(3) || interesting__readme__
        # (we're expecting the above to be true when normal, false when our style)
        # (NOTE) skipping descent into conditional expression

        _expression s.fetch 2
      end

      def __case s

        # we do some "by hand" parsing of these because of the relatively
        # particular structure of `case` (switch) expressions when compared
        # to other language features:

        # the [1] member is an expression for the value under scrutiny
        # (superficially like the same slot in `if` but not really).

        # jumping to the end of the feature for a moment, the [(N-1)] member
        # is the `else` expression.  NOTE if an `else` clause isn't present
        # in the feature instance, this value is `nil`; i.e this "slot"
        # always exists whether or not it has anything in it (necessarily).

        # the remaining (at least one) [2 thru (N-2)] items are `when`
        # features. these are represented in the tree as formal `when`
        # instances proper; but since such features should only ever occur
        # in `switch` expressions, we don't want them in our general lookup
        # table so we assert for them "by hand" here.

        # satisfyingly, it appears to be syntactically impossible to have
        # a `case` expression without at least one `when` component.

        # for arbitrary grammers this context-sensitive situation should
        # occur with arbitrary frequency, and so we would want to improve
        # our "after parsing" library so this feels less like such a one-
        # off; but with the target language this situation appears to be
        # limited to this language feature? some other keywords that have
        # particular context senstivity: `return`, `break`, `next`, `redo`, `rescue`, `super` ..
        # but note some of these contextualities aren't implemented lexically
        # but rather at runtime

        d = s.length
        # symbol, scrutinized, when, [ when, [..]] else
        3 < d || interesting
        _expression s.fetch 1  # the scrutinized

        2.upto( d - 2 ) do |idx|  # the one or more `when` components

          whn = s.fetch idx
          :when == whn.fetch(0) || interesting  # :#here1

          # each `when` has the "comparator" expression and the "consequence" expression
          3 == whn.length || interesting
          cmp = whn.fetch 1
          con = whn.fetch 2
          :array == cmp.fetch(0) || interesting

          _tapeworm 1, cmp  # descend into each one of the (possibly multiple) comparator values

          _expression con  # the consequence expression is any arbitrary expression
        end

        els = s.fetch d - 1
        if els
          _expression els
        end
      end

      def __if s

        4 == s.length || interesting
        # any one of these could go deep

        _expression s.fetch 1
        _expression s.fetch 2

        els = s.fetch 3
        if els
          _expression els
        end
      end

      def __yield s
        if 1 < s.length
          _tapeworm 1, s
        end
      end

      def __redo s
        _common_assertion_one_for_debugging s
      end

      def __break s
        _common_assertion_one_for_debugging s
      end

      def _tapeworm d, s
        last = s.length - 1
        begin
          _expression s.fetch d
          last == d && break
          d += 1
          redo
        end while above
      end

      def __const_declaration s
        3 == s.length || interesting
        # s.fetch 1  # const - ignored for now
        _expression s.fetch 2
      end

      def __iasgn s
        3 == s.length || interesting
        ::Symbol === s[1] || oops
        _expression s.fetch 2
      end

      def __lasgn s
        3 == s.length || interesting
        ::Symbol === s[1] || oops
        _expression s.fetch 2
      end

      def __attrasng s
        4 == s.length || interesting
        :lvar == s[1].fetch(0) || interesting
        ::Symbol === s[2] || oops  # method name (e.g. `max_height=`)
        _expression s.fetch 3
      end

      def __const s
        2 == s.length || oops
        ::Symbol === s[1] || oops
      end

      def __lvar s
        2 == s.length || oops
        ::Symbol === s.fetch(1) || oops
      end

      def __array s
        if 1 != s.length
          _tapeworm 1, s
        end
      end

      def __colon2 s

        # (NOTE we *think* this is for our fully qualified const names: `::Foo::Bar`)

        3 == s.length || interesting

        ::Symbol === s.fetch(2) || interesting

        this = s.fetch 1
        sym = this.fetch(0)
        :colon2 == sym || :colon3 == sym or interesting

        _expression this
      end

      def __colon3 s

        _common_assertion_two_for_debugging s
      end

      def __gvar s
        # (interesting, rescuing an exception is syntactic sugar for `e = $!`)
        _common_assertion_two_for_debugging s
      end

      def __ivar s
        _common_assertion_two_for_debugging s
      end

      def __dstr s

        # interesting - if the double-quoted string has interpolation things
        # in it, the entire remainder of the string is a tapeworm of arbitary
        # expressions (but probably every other element is a string..)

        d = s.length
        2 <= d || intersing
        ::String === s.fetch(1) || interesting
        if 2 < d
          _tapeworm 2, s
        end
      end

      def __evstr s  # (presumably "evaluate as string")
        2 == s.length || interesting
        _expression s.fetch 1
      end

      def __str s
        2 == s.length || interesting
        ::String === s.fetch(1) || interesting
      end

      def __lit s
        2 == s.length || interesting
        case s.fetch(1)
        when ::Symbol  # is symbol
        when ::Integer  # is integer
        # .. flot probably ..
        else ; interesting
        end
      end

      def _common_assertion_two_for_debugging s
        2 == s.length || interesting
        ::Symbol === s.fetch(1) || interesting
      end

      def __self s
        _common_assertion_one_for_debugging s
      end

      def __zsuper s
        _common_assertion_one_for_debugging s
      end

      def __nil s
        _common_assertion_one_for_debugging s
      end

      def _common_assertion_one_for_debugging s
        1 == s.length || interesting
      end
    end

    # ==

    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }

    # ==
    # ==
  end
end
# #born

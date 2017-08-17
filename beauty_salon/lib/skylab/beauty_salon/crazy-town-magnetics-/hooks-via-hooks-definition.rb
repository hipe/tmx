module Skylab::BeautySalon

  class CrazyTownMagnetics_::Hooks_via_HooksDefinition  # 1x

    # (NOTE - we still use the old terminology "sexp" when we should say
    # "AST node". see also #here2 #todo)

    # this is the moneyshot - this is the guy that traverses every sexp
    # of a document sexp and runs all the hooks.

    # a "hook" is a proc associated with a symbol from the grammar: each
    # time a sexp node is encountered corresponding to that symbol, the proc
    # is called, being passed the sexp. (the result of this call is ignored.)
    #
    # (it bears mentioning that this arrangement is broadly similar to
    # `::AST::Processor`, however we maintain our own take(s) on this
    # pattern as justified at #reason1.2)
    #
    # there need not be one hook for every symbol. even if a symbol does not
    # have an associated hook, our traversal will nonetheless descend into
    # those sexps that are nonterminal (i.e "deep", "branchy", recursive).
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

    # we follow our own simple #[#sli-023] "prototype" pattern.

    # primarily, in its current state, the bulk of the code here is for our
    # own "getting to know" the sexp's, and asserting their shape to be
    # used across our corpus. (this was true when we used 'ruby_parser'
    # and is still true now as we use 'parser'.)
    #
    # this amounts to a black-box reverse enginnering of exactly whatever
    # grammar the remote library implements.
    # classifications:
    #
    #   - terminals in a grammar senese (vs. non-terminals)
    #   - our higher-level sense of "branchy" nodes (vs. not)

    # development notes
    #
    # developer's note: conventionally a variable called `s` is for holding
    # a string; however here `s` is used exclusively for `::Sexp` instances.
    # NOTE - generally we are now dealing with `::Parser::AST::Node`
    # instances instead of the (`ruby_parser`) Sexp's we used to.
    # at present there are still some places where we use this legacy `s`
    # name to hold these AST nodes.
    # for new code we will use `n`, as this single letter name is rarely
    # used for anything else in this ecosystem. :#here2

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

        _plan = DocumentHooksPlan_via_Definition___.call_by do |o|
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

      attr_reader(
        :receive_each_file_path__,
        :plans,
        :proc_for_after_last_file__,
      )
    # -

    # ==

    class DocumentHooksPlan_via_Definition___ < Common_::MagneticBySimpleModel

      def initialize

        @__mutex_for_on_each_branchy_node = nil
        @branchy_node_hook = nil

        @_strict_hook_box = Common_::Box.new

        @__mutex_for_before_each_file = nil
        @before_each_file = MONADIC_EMPTINESS_

        @__mutex_for_after_each_file = nil
        @after_each_file = MONADIC_EMPTINESS_

        @listener = nil  # some reports know they don't need this
        @named_listeners = nil

        yield self
      end

      def on_each_branchy_node__ & p

        remove_instance_variable :@__mutex_for_on_each_branchy_node
        @branchy_node_hook = p
      end

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

      attr_writer(
        :listener,
        :named_listeners,
      )

      def execute

        bx = remove_instance_variable :@_strict_hook_box
        bn_p = @branchy_node_hook

        if bx.length.zero? && ! bn_p
          SimpleGuy___.new(
            @before_each_file,
            @after_each_file,
          )
        else
          ComplexGuy___.new(
            bx.h_,
            bn_p,
            @named_listeners,
            @before_each_file,
            @after_each_file,
            @listener,
          )
        end
      end
    end

    # ==

    class SimpleGuy___

      def initialize h, h_
        @before_each_file = h
        @after_each_file = h_
      end

      def execute_plan_against potential_AST
        @before_each_file[ potential_AST ]
        @after_each_file[ potential_AST ]
        NIL
      end
    end

    # ==

    class ComplexGuy___

      def initialize hvss_h, bn_p, named_listeners, bef_h, aef_h, p

        if ! hvss_h
          hvss_h = MONADIC_EMPTINESS_
        end

        @after_each_file = aef_h
        @before_each_file = bef_h
        @branchy_node_hook = bn_p
        @hook_via_symbol_symbol = hvss_h
        @listener = p
        @named_listeners = named_listeners
      end

      def execute_plan_against potential_AST

        @before_each_file[ potential_AST ]

        StackSession_via_Potential_AST___.new(
          potential_AST,
          @branchy_node_hook,
          @hook_via_symbol_symbol,
          @listener,
        ).execute

        ok = true
      ensure
        if ! ok
          __when_errored
        end
        @after_each_file[ potential_AST ]
        NIL
      end

      def __when_errored
        sct = @named_listeners
        if sct
          p = sct.on_error_once
        end
        if p
          p[]
        end
        NIL
      end
    end

    # ==

    class StackSession_via_Potential_AST___

      def initialize o, bn_p, h, p

        @_push_stack_frame = :__push_stack_frame_initially

        @potential_AST = o
        @branchy_node_hook = bn_p
        @hook_via_symbol_symbol = h
        @listener = p
      end

      def execute
        __stack_session do
          __via_wrapped_AST
        end
        NIL
      end

      def __via_wrapped_AST

        wast = @potential_AST.sexp

        # ignoring comments stuff

        ast = wast.ast_
        if ast
          _node ast
        else
          @listener.call( :info, :expression, :empty_file ) { |y| y << "(file has no code)" }
        end
        NIL
      end

      def _any_node x
        if x
          _node x
        end
      end

      def _expect sym, n
        if sym != n.type
          oops
        end
        _node n
      end
      alias_method :o, :_expect  # not sure which one we want

      def _node n

        _m = GRAMMAR_SYMBOLS.fetch n.type
        _call _m, n
      end

      def _call m, n

        p = @hook_via_symbol_symbol[ n.type ]
        if p
          p[ n ]  # ignore result - don't let hooks control our flow
        end

        send m, * n.children, n
      end

      CrazyTownMagnetics_::Hooks_via_HooksDefinition::GRAMMAR_SYMBOLS = {

        # it seems a bit .. well .. "crunchy" to have all this stuff
        # splayed out here. but:
        #
        #   A) it was for getting to know how the previous parsing library
        #      parses things, and likewise can be used to see how the
        #      current library parses things.
        #
        #   B) to traverse an AST recursively, we want to be able to do
        #      this "forwardly" rather than passively reflecting on each
        #      AST; i.e we want a sense for the discrete set of symbols
        #      that are nonterminal rather than terminal
        #
        #   C) for the nascent but soon-to-be-burgeoning "selector" API
        #      we may want fine-grained control over what behavior we
        #      avail to each symbol, for example to make complicated
        #      representations appear simpler to the DSL.
        #
        #   D) it's fun to get a sense for how our own corpus covers all
        #      grammar symbols vs. the set of all symbols.

        and: :__and,
        and_asgn: :__and_asgn,
        arg: :__arg,
        args: :__args,
        array: :__array,
        begin: :__begin,
        block: :__block,
        block_pass: :__block_pass,
        break: :__break,
        case: :__case,
        casgn: :__const_assign,
        class: :__class,
        const: :__const,
        def: :__def,
        defined?: :__defined?,
        defs: :__defs,
        dstr: :__dstr,
        dsym: :__dsym,
        ensure: :__ensure,
        erange: :__erange,
        false: :__false,
        float: :__float,
        gvar: :__gvar,
        gvasgn: :__gvasgn,
        hash: :__hash,
        irange: :__irange,
        if: :__if,
        int: :__int,
        ivar: :__ivar,
        ivasgn: :__ivasgn,
        kwbegin: :__kwbegin,
        lvar: :__lvar,
        lvasgn: :__lvasgn,
        match_with_lvasgn: :__match_with_lvasgn,
        masgn: :__masgn,
        module: :__module,
        next: :__next,
        nil: :__nil,
        nth_ref: :__nth_ref,
        op_asgn: :__op_asgn,
        or: :__or,
        or_asgn: :__or_asgn,
        redo: :__redo,
        regexp: :__regexp,
        rescue: :__rescue,
        return: :__return,
        self: :__self,
        send: :__send,
        sclass: :__singleton_class_block,
        splat: :__splat,
        str: :__str,
        super: :__super,
        sym: :__sym,
        true: :__true,
        # when:  see #here1
        until: :__until,
        until_post: :__until_post,
        while: :__while,
        while_post: :__while_post,
        xstr: :__xstr,
        yield: :__yield,
        zsuper: :__zsuper,
      }

      # -- class, module and related

      def __class const, exp_mod, body, n
        o :const, const
        _any_expression_of_module exp_mod
        _in_stack_frame n do
          _any_node body
        end
      end

      def __singleton_class_block sc, body, n
        _singleton_classable sc
        _in_stack_frame n do
          _any_node body
        end
      end

      def __module const, body, n  # #testpoint1.35
        o :const, const
        _in_stack_frame n do
          _any_node body
        end
      end

      # -- method definition and related

      def __defs sc, sym, args, body, n  # #testpoint1.37
        _singleton_classable sc
        _symbol sym
        o :args, args
        _in_stack_frame n do
          _any_node body  # empty method body like #testpoint1.38
        end
      end

      def __def sym, args, body, n
        _symbol sym
        o :args, args
        _in_stack_frame n do
          _any_node body  # defs can be blank
        end
      end

      def __args * arg_arg_arg, _
        arg_arg_arg.each do |n|
          __arg_mine n
        end
      end

      def __arg sym, _
        _symbol sym
      end

      def __arg_mine n
        case n.type
        when :arg      ; _node n
        when :blockarg ; _call :__blockarg, n  # #testpoint1.40
        when :procarg0 ; _call :__procarg0, n  #
        when :optarg   ; _call :__optarg, n    # #testpoint1.41
        when :restarg  ; _call :__restarg, n   #
        when :kwoptarg ; _call :__kwoptarg, n  # #testpoint1.49
        when :mlhs     ; _call :__mlhs_this_other_form, n  # #testpoint1.10
        else
          oops
        end
      end

      def __kwoptarg sym, default_value, _
        _symbol sym
        _node default_value
      end

      def __optarg sym, default_value, _
        _symbol sym
        _node default_value
      end

      def __restarg * zero_or_one, _
        # neato - has no name if it's .. with no name
        if zero_or_one.length.zero?
          NOTHING_
        else
          _symbol( * zero_or_one )
        end
      end

      def __procarg0 * one_or_more, _

        case 1 <=> one_or_more.length

        when -1  # #testpoint1.45
          one_or_more.each do |n|
            o :arg, n
          end

        when 0  # #testpoint1.21
          _symbol one_or_more[0]

        when 1 ; oops
        end
      end

      def __blockarg sym, _  # #testpoint1.40 (again)
        _symbol sym
      end

      # -- language features that look like method calls

      # ~ boolean operators (pretend they're special methods (functions)))

      def __or left_node, right_node, _
        _node left_node
        _node right_node
      end

      def __and left_node, right_node, _  # #testpoint1.36
        _node left_node
        _node right_node
      end

      def __defined? expression, _  # #testpoint1.33
        _node expression
      end

      # -- calling methods

      def __send receiver, sym, * args, _
        _any_node receiver
        _symbol sym
        args.each do |n|
          _node n
        end
      end

      def __splat n_, _
        # this is yet another #foolhardy (see)

        case n_.type

        when :lvar  ; _node n_  # #testpoint1.19

        when :ivar  ; _node n_  # #testpoint1.18

        when :send  ; _node n_  # #testpoint1.17

        when :block ; _node n_  # #testpoint1.16

        when :const ; _node n_  # #testpoint1.15

        when :begin ; _node n_  # #testpoint1.14

        when :array ; _node n_  # #testpoint1.50

        when :case  ; _node n_  # #testpoint1.24

        else

          _asgn n_ # #testpoint1.23
        end
      end

      def __block_pass node, _
        # for when a proc is passed as a block argument,
        # as in:
        #     foomie.toumie( & xx(yy(zz)) )  # (the part beginning with `&` & ending with `zz))`
        #                    ^^^^^^^^^^^^

        _node node
      end

      # -- can only happen within a method

      def __yield * zero_or_more, _  # #testpoint1.42

        # see discussion at #common-jump, but see how we differ:
        # a `yield` is passing arguments to a block or proc, so its arguments
        # can be many unlike these others.
        #
        # (as seen in (at writing) system/lib/skylab/system/diff/core.rb:116)

        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __zsuper _  # `super` #testpoint1.43
        NOTHING_
      end

      def __super * zero_or_more, _  # `super()` #testpoint1.13

        # the zero or more children is an argument list

        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __return n_=nil, _  # #testpoint1.31
        _any_node n_  # see #common-jump
      end

      # -- control flow

      def __begin *zero_or_more, _
        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __block block_head, args, body, _

        __block_head block_head

        o :args, args

        _any_node body  # (blocks can be empty)
      end

      def __block_head n

        case n.type
        when :send   ; _node n  # #testpoint1.20
        when :lambda ; _call :__lambda, n
        when :super  ; _node n  # #testpoint1.12
        when :zsuper ; _node n  # #testpoint1.12.B
        else
          interesting
        end
      end

      def __lambda _
        NOTHING_
      end

      def __kwbegin * zero_or_one_or_two, _

        case zero_or_one_or_two.length
        when 0 ; NOTHING_
        when 1 ;
          n_ = zero_or_one_or_two[0]
          case n_.type
          when :rescue ; _node n_  # hi.
          when :ensure ; _node n_
          else
            _node n_
          end
        else
          zero_or_one_or_two.each do |n__|
            _node n__
          end
        end
      end

      def __ensure any_head, any_body, _

        # (the kind you see at the toplevel of method bodies is #testpoint1.11)

        if any_head
          if :rescue == any_head.type
            _node any_head  # hi.
          else
            _node any_head
          end
        end

        _any_node any_body
      end

      def __rescue begin_body, *res_bodies, mystery_last, _

        # you can have multiple rescue clauses
        # (as seen in (at writing) common/lib/skylab/common/autoloader/file-tree-.rb:215)

        # we still haven't figured out what the last item is for #todo

        # (the typical rescue clause is 3 elements long)

        _node begin_body  # a `begin` block or 1 statement

        res_bodies.each do |n_|

          :resbody == n_.type || oops
          __resbody( * n_.children )
        end

        if mystery_last
          this_is_something  # not sure, a ensure? but didn't we cover that?
        end
      end

      def __resbody array, assignable, body

        # (the next two can be not there as in (woah crazy old)):
        # task_examples/lib/skylab/task_examples/task-types/symlink.rb:14
        # #todo this doens't line up with the others

        if array
          _expect :array, array
        end

        if assignable
          # (it's possible to have a rescue clause that doesn't assign to a left value)
          _assignable assignable
        end

        if body
          # (it's possible to have a rescue clause with no "do this then")
          _node body
        end
      end

      def __until_post cond, kwbeg, _  # #testpoint1.29
        _condition cond
        _expect_kwbegin kwbeg
      end

      def __while_post cond, kwbeg, _
        _condition cond
        _expect_kwbegin kwbeg
      end

      def _expect_kwbegin n

        :kwbegin == n.type || fine

        # zero or more below. it's possible to have an empty body in it
        # (as seen in (at writing) zerk/lib/skylab/zerk/non-interactive-cli/when-help-.rb:37)

        n.children.each do |n_|
          _node n_
        end
      end

      def __until cond, body, _  # #testpoint1.26
        _condition cond
        _node body
      end

      def __while cond, body, _
        _condition cond
        _node body
      end

      def __break n_=nil, _
        _any_node n_  # see #common-jump
      end

      def __next n_=nil, _
        _any_node n_  # see #common-jump
      end

      def __redo n_=nil, _
        _any_node n_  # see #common-jump
      end

      begin

        # :#common-jump:

        # we'll describe first a `return` nonterminal then apply it to the
        # others: interestingly (or not) we note that a return statement
        # resembles superficially a method call, in that it can take
        # parenthesis or no, and that it can take zero or one "argument".
        # but unlike a method call, the return "call" cannot take multiple
        # arguments, or a block argument.
        #
        # this appears to hold also for our other friends:
        #   - `break`
        #   - `next`
        #   - `redo`
        #   - `yield` NO (see)

        # when one argument is passed, it's #testpoint1.28

        # with a `next`, annoyingingly you can "pass" one expression here
        # but look how we hack with this "feature":
        # (as seen in (at writing) system/lib/skylab/system/io/line-stream-via-page-size.rb:58)

        # the no-args form is seen everywhere, for example:
        # (as seen in (at writing) human/lib/skylab/human/summarization.rb:24)

      end

      def __case scrutinized, *one_or_more_whens, any_else_node, _

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

        # for arbitrary grammars this context-sensitive situation should
        # occur with arbitrary frequency, and so we would want to improve
        # our "after parsing" library so this feels less like such a one-
        # off; but with the target language this situation appears to be
        # limited to this language feature? some other keywords that have
        # particular context senstivity: `return`, `break`, `next`, `redo`, `rescue`, `super` ..
        # but note some of these contextualities aren't implemented lexically
        # but rather at runtime

        _node scrutinized

        one_or_more_whens.length.zero? && oops

        one_or_more_whens.each do |n_|

          :when == n_.type || interesting  # :#here1
          __when n_
        end

        _any_node any_else_node
      end

      def __when n
        a = n.children
        len = a.length
        1 < len || interesting
        0.upto( len - 2 ) do |d|
          _node a[d]  # if the scrutnized value is `===` this..
        end
        _any_node a.last  # do this (maybe do nothing)
      end

      def __if condition, if_trueish_do_this, else_do_this, _

        # (an `unless` expression gets turned into `if true, no-op else ..`)

        _condition condition
        _any_node if_trueish_do_this
        _any_node else_do_this
      end

      def _condition n
        # condition expression (its trueishness determines doo-hah)
        _node n
      end

      # -- assignment

      def __match_with_lvasgn left_node, right_node, _  # #testpoint1.48
        _node left_node
        _node right_node
      end

      def __const_assign any_const, sym, rhs=nil, _

        if any_const
          __expression_of_module any_const  # fixture file: literals and assigment
        else
          NOTHING_  # our first fixture file
        end

        _symbol sym

        _any_node rhs
      end

      def __masgn mlhs, right_node, _
        :mlhs == mlhs.type || oops
        __mlhs_this_one_form mlhs
        _node right_node
      end

      def __mlhs_this_other_form * one_or_more, _
        one_or_more.each do |n_|
          _expect :arg, n_
        end
      end

      def __mlhs_this_one_form n
        n.children.each do |n_|
          __assignable_in_mlhs n_
        end
      end

      def __op_asgn assignable, sym, rhs, _
        _assignable assignable
        _symbol sym  # :+
        _node rhs
      end

      def __or_asgn assignable, rhs, _
        _assignable assignable
        _node rhs
      end

      def __and_asgn assignable, rhs, _  # #testpoint1.25
        _assignable assignable
        _node rhs
      end

      def __assignable_in_mlhs n

        # (compare this to the immediately following method)

        case n.type
        when :send ; _node n  # #testpoint1.9
          # a send that ends up thru sugar calling `foo=`

        when :splat ; _node n  # #testpoint1.8
          # you can splat parts of the list

        else  # #testpoint1.34
          # plain old lvars

          _asgn n
        end
      end

      def _assignable n

        # (compare this to the immediately preceding method)

        # what are the things that can be the left side of a `||=` or a `+=` or the several others?
        # lvars, ivars, gvars, but also a "send" will presumably get
        # sugarized:
        #
        #   o.foo ||= :x
        #
        # what happes there is that the method `foo` is called then (IFF it's
        # false-ish) the method `foo=` is called. this isn't reflected in the
        # parse tree.

        case n.type
        when :send ; _node n  # #testpoint1.22
        else
          _asgn n
        end
      end

      def _asgn n
        case n.type
        when :gvasgn, :ivasgn, :lvasgn
          _symbol( * n.children )

        when :casgn  # #testpoint1.6
          _node n
        else
          interesting
        end
      end

      def __gvasgn sym, rhs, _
        _symbol sym
        _node rhs
      end

      def __ivasgn sym, rhs, _
        _symbol sym
        _node rhs
      end

      def __lvasgn sym, rhs, _
        _symbol sym
        _node rhs
      end

      # ~

      def __lvar sym, _
        _symbol sym
      end

      def __gvar sym, _  # #testpoint1.44

        # (interesting, rescuing an exception is syntactic sugar for `e = $!`)
        # (see also `nth_ref` which looks superficially like a global)

        _symbol sym
      end

      def __ivar sym, _
        _symbol sym
      end

      # -- special section on expression of modules

      def _any_expression_of_module x
        if x
          __expression_of_module x
        end
      end

      def __expression_of_module n

        # this is yet another case of #foolhardy (see)

        # partially duplicated at #temporary-spot-1. this one is now ahead. #todo

        case n.type
        when :const ; _node n  # can recurse back to here
        when :cbase ; _call :__cbase, n  # `< ::BasicObject`
        when :self  ; _node n  # #testpoint1.5
        when :lvar  ; _node n  # #testpoint1.27
        when :ivar  ; _node n  # #testpoint1.30
        when :send  ; _node n  # #testpoint1.39
        when :begin ; _node n  # #testpoint1.4
        else
          anything_is_possible_here_but_lets_make_a_note_of_it
        end
      end

      def __const any_mod_exp, sym, _
        _any_expression_of_module any_mod_exp
        _symbol sym
      end

      def __cbase _
        NOTHING_
      end

      # -- magic variables (globals) and similar

      def __nth_ref d, _  # `$1` #testpoint1.3
        _integer d
      end

      # -- literals

      def __hash *zero_or_more, _
        zero_or_more.each do |n_|
          :pair == n_.type || oops
          __pair( * n_.children )
        end
      end

      def __pair left_node, right_node
        _node left_node
        _node right_node
      end

      def __array * zero_or_more, _
        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __regexp * one_or_more, _

        len = one_or_more.length
        if 1 < len
          0.upto( len - 2 ) do |d|
            # like double-quoted strings, these can be any expressions
            _node one_or_more[ d ]
          end
        end

        :regopt == one_or_more.last.type || oops
      end

      def __dsym * zero_or_more, _
        zero_or_more.each { |n_| _node n_ }  # #double-quoted-string-like
      end

      def __xstr * zero_or_more, _  # #testpoint1.2
        zero_or_more.each { |n_| _node n_ }  # #double-quoted-string-like
      end

      def __dstr * zero_or_more, _

        # a double-quoted string will parse into `str` unless (it seems)
        # it has interpolated parts. presumably they must alternate between
        # string and expression, but can start with either, we don't bother
        # assertint which.

        zero_or_more.each { |n_| _node n_ }  # #double-quoted-string-like
      end

      # :#double-quoted-string-like:
      # for all of these, it's possible to have an empty symbol, backticks, etc
      # (as seen in (at writing) basic/lib/skylab/basic/module/creator.rb:193)

      def __str s, _
        _string s
      end

      def __sym sym, _
        _symbol sym
      end

      def __irange begin_node, end_node, _
        _node begin_node
        _node end_node
      end

      def __erange begin_node, end_node, _
        _node begin_node
        _node end_node
      end

      def __float f, _
        ::Float === f || interesting
      end

      def __int d, _
        _integer d
      end

      def _integer d
        ::Integer === d || interesting
      end

      def _singleton_classable n

        # this is another #foolhardy case and its implementation must
        # change - it's just an excercise to understand pragmatics

        case n.type

        when :self   ; _node n   # `def self.xx`        #testpoint1.38
        when :lvar   ; _node n   # `def o.xx`           #testpoint1.46
        when :const  ; _node n   # `class << Foo::Bar`  #testpoint1.47
        when :begin  ; _node n   #                      #testpoint1.1
        else
          interesting
        end
      end

      def _CVME n  # #todo - this is temporary used in development.
        #
        # 1) run that one test with coverage turned on:
        #        tmx-test-support-quickie -cover <that one spec file>
        #
        # 2) whatever grammar symbol methods are here that are not covered,
        #    make a single call to this method at the beginning of that method.
        #
        # 3) run the indented report against the target corpus so that the
        #    methods are called. when the below message appears, use that
        #    information to make an appropriate test to cover the spot.
        #
        # 4) repeat (3) until all such spots are covered.
        #
        # note this could be automated somewhat, but it would require work.

        io = $stderr
        o = caller_locations( 1, 1 )[ 0 ]
        io.puts "in this method: #{ o.base_label } (line #{ o.lineno })"
        io.puts "(as seen in (at writing) #{ @CURRENT_FILE }:#{ n.loc.line })"
        exit 0
      end

      # -- "keywords" (and those literals)

      def __self _
        NOTHING_
      end

      def __false _
        NOTHING_
      end

      def __true _
        NOTHING_
      end

      def __nil _
        NOTHING_
      end

      # -- asserters & simple clients of

      def _string x
        ::String === x || interesting
      end

      def _symbol x
        ::Symbol === x || interesting
      end

      # -- stack stuff

      # both as a contact exercise and to reduce moving parts, awareness of
      # a frame stack is "baked in" to the mechanics here, regardless of
      # whether the user has supplied a hook for listening for "branchy"
      # nodes.
      #
      #   - when the hook *is* supplied, the user gets a wrapped node
      #     that knows the depth (integer) of this node on the stack.
      #
      #   - but when the hook is not supplied, we don't create wrapped
      #     node objects that would otherwise go unused.
      #
      #   - artificially we add a once-per-file root stack frame for
      #     the file itself. this frame always has a depth of zero.
      #
      #   - then, each "branchy" node at the root level of the document
      #     will have a frame depth of 1, and so on.
      # --

      def __stack_session
        @_current_stack_depth = 0
        bn_p = @branchy_node_hook
        if bn_p
          bn_p[ WrapWithDepthAtLevelZero___.new( _path ) ]
          @_push_stack_frame = :__push_stack_frame_when_listener
        else
          @_push_stack_frame = :__push_stack_frame_when_no_listener
        end
        @_pop_stack_frame = :_pop_stack_frame
        yield
        @_current_stack_depth.zero? || fail
        remove_instance_variable :@_current_stack_depth ; nil
      end

      def _path
        @potential_AST.path
      end

      def _in_stack_frame n
        send @_push_stack_frame, n
        yield
        send @_pop_stack_frame
        NIL
      end

      def __push_first_again n
        @_pop_stack_frame = :_pop_stack_frame
        @_push_stack_frame = remove_instance_variable :@__push_stack_frame_on_deck
        send @_push_stack_frame, n
      end

      def __push_stack_frame_when_listener n
        @_current_stack_depth += 1
        _tng = Tupling_for__[ n ]
        @branchy_node_hook[ WrapWithDepthNormally__.new( @_current_stack_depth, _tng ) ]
        NIL
      end

      def __push_stack_frame_when_no_listener _n
        @_current_stack_depth += 1
      end

      def _pop_stack_frame
        @_current_stack_depth -= 1
        if @_current_stack_depth.zero?
          @__push_stack_frame_on_deck = @_push_stack_frame
          @_push_stack_frame = :__push_first_again
          @_pop_stack_frame = :_NEVER
        end
      end
    end

    # ==

    class WrapWithDepthAtLevelZero___

      def initialize path
        @path = path ; freeze
      end

      def to_description
        "file: #{ @path }"
      end

      def depth
        0
      end
    end

    class WrapWithDepthNormally__

      def initialize d, tng
        @depth = d
        @tupling = tng
        freeze
      end

      def to_description
        @tupling.to_description
      end

      attr_reader(
        :depth,
        :tupling,
      )
    end

    # ==

    Tupling_for__ = -> n do
      Home_::CrazyTownMagnetics_::SemanticTupling_via_Node.
        specific_tupling_or_generic_tupling_for n
    end

    # ==

    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }

    # ==

    # :#foolhardy:
    #
    # the TL;DR: is that this is a developmental crutch that we will
    # probably refactor out later, because as it is it isn't correct.
    #
    # this implementational quirk applies (at least) to:
    #   - `defs`
    #   - `splat`
    #   - "expression of module" for example:
    #     - the right side of `<`
    #     - the left side of `::`
    #
    # in places marked with this tag (viz the above places at least), the
    # grammatical nonterminal has as one of its components an "argument"
    # that can in fact be any expression (presumably).
    #
    # for example in the case of subclassing with `<`, you could write any
    # expression to the right side of the operator, for example a case
    # expression that weirdly determines the superclass to use. only at
    # runtime does the runtime resolve whether the expression produces
    # a (subclassable) class. the point is, it still compiles with any
    # expression there.
    #
    # (a more realistic example is using a case expression as the left
    # side of a `::` operator, something we do in one place in the corpus,
    # and is turned into a testpoint.)
    #
    # the real-world consequences of this dynamic spell out for us in a way
    # that we anticipated: for example you cannot reliably find all classes
    # in a corpus that subclass some particular class. you might find some
    # but the dynamic nature of the language prevents you from doing this
    # reliably with syntactic analysis alone.
    #
    # however as it is implemented presently, we are not so lenient.
    # rather, we have gone thru and made a case expression with a case for
    # every single grammatical symbol that *does* occur in our corpus;
    # rather that doing what is correct and acceping *any* expression (so
    # `_node`).
    #
    # this is for at least two reasons:
    #
    #   - we didn't really realize that all these things were this way
    #     at the outset. (we didn't exactly think they were *not* this way,
    #     either. we just hadn't really thought about it.)
    #
    #   - there is a tiny chance that our "granular optimism" here will
    #     yield profit later - if for example we want to implement selectors
    #     to be "pragmatic" rather than "pure" so that for example we *could*
    #     find all those classes that subclass a module as expressed by a
    #     certain const string, like "Xx::Yy". (in fact our selectors should
    #     be flexible enough to support such a query by "pure" means, but
    #     that's later.)

    # ==
    # ==
  end
end
# #history-A.3: converted hard-coded hook methods to "expand" nodes via method argument signature
# #history-A.2 (can be temporary): remove last traces of 'ruby_parser'
# #history-A.1: begin refactor from 'ruby_parser' to 'parser'
# #born

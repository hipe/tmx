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

      def _node n

        sym = n.type

        p = @hook_via_symbol_symbol[ sym ]
        if p
          p[ n ]  # ignore result - don't let hooks control our flow
        end

        _m = GRAMMAR_SYMBOLS.fetch sym
        send _m, n
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
        arg: :_arg,
        args: :__args,
        array: :_array,
        begin: :_begin,
        block: :_block,
        block_pass: :__block_pass,
        break: :__break,
        case: :_case,
        casgn: :__const_assign,
        class: :__class,
        const: :_const,
        def: :__def,
        defined?: :__defined?,
        defs: :__defs,
        dstr: :__dstr,
        dsym: :__dsym,
        ensure: :__ensure_ALONE,
        erange: :__erange,
        false: :__false,
        float: :__float,
        gvar: :__gvar,
        gvasgn: :__gvasgn,
        hash: :__hash,
        irange: :__irange,
        if: :__if,
        int: :_int,
        ivar: :_ivar,
        ivasgn: :__ivasgn,
        kwbegin: :__kwbegin,
        lvar: :_lvar,
        lvasgn: :_lvasgn,
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
        rescue: :_rescue,
        return: :__return,
        self: :_self,
        send: :_send,
        sclass: :__singleton_class_block,
        splat: :_splat,
        str: :_str,
        super: :_super,
        sym: :__sym,
        true: :__true,
        # when:  see #here1
        until: :__until,
        until_post: :__until_post,
        while: :__while,
        while_post: :__while_post,
        xstr: :__xstr,
        yield: :__yield,
        zsuper: :_zsuper,
      }

      # -- class, module and related

      def __class s
        a = s.children
        _length 3, s
        _expect :const, a[0]
        _any_expression_of_module a[1]
        _in_stack_frame s do
          _any_node a[2]
        end
      end

      def __singleton_class_block n  # this is the block
        a = n.children
        _length 2, n  # no
        _self_probably a[0]
        _in_stack_frame n do
          _any_node a[1]
        end
      end

      def __module n  # #testpoint1.35
        a = n.children
        _length 2, n
        _expect :const, a[0]
        _in_stack_frame n do
          _any_node a[1]  # empty modules have a nil item here (THING 1)
        end
      end

      # -- method definition and related

      def __defs n  # #testpoint1.37
        a = n.children
        _length 4, n
        _self_probably a[0]
        _symbol a[1]
        _expect :args, a[2]
        _in_stack_frame n do
          _any_node a[3]  # empty method body like #testpoint1.38
        end
      end

      def __def n
        a = n.children
        _length 3, n
        _symbol a[0]
        _expect :args, a[1]
        _in_stack_frame n do
          _any_node a[2]  # defs can be blank
        end
      end

      def __args node
        a = node.children
        a.each do |n|
          __arg n
        end
      end

      def __arg n
        case n.type
        when :arg      ; _arg n  # an example of #open [#043] ([#043.B])
        when :blockarg ; __blockarg n  # #testpoint1.40
        when :procarg0 ; __procarg0 n
        when :optarg   ; __optarg n  # #testpoint1.41
        when :restarg  ; __restarg n
        when :kwoptarg ; __kwoptarg n  # #testpoint1.49
        when :mlhs     ; __mlhs_this_other_form n  # #testpoint1.32
        else
          oops
        end
      end

      def __kwoptarg n
        _same_arg n
      end

      def __optarg n
        _same_arg n
      end

      def _same_arg n
        a = n.children
        _length 2, n
        _symbol a[0]
        _node a[1]  # the default value
      end

      def __restarg n
        # neato - has no name if it's .. with no name
        if n.children.length.nonzero?
          _common_assertion_two_for_debugging n
        end
      end

      def __procarg0 n  # #testpoint1.21
        a = n.children
        if 1 == a.length
          _common_assertion_two_for_debugging n
        else
          # #testpoint1.45
          _each_child a do |n_|
            :arg == n_.type || oops
          end
        end
      end

      def __blockarg n  # #testpoint1.40 (again)
        _common_assertion_two_for_debugging n
      end

      def _arg n
        _common_assertion_two_for_debugging n
      end

      # -- language features that look like method calls

      # ~ boolean operators (pretend they're special methods (functions)))

      def __or n
        _and_or_or n
      end

      def __and n  # #testpoint1.36
        _and_or_or n
      end

      def _and_or_or n
        a = n.children
        _length 2, n
        _node a[0]
        _node a[1]
      end

      def __defined? n  # #testpoint1.33
        a = n.children
        _length 1, n
        _node a[0]
      end

      # -- calling methods

      def __lambda n
        _common_assertion_one_for_debugging n
      end

      def _send n
        a = n.children
        _any_node a[0]
        _symbol a[1]
        if 2 < a.length
          _tapeworm 2, a
        end
      end

      def _splat n
        # this is yet another #foolhardy (see)
        _length 1, n
        n_ = n.children[0]
        case n_.type

        when :lvar ; _lvar n_  # #testpoint1.19

        when :ivar ; _ivar n_  # #testpoint1.18

        when :send ; _node n_  # #testpoint1.17

        when :block ; _node n_  # #testpoint1.16

        when :const ; _const n_  # #testpoint1.15

        when :begin ; _begin n_  # #testpoint1.14

        when :array ; _array n_  # #testpoint1.50

        when :case ; _case n_  # #testpoint1.24

        else

          _asgn n_ # #testpoint1.23
        end
      end

      def __block_pass s  # for when a proc is passed as a block argument,

        # as in:
        #     foomie.toumie( & xx(yy(zz)) )  # (the part beginning with `&` & ending with `zz))`
        #                    ^^^^^^^^^^^^

        a = s.children
        _length 1, s
        _node a[0]
      end

      # -- can only happen within a method

      def __yield n  # #testpoint1.42

        # see discussion ant `_common_jump`, but see how we differ:
        # a `yield` is passing arguments to a block or proc, so its arguments
        # can be many unlike these others.
        # system/lib/skylab/system/diff/core.rb:116

        _node_any_each_child n.children
      end

      def _zsuper n  # `super` #testpoint1.43

        _common_assertion_one_for_debugging n
      end

      def _super n  # `super()` #testpoint1.13

        # the zero or more children is an argument list

        _node_any_each_child n.children
      end

      def __return n  # #testpoint1.31
        _common_jump n
      end

      # -- control flow

      def _begin n
        _node_any_each_child n.children
      end

      def _block n
        a = n.children
        _length 3, n

        n_ = a[0]
        k = n_.type
        case k
        when :send ; _send n_  # #testpoint1.20
        when :lambda ; __lambda n_
        when :super ; _super n_  # #testpoint1.12
        when :zsuper ; _zsuper n_  # #testpoint1.12.B
        else
          interesting
        end

        _expect :args, a[1]

        _any_node a[2]  # (blocks can be empty)
      end

      def __kwbegin n
        _nothing_or_anything_or_this_switch n do |n_|
          case n_.type
          when :rescue ; _rescue n_
          when :ensure ; _ensure n_
          else
            _node n_
          end
        end
      end

      def __ensure_ALONE n
        # the kind you see at the toplevel of method bodies
        _ensure n  # #testpoint1.11
      end

      def _ensure n
        a = n.children
        _length 2, n
        n_ = a[0]
        if n_
          if :rescue == n_.type
            _rescue n_  # hi.
          else
            _node n_
          end
        end
        _any_node a[1]
      end

      def _rescue n

        # you can have multiple rescue clauses
        # common/lib/skylab/common/autoloader/file-tree-.rb:215

        # we still haven't figured out what the last item is for

        a = n.children
        last = a.length - 1

        # (the typical rescue clause is 3 elements long)

        _node a[0]  # a `begin` block or 1 statement

        1.upto( last - 1 ) do |d|
          n_ = a[d]
          :resbody == n_.type || oops
          __resbody n_
        end

        n_ = a[last]
        if n_
          this_is_something  # not sure, a ensure? but didn't we cover that?
        end
      end

      def __resbody n
        a = n.children
        _length 3, n

        # (the next two can be not there as in (woah crazy old)):
        # task_examples/lib/skylab/task_examples/task-types/symlink.rb:14
        # #todo this doens't line up with the others

        n_ = a[0]
        if n_
          :array == n_.type || oops
          _array n_
        end

        n_ = a[1]
        if n_
          # (it's possible to have a rescue clause that doesn't assign to a left value)
          _assignable n_
        end

        n_ = a[2]
        if n_
          # (it's possible to have a rescue clause with no "do this then")
          _node n_
        end
      end

      def _nothing_or_anything_or_this_switch n
        a = n.children
        case a.length
        when 0 ; NOTHING_
        when 1 ; yield a[0]
        else   ; _node_each_child a
        end
      end

      def __until_post n  # #testpoint1.29
        _while_or_until_post n
      end

      def __while_post n
        _while_or_until_post n
      end

      def _while_or_until_post n
        a = n.children
        _length 2, n
        _condition a[0]
        n_ = a[1]
        :kwbegin == n_.type || fine
        # it's possible to have an empty body in it
        # zerk/lib/skylab/zerk/non-interactive-cli/when-help-.rb:37

        _node_any_each_child n_.children
      end

      def __until n  # #testpoint1.26
        _while_or_until n
      end

      def __while n
        _while_or_until n
      end

      def _while_or_until n
        a = n.children
        _length 2, n
        _condition a[0]
        _node a[1]
      end

      def __break n
        _common_jump n
      end

      def __next n
        _common_jump n
      end

      def __redo n
        _common_jump n
      end

      def _common_jump n

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

        # with a `next`, annoyingingly you can "pass" one expression here
        # but look how we hack with this "feature":
        # system/lib/skylab/system/io/line-stream-via-page-size.rb:58

        a = n.children
        case a.length
        when 0 ; # nothing, ofc - human/lib/skylab/human/summarization.rb:24
        when 1 ; _node a[0]  # any expression  #testpoint1.28
        else   ;
          probably_never
        end
      end

      def _case n

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

        a = n.children
        d = a.length

        # scrutinized, when, [ when, [..]] else
        2 < d || interesting

        _node a[0]  # scrutinized

        _each_child_from_to 1, a.length - 2, a do |n_|

          :when == n_.type || interesting  # :#here1
          __when n_
        end

        _any_node a[-1]
      end

      def __when n
        a = n.children
        last = a.length - 1
        0 < last || interesting
        0.upto( last - 1 ) do |d|
          _node a[d]  # if the scrutnized value is `===` this..
        end
        _any_node a[last]  # do this (maybe do nothing)
      end

      def __if n
        a = n.children
        _length 3, n
        _condition a[0]
        _any_node a[1]  # if true do this
        # NOTE an `unless` expression gets turned into `if true, no-op else ..`
        _any_node a[2]  # else do this
      end

      def _condition n
        # condition expression (its trueishness determines doo-hah)
        _node n
      end

      # -- assignment

      def __match_with_lvasgn n  # #testpoint1.48
        a = n.children
        _length 2, n
        _node a[0]
        _node a[1]
      end

      def __const_assign n
        a = n.children
        _length 3, n
        _any_expression_of_module a[0]
        _symbol a[1]
        _node a[2]
      end

      def __masgn n
        a = n.children
        _length 2, n
        n_ = a[0]
        :mlhs == n_.type || oops
        __mlhs_this_one_form n_
        _node a[1]
      end

      def __mlhs_this_other_form n  # #testpoint1.10
        _each_child n.children do |n_|
          :arg == n_.type || oops
          _arg n_
        end
      end

      def __mlhs_this_one_form n
        _each_child n.children do |n_|
          __assignable_in_mlhs n_
        end
      end

      def __op_asgn n
        a = n.children
        _length 3, n
        _assignable a[0]
        _symbol a[1]  # :+
        _node a[2]
      end

      def __or_asgn n
        _boolean_asgn n
      end

      def __and_asgn n  # #testpoint1.25
        _boolean_asgn n
      end

      def _boolean_asgn n
        a = n.children
        _length 2, n
        _assignable a[0]
        _node a[1]
      end

      def __assignable_in_mlhs n

        # (compare this to the immediately following method)

        case n.type
        when :send
          # a send that ends up thru sugar calling `foo=`

          _send n  # #testpoint1.9

        when :splat
          # you can splat parts of the list

          _splat n  # #testpoint1.8

        else
          # plain old lvars

          _asgn n  # testpoint1.34
        end
      end

      def _assignable n

        # (compare this to the immediately preceding method)

        # what are the things that can be the left side of a `||=` or a `+=` or the several others?
        # lvars, ivars, gvars, but also a "send" will presumably gets
        # sugarized:
        #
        #   o.foo ||= :x
        #
        # what happes there is that the method `foo` is called then (IFF it's
        # false-ish) the method `foo=` is called. this isn't reflected in the
        # parse tree.

        case n.type
        when :send
          _send n  # #testpoint1.22
        else
          _asgn n
        end
      end

      def _asgn n
        case n.type
        when :gvasgn, :ivasgn, :lvasgn
          _common_assertion_two_for_debugging n
        when :casgn
          _const n  # #testpoint1.6
        else
          interesting
        end
      end

      def __gvasgn n
        _assign n
      end

      def __ivasgn n
        _assign n
      end

      def _assign n
        a = n.children
        _length 2, n
        _symbol a[0]
        _node a[1]
      end

      def _lvasgn n
        a = n.children
        _length 2, n
        _symbol a[0]
        _node a[1]
      end

      def _lvar n
        a = n.children
        _length 1, n
        _symbol a[0]
      end

      def __gvar n  # #testpoint1.44

        # (interesting, rescuing an exception is syntactic sugar for `e = $!`)
        # (see also `nth_ref` which looks superficially like a global)

        _common_assertion_two_for_debugging n
      end

      def _ivar s
        _common_assertion_two_for_debugging s
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
        when :const ; _const n  # can recurse back to here
        when :cbase ; __cbase n  # `< ::BasicObject`
        when :self  ; _self n  # #testpoint1.5
        when :lvar  ; _lvar n  # #testpoint1.27
        when :ivar  ; _ivar n  # #testpoint1.30
        when :send  ; _send n  # #testpoint1.39
        when :begin ; _begin n   # #testpoint1.4
        else
          anything_is_possible_here_but_lets_make_a_note_of_it
        end
      end

      def _const n
        a = n.children
        _length 2, n
        _any_expression_of_module a[0]
        _symbol a[1]
      end

      def __cbase n
        _common_assertion_one_for_debugging n
      end

      # -- magic variables (globals) and similar

      def __nth_ref n  # `$1` #testpoint1.3
        _int n  # ick/meh
      end

      # -- literals

      def __hash n
        _any_each_child n.children do |n_|
          __expect_pair n_
        end
      end

      def __expect_pair n
        a = n.children
        :pair == n.type || oops
        _length 2, n
        _node a[0]
        _node a[1]
      end

      def _array n
        _node_any_each_child n.children
      end

      def __regexp n
        a = n.children
        len = a.length
        last = len - 1
        if 1 < len
          _each_child_from_to 0, last - 1, a do |n_|
            _node n_  # like double-quoted strings, these can be any expressions
          end
        end
        :regopt == a[last].type || oops
      end

      def __dsym n
        _double_quoted_string_and_similar n
      end

      def __xstr n # #testpoint1.2
        _double_quoted_string_and_similar n
      end

      def __dstr n

        # a double-quoted string will parse into `str` unless (it seems)
        # it has interpolated parts. presumably they must alternate between
        # string and expression, but can start with either, we don't bother
        # assertint which.

        _double_quoted_string_and_similar n
      end

      def _double_quoted_string_and_similar n

        # (it's possible to have an empty symbol (etc), as basic/lib/skylab/basic/module/creator.rb:193

        _node_any_each_child n.children
      end

      def _str s
        a = s.children
        _length 1, s
        _string a[0]
      end

      def __sym n
        a = n.children
        _length 1, n
        _symbol a[0]
      end

      def __irange n
        _range n
      end

      def __erange n
        _range n
      end

      def _range n
        a = n.children
        _length 2, n
        _node a[0]
        _node a[1]
      end

      def __float n
        a = n.children
        _length 1, n
        ::Float === a[0] || interesting
      end

      def _int n
        a = n.children
        _length 1, n
        ::Integer === a[0] || interesting
      end

      def _self_probably n

        # this is another #foolhardy case and its implementation must
        # change - it's just an excercise to understand pragmatics

        case n.type

        when :self  # #testpoint1.38
          _self n  # `def self.xx`

        when :lvar  # #testpoint1.46
          _lvar n  # `def o.xx`

        when :const  # #testpoint1.47
          _const n  # class << Foo::Bar

        when :begin  # #testpoint1.1
          _begin n

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

      def _self s
        _common_assertion_one_for_debugging s
      end

      def __false n
        _common_assertion_one_for_debugging n
      end

      def __true n
        _common_assertion_one_for_debugging n
      end

      def __nil s
        _common_assertion_one_for_debugging s
      end

      # -- support

      def _node_any_each_child a
        if a.length.nonzero?
          _tapeworm 0, a
        end
      end

      def _node_each_child a
        _tapeworm 0, a
      end

      def _any_each_child a, & p
        if a.length.nonzero?
          _each_child_from_to 0, a.length - 1, a, & p
        end
      end

      def _each_child a, & p
        _each_child_from_to 0, a.length - 1, a, & p
      end

      def _tapeworm d, a
        _each_child_from d, a do |node|
          _node node
        end
      end

      def _each_child_from d, a, & p
        _each_child_from_to d, a.length - 1, a, & p
      end

      def _each_child_from_to d, last, a
        begin
          yield a.fetch d
          last == d && break
          d += 1
          redo
        end while above
      end

      # -- asserters & simple clients of

      def _common_assertion_two_for_debugging n
        a = n.children
        _length 1, n
        _symbol a[0]
      end

      def _common_assertion_one_for_debugging n
        _length 0, n
      end

      def _length d, n
        if d != n.children.length
          interesting
        end
      end

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
# #history-A.2 (can be temporary): remove last traces of 'ruby_parser'
# #history-A.1: begin refactor from 'ruby_parser' to 'parser'
# #born

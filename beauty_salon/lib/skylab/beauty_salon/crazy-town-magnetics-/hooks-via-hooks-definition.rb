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

        @_has_branchy_node_hook = false
        @__mutex_for_on_each_branchy_node = nil

        @_strict_hook_box = Common_::Box.new

        @__mutex_for_before_each_file = nil
        @before_each_file = MONADIC_EMPTINESS_

        @__mutex_for_after_each_file = nil
        @after_each_file = MONADIC_EMPTINESS_

        yield self

        bx = remove_instance_variable :@_strict_hook_box
        if bx.length.zero?
          @_has_name_based_hooks = false
        else
          @_has_name_based_hooks = true
          @_hook_via_symbol_symbol = bx.h_
        end

        freeze
      end

      private :dup

      def on_each_branchy_node__ & p

        remove_instance_variable :@__mutex_for_on_each_branchy_node
        @_hook_via_symbol_symbol ||= MONADIC_EMPTINESS_  # ick/meh. overwrite OK
        @_branchy_node_hook = p
        @_has_branchy_node_hook = true
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

      # -- read

      def execute_plan_against__ potential_sexp
        @before_each_file[ potential_sexp ]
        if @_has_name_based_hooks || @_has_branchy_node_hook
          sexp = potential_sexp.sexp
          if sexp
            dup.__execute_against sexp
          end
        end
        @after_each_file[ potential_sexp ] ; nil
      end

      def __execute_against wast  # assume dup

        @_push_stack_frame = :__push_stack_frame_initially

        # ignoring comments stuff

        __stack_session wast.path do
          _node wast.ast_
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

        p = @_hook_via_symbol_symbol[ sym ]
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
        arg: :_arg,
        args: :__args,
        array: :_array,
        attrasgn: :__attrasng,
        begin: :__begin,
        block: :_block,
        block_pass: :__block_pass,
        break: :__break,
        call: :__call,
        case: :__case,
        casgn: :__const_assign,
        cdecl: :__const_declaration,
        class: :__class,
        colon2: :__colon2,
        colon3: :__colon3,
        const: :_const,
        def: :__def,
        defn: :__defn,
        defs: :__defs,
        dstr: :__dstr,
        dsym: :__dsym,
        erange: :__erange,
        evstr: :__evstr,
        false: :__false,
        float: :__float,
        gvar: :__gvar,
        gvasgn: :__gvasgn,
        hash: :__hash,
        iasgn: :__iasgn,
        irange: :__irange,
        if: :__if,
        int: :__int,
        iter: :__iter,
        ivar: :_ivar,
        ivasgn: :__ivasgn,
        kwbegin: :__kwbegin,
        lasgn: :__lasgn,
        lit: :__lit,
        lvar: :_lvar,
        lvasgn: :_lvasgn,
        match_with_lvasgn: :__match_with_lvasgn,
        masgn: :__masgn,
        module: :__module,
        next: :__next,
        nil: :__nil,
        op_asgn: :__op_asgn,
        or: :__or,
        or_asgn: :__or_asgn,
        redo: :__redo,
        regexp: :__regexp,
        rescue: :_rescue,
        self: :_self,
        send: :_send,
        sclass: :__singleton_class_block,
        splat: :__splat,
        str: :_str,
        sym: :__sym,
        true: :__true,
        # when:  see #here1
        while: :__while,
        while_post: :__while_post,
        yield: :__yield,
        zsuper: :__zsuper,
      }

      # -- class, module and related

      def __class s
        a = s.children
        _length 3, s
        _module_identifier a[0]
        _any_probably_module a[1]
        _in_stack_frame s do
          _any_node a[2]
        end
      end

      def _any_probably_module x

        # if it's not a literal const dereference, it should be a this, right?

        if x
          if :send == x.type
            _send x
          else
            _module_identifier x
          end
        end
      end

      def __singleton_class_block n  # this is the block
        a = n.children
        _length 2, n  # no
        _self_probably a[0]
        _tapeworm 1, a
      end

      def __module s
        a = s.children
        _module_identifier a[0]
        if 1 == a.length
          interesting
        else
          _in_stack_frame s do
            _tapeworm 1, s.children
          end
        end
      end

      def __iter s
        Hi__[]

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

      # -- method definition and related

      def __defs n
        a = n.children
        _length 4, n
        _self_probably a[0]
        _symbol a[1]
        _expect :args, a[2]
        _in_stack_frame n do
          _node a[3]
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
        if a.length.nonzero?
          a.each do |n|
            case n.type
            when :arg ; _arg n  # an example of #open [#043] ([#043.B])
            when :blockarg ; __blockarg n
            when :procarg0 ; __procarg n
            when :optarg   ; __optarg n
            when :restarg  ; __restarg n
            when :kwoptarg ; __kwoptarg n
            else
              oops
            end
          end
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

      def __procarg n
        a = n.children
        if 1 == a.length
          _common_assertion_two_for_debugging n
        else
          _each_child a do |n_|
            :arg == n_.type || oops
          end
        end
      end

      def __blockarg n
        _common_assertion_two_for_debugging n
      end

      def _arg n
        _common_assertion_two_for_debugging n
      end

      def __defn s
        Hi__[]

        4 <= s.length || interesting
        # s.fetch 1  # name thing - ignored for now

        s.fetch( 2 ).first == :args || interesting  # ignored for now

        _tapeworm 3, s
      end

      # -- calling methods (special edition - boolean operators (pretend they're special methods (functions)))

      def __or n
        _and_or_or n
      end

      def __and n
        _and_or_or n
      end

      def _and_or_or n
        a = n.children
        _length 2, n
        _node a[0]
        _node a[1]
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

      def __splat n
        _length 1, n
        _node n.children[0]
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

      def __yield n
        _node_any_each_child n.children
      end

      def __zsuper n
        _common_assertion_one_for_debugging n
      end

      # -- control flow

      def __begin n
        _node_any_each_child n.children
      end

      def _block n
        a = n.children
        _length 3, n

        n_ = a[0]
        k = n_.type
        case k
        when :send ; _send n_
        when :lambda ; __lambda n_
        else ;
          interesting
        end

        _expect :args, a[1]

        _any_node a[2]  # (blocks can be empty)
      end

      # (will go away)
      def __call s
        Hi__[]

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
        a = n.children
        _length 3, n

        _node a[0]  # a `begin` block or 1 statement

        n_ = a[1]
          :resbody == n_.type || oops
          __resbody n_

        n_ = a[2]
        if n_
          this_is_something  # not sure, a ensure? but didn't we cover that?
        end
      end

      def __resbody n
        a = n.children
        _length 3, n
        n_ = a[0]
          :array == n_.type || oops
          _array n_
        n_ = a[1]
          :lvasgn == n_.type || oops  # .. #todo
          _lvasgn n_
        n_ = a[2]
          _node n_
      end

      def _nothing_or_anything_or_this_switch n
        a = n.children
        case a.length
        when 0 ; NOTHING_
        when 1 ; yield a[0]
        else   ; _node_each_child a
        end
      end

      def __while_post n
        a = n.children
        _length 2, n
        _condition a[0]
        n_ = a[1]
        :kwbegin == n_.type || fine
        _node_each_child n_.children
      end

      def __while s
        a = s.children
        _length 2, s
        _condition a[0]
        _node a[1]
      end

      def __break n
        _common_assertion_one_for_debugging n
      end

      def __next n
        _common_assertion_one_for_debugging n
      end

      def __redo s
        _common_assertion_one_for_debugging s
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

        # for arbitrary grammars this context-sensitive situation should
        # occur with arbitrary frequency, and so we would want to improve
        # our "after parsing" library so this feels less like such a one-
        # off; but with the target language this situation appears to be
        # limited to this language feature? some other keywords that have
        # particular context senstivity: `return`, `break`, `next`, `redo`, `rescue`, `super` ..
        # but note some of these contextualities aren't implemented lexically
        # but rather at runtime

        a = s.children
        d = a.length

        # scrutinized, when, [ when, [..]] else
        2 < d || interesting

        _node a[0]  # scrutinized

        _each_child_from_to 1, a.length - 2, a do |n|

          :when == n.type || interesting  # :#here1
          __when n
        end

        _any_node a[-1]
      end

      def __when n
        a = n.children
        _length 2, n

          # each `when` has the "comparator" expression and the "consequence" expression

        _node a[0]  # if the scrutinized value is `===` to this..
        _any_node a[-1]  # do this (maybe do nothing)
      end

      def __if n
        a = n.children
        _length 3, n
        _condition a[0]
        _node a[1]  # if true do this
        _any_node a[2]  # else do this
      end

      def _condition n
        # condition expression (its trueishness determines doo-hah)
        _node n
      end

      # -- assignment

      def __match_with_lvasgn n
        a = n.children
        _length 2, n
        _node a[0]
        _node a[1]
      end

      def __const_assign n
        a = n.children
        _length 3, n
        _any_const_or_similar a[0]
        _symbol a[1]
        _node a[2]
      end

      def __const_declaration s
        Hi__[]
        3 == s.length || interesting
        # s.fetch 1  # const - ignored for now
        _expression s.fetch 2
      end

      def __masgn n
        a = n.children
        _length 2, n
        n_ = a[0]
        :mlhs == n_.type || oops
        _each_child n_.children do |n3|
          _one_of_these n3
        end
        _node a[1]
      end

      def __op_asgn n
        a = n.children
        _length 3, n
        _one_of_these a[0]
        _symbol a[1]  # :+
        _node a[2]
      end

      def __or_asgn n
        a = n.children
        _length 2, n
        _one_of_these a[0]
        _node a[1]
      end

      def _one_of_these n
        k = n.type
        :lvasgn == k || :ivasgn == k || :gvasgn == k || oops
        _common_assertion_two_for_debugging n
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

      def __iasgn s
        Hi__[]
        3 == s.length || interesting
        ::Symbol === s[1] || oops
        _expression s.fetch 2
      end

      def _lvasgn n
        a = n.children
        case a.length
        when 1  # when e.g a rescue expression
          _symbol a[0]
        when 2
          _symbol a[0]
          _node a[1]
        else
          oops
        end
      end

      def __lasgn s
        Hi__[]
        3 == s.length || interesting
        ::Symbol === s[1] || oops
        _expression s.fetch 2
      end

      def __attrasng s
        Hi__[]
        4 == s.length || interesting
        :lvar == s[1].fetch(0) || interesting
        ::Symbol === s[2] || oops  # method name (e.g. `max_height=`)
        _expression s.fetch 3
      end

      def _lvar n
        a = n.children
        _length 1, n
        _symbol a[0]
      end

      def __colon2 s

        Hi__[]
        # (NOTE we *think* this is for our fully qualified const names: `::Foo::Bar`)

        3 == s.length || interesting

        ::Symbol === s.fetch(2) || interesting

        this = s.fetch 1
        sym = this.fetch(0)
        :colon2 == sym || :colon3 == sym or interesting

        _expression this
      end

      def __colon3 s
        Hi__[]
        _common_assertion_two_for_debugging s
      end

      def __gvar s
        # (interesting, rescuing an exception is syntactic sugar for `e = $!`)
        _common_assertion_two_for_debugging s
      end

      def _ivar s
        _common_assertion_two_for_debugging s
      end

      # -- special section on consts

      def _any_const_or_similar x
        if x
          case x.type
          when :const ; _const x
          when :cbase ; __cbase x
          when :send  ; _send x
          when :lvar  ; _lvar x
          when :ivar  ; _ivar x
          else
            fine_just_weird
          end
        end
      end

      def __cbase n
        _common_assertion_one_for_debugging n
      end

      def _const n
        a = n.children
        _length 2, n
        _any_const_or_similar a[0]
        _symbol a[1]
      end

      def _any_module_identifier x
        if x
          _module_identifier x
        end
      end

      def _module_identifier n
        # duplicated at #temporary-spot-1 (this one will go away) #todo
        :const == n.type || interesting
        _length 2, n
        a = n.children
        _any_probably_module a[0]
        _symbol a[1]
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

      def __dstr n

        # a double-quoted string will parse into `str` unless (it seems)
        # it has interpolated parts. presumably they must alternate between
        # string and expression, but can start with either, we don't bother
        # assertint which.

        _double_quoted_string_and_similar n
      end

      def _double_quoted_string_and_similar n
        _node_each_child n.children
      end

      def __evstr s  # (presumably "evaluate as string")
        Hi__[]
        2 == s.length || interesting
        _expression s.fetch 1
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

      def __lit s
        Hi__[]
        2 == s.length || interesting
        case s.fetch(1)
        when ::Symbol  # is symbol
        when ::Integer  # is integer
        # .. flot probably ..
        else ; interesting
        end
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

      def __int n
        a = n.children
        _length 1, n
        ::Integer === a[0] || interesting
      end

      def _self_probably n
        if :self != n.type
          self._WEEE__no_problem__
        end
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
      #   - artificially we add a once-per-file root stack frame that
      #     the file itself. this frame always has a depth of zero.
      #
      #   - then, each "branchy" node at the root level of the document
      #     will have a frame depth of 1, and so on.
      # --

      def __stack_session path
        @_current_stack_depth = 0
        if @_has_branchy_node_hook
          @_branchy_node_hook[ WrapWithDepthAtLevelZero___.new( path ) ]
          @_push_stack_frame = :__push_stack_frame_when_listener
        else
          @_push_stack_frame = :__push_stack_frame_when_no_listener
        end
        @_pop_stack_frame = :_pop_stack_frame
        yield
        @_current_stack_depth.zero? || fail
        remove_instance_variable :@_current_stack_depth ; nil
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
        @_branchy_node_hook[ WrapWithDepthNormally__.new( @_current_stack_depth, _tng ) ]
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

    Hi__ = -> do
      _loc = caller_locations(1, 1)[0]
      $stderr.puts "ride this: #{ _loc.base_label }"
      exit 0
    end

    # ==

    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }

    # ==
    # ==
  end
end
# #history-A.1: begin refactor from 'ruby_parser' to 'parser'
# #born

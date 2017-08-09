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
        sym == n.type || oops
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

        arg: :__arg,
        args: :__args,
        array: :__array,
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
        dstr: :__dstr,
        evstr: :__evstr,
        gvar: :__gvar,
        iasgn: :__iasgn,
        if: :__if,
        int: :__int,
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
        send: :__send,
        sclass: :__singleton_class_block,
        str: :__str,
        sym: :__sym,
        # when:  see #here1
        while: :__while,
        yield: :__yield,
        zsuper: :__zsuper,
      }

      def __class s
        a = s.children
        _length 3, s
        _module_identifier a[0]
        _any_module_identifier a[1]
        _in_stack_frame s do
          x = a[2]
          if x
            interesting
          end
        end
      end

      def __singleton_class_block s  # this is the block
        Hi__[]

        # s.fetch 1  # the class we are mutating the singleton class of -
                     # it could be anything NOTE, but typically in our use it's just `s(:self)`

        if 2 < s.length  # (hypothetically could be empty)
          _tapeworm 2, s
        end
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

      def __def n
        a = n.children
        _length 3, n
        _symbol a[0]
        _expect :args, a[1]
        _in_stack_frame n do
          _node a[2]
        end
      end

      def __args node
        if node.children.length.nonzero?
          _each_child_from 0, node.children do |n|
            _expect :arg, n
          end
        end
      end

      def __arg n
        a = n.children
        _length 1, n
        _symbol a[0]
      end

      def __defn s
        Hi__[]

        4 <= s.length || interesting
        # s.fetch 1  # name thing - ignored for now

        s.fetch( 2 ).first == :args || interesting  # ignored for now

        _tapeworm 3, s
      end

      def __rescue s
        Hi__[]
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

      def __begin n
        _tapeworm 0, n.children
      end

      def _block s
        Hi__[]
        _tapeworm 1, s
      end

      def __send n
        a = n.children
        _any_node a[0]
        _symbol a[1]
        if 2 < a.length
          _tapeworm 2, a
        end
      end

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

      def __block_pass s  # for when a proc is passed as a block argument,

        # as in:
        #     foomie.toumie( & xx(yy(zz)) )  # (the part beginning with `&` & ending with `zz))`
        #                    ^^^^^^^^^^^^

        a = s.children
        _length 1, s
        _node a[0]
      end

      def __while s
        Hi__[]
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
        _node a[-1]  # do this
      end

      def __if n
        a = n.children
        _length 3, n
        _node a[0]  # condition expression (its trueishness determines doo-hah)
        _node a[1]  # if true do this
        _any_node a[2]  # else do this
      end

      def __yield s
        Hi__[]
        if 1 < s.length
          _tapeworm 1, s
        end
      end

      def __redo s
        Hi__[]
        _common_assertion_one_for_debugging s
      end

      def __break s
        Hi__[]
        _common_assertion_one_for_debugging s
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

      def __const_assign n
        a = n.children
        _length 3, n
        _any_mystery a[0]
        _symbol a[1]
        _node a[2]
      end

      def __const_declaration s
        Hi__[]
        3 == s.length || interesting
        # s.fetch 1  # const - ignored for now
        _expression s.fetch 2
      end

      def __iasgn s
        Hi__[]
        3 == s.length || interesting
        ::Symbol === s[1] || oops
        _expression s.fetch 2
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

      def _any_const_or_similar x
        if x
          case x.type
          when :const ; _const x
          when :cbase ; __cbase x
          else ; interesting
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

      def __lvar n
        a = n.children
        _length 1, n
        _symbol a[0]
      end

      def __array s
        Hi__[]
        if 1 != s.length
          _tapeworm 1, s
        end
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

      def __ivar s
        Hi__[]
        _common_assertion_two_for_debugging s
      end

      def __dstr s

        # interesting - if the double-quoted string has interpolation things
        # in it, the entire remainder of the string is a tapeworm of arbitary
        # expressions (but probably every other element is a string..)

        a = s.children
        _expect :str, a[0]
        if 1 < a.length
          _tapeworm 1, a
        end
      end

      def __evstr s  # (presumably "evaluate as string")
        Hi__[]
        2 == s.length || interesting
        _expression s.fetch 1
      end

      def __str s
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

      def __int n
        a = n.children
        _length 1, n
        __integer a[0]
      end

      def _any_module_identifier x
        if x
          _module_identifier x
        end
      end

      def _module_identifier n
        # duplicated at #temporary-spot-1 (this one will go away) #todo
        :const == n.type || fail
        _length 2, n
        a = n.children
        _any_module_identifier a[0]
        _symbol a[1]
      end

      # -- asserters & simple clients of

      def _any_mystery x
        if x
          interesting
        end
      end

      def _common_assertion_two_for_debugging s
        a = s.children
        _length 1, s
        _symbol a[0]
      end

      def __self s
        Hi__[]
        _common_assertion_one_for_debugging s
      end

      def __zsuper s
        Hi__[]
        _common_assertion_one_for_debugging s
      end

      def __nil s
        _common_assertion_one_for_debugging s
      end

      def _common_assertion_one_for_debugging s
        _length 0, s
      end

      def _string x
        ::String === x || interesting
      end

      def _symbol x
        ::Symbol === x || interesting
      end

      def __integer x
        ::Integer === x || interesting
      end

      def _length d, n
        if d != n.children.length
          interesting
        end
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

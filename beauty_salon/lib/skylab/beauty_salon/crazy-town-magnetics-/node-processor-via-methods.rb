module Skylab::BeautySalon

  class CrazyTownMagnetics_::NodeProcessor_via_Methods  # (module name is #depencency1.1)

    # there's a lot to say about this node. [#021] grew out of this.
    # see especially [#021.B] and [#021.D].

    class << self
      define_method :grammar_reflection_hash, ( Lazy_.call do
        CrazyTownMagnetics_::NodeDispatcher_via_Everything::This_crazy_thing[ Here___ ]
      end )
    end  # >>

    # -

      def initialize o

        @_structured_nodes = Home_::CrazyTownMagnetics_::SemanticTupling_via_Node.structured_nodes_as_feature_branch

        @_FOR_TRANSITION_cache_one = {}

        @_node_dispatcher = o
      end

      YIKES___ = ::Hash.new { |h, k| h[k] = ::Hash.new { |hh,kk| hh[ kk ] = false ; true } }
        # only while open [#022], supress redudnant message

      def _FOR_TRANSITION_use_remote_class n

        # #open [#007.I] we are entertaining ideas of this whole ship being
        # run with a hand-made stack so that our call stack doesn't get so
        # ridiculously tall: each truly branch node (that is, most of them)
        # gets its own frame on the stack. modify the below remote method so
        # it results in a qualified (or not) scanner of its children. this
        # scanner in effect comprises the frame on the stack. at each child,
        # if it is a terminal, yield it or whatever, and otherwise add *it*
        # as a frame on the stack and so on. would be fun to benchmark the
        # two..

        cls = @_structured_nodes.dereference n.type

        same = -> do
          cls.accept_visitor_by n do |x, asc|
            if x
              if asc.is_component
                if YIKES___[ n.type ][ asc.association_symbol ]
                  $stderr.puts "(skipping #{ asc.association_symbol } of #{ n.type })"
                end
              else
                _node x
              end
            end
          end
        end

        if cls::IS_BRANCHY
          _in_stack_frame n do
            same[]
          end
        else
          same[]
        end
      end

      # -- boilerplate ..

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
        m = __shoopy_doopie_one n
        _a = _pre_descend m, n
        send m, * _a
      end

      def __shoopy_doopie_one n
        @_FOR_TRANSITION_cache_one.fetch n.type do
          k = n.type
          x = __shoopy_doopie_decide_which_way_to_go k
          @_FOR_TRANSITION_cache_one[ k ] = x
          x
        end
      end

      def __shoopy_doopie_decide_which_way_to_go k

        m = CHILDREN_OF_ENTRYPOINT___.fetch k  # (note fetch not aref)

        if @_structured_nodes.has_reference_FOR_TRANSITION_ASSUME_RESULT_IS_CACHED__ k
          if m
            $stderr.puts "MAKE THIS GUY NIL: #{ m } (in #{ __FILE__ } #{ __LINE__ }" ; exit 0
          end
          :_FOR_TRANSITION_use_remote_class
        else
          m || kristen_chenowythe
        end
      end

      # what are these hashes for? [#021.D]

      CHILDREN_OF_ENTRYPOINT___ = {
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
        cbase: :__cbase,
        class: nil,
        const: nil,
        def: nil,
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
        ivar: nil,
        ivasgn: :__ivasgn,
        kwbegin: :__kwbegin,
        lvar: :__lvar,
        lvasgn: :__lvasgn,
        match_with_lvasgn: :__match_with_lvasgn,
        masgn: :__masgn,
        module: nil,
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
        send: nil,
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

      # (tombstone: __class)

      def __singleton_class_block sc, body, self_node
        _singleton_classable sc
        _in_stack_frame self_node do
          _any_node body
        end
      end

      # (tombstone: __module)

      # -- method definition and related

      def __defs sc, sym, args, body, self_node  # #testpoint1.37
        _singleton_classable sc
        _symbol sym
        o :args, args
        _in_stack_frame self_node do
          _any_node body  # empty method body like #testpoint1.38
        end
      end

      # (tombstone: __def)

      # ~ (blocks are like procs are like method defs..)

      def __block block_head, args, body

        m = CHILDREN_OF_BLOCK___.fetch block_head.type
        _a = _pre_descend m, block_head
        send m, * _a

        o :args, args

        _any_node body  # (blocks can be empty)
      end

      CHILDREN_OF_BLOCK___ = {
        lambda: :__lambda_as_block_child,
        send: :__send_as_block_child,
        super: :__super_as_block_child,
        zsuper: :__zsuper_as_block_child,
      }

      def __lambda_as_block_child
        NOTHING_
      end

      def __zsuper_as_block_child
        # #todo in corpus but not covered.
        # as seen in (a writing) brazen/test/433-collection-adapters/031-git-config/400-mutable/040-counterpart-parsing-canon_spec.rb)
        NOTHING_
      end

      # ~

      def __args * arg_arg_arg
        arg_arg_arg.each do |n|
          m = CHILDREN_OF_ARGS___.fetch n.type
          _a = _pre_descend m, n
          send m, * _a
        end
      end

      CHILDREN_OF_ARGS___ = {
        arg:      :__arg_as_child_of_args,
        blockarg: :__blockarg,  # #testpoint1.40
        procarg0: :__procarg0,
        optarg:   :__optarg,  # #testpoint1.41
        restarg:  :__restarg,
        kwoptarg: :__kwoptarg,  # #testpoint1.49
        mlhs:     :__mlhs_this_other_form,  # #testpoint1.10
      }

      def __arg_as_child_of_args sym
        _symbol sym
      end

      def __arg sym
        _symbol sym
      end

      def __kwoptarg sym, default_value
        _symbol sym
        _node default_value
      end

      def __optarg sym, default_value
        _symbol sym
        _node default_value
      end

      def __restarg * zero_or_one
        # neato - has no name if it's .. with no name
        if zero_or_one.length.zero?
          NOTHING_
        else
          _symbol( * zero_or_one )
        end
      end

      def __procarg0 * one_or_more

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

      def __blockarg sym  # #testpoint1.40 (again)
        _symbol sym
      end

      # -- language features that look like method calls

      # ~ boolean operators (pretend they're special methods (functions)))

      def __or left_node, right_node
        _node left_node
        _node right_node
      end

      def __and left_node, right_node  # #testpoint1.36
        _node left_node
        _node right_node
      end

      def __defined? expression  # #testpoint1.33
        _node expression
      end

      # -- calling methods

      def __send_as_block_child receiver, sym, *args  # #testpoint1.20

        # #todo the "as block child" of `send` is identical to oridnary send
        # not covered but in corpus
        # as seen in (at writing): common/test/fixture-directories/twlv-dli/glient.rb

        _any_node receiver
        _symbol sym
        args.each do |n_|
          _node n_
        end
      end

      # (tombstone: __send)

      def __splat n_
        # another (TEMPORARY) "foolhardy" [#doc.G] (see)

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

      def __block_pass n_
        # for when a proc is passed as a block argument,
        # as in:
        #     foomie.toumie( & xx(yy(zz)) )  # (the part beginning with `&` & ending with `zz))`
        #                    ^^^^^^^^^^^^

        _node n_
      end

      # -- can only happen within a method

      def __yield * zero_or_more  # #testpoint1.42

        # syntax sidebar:
        # see discussion at #common-jump, but see how we differ:
        # a `yield` is passing arguments to a block or proc, so its arguments
        # can be many unlike these others.
        #
        # (as seen in (at writing) system/lib/skylab/system/diff/core.rb:116)

        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __zsuper  # `super` #testpoint1.43
        NOTHING_
      end

      def __super_as_block_child * args

        # #todo - is the same as next
        # with no arg: #testpoint1.12
        # with some args: #testpoitn1.12.B

        args.each do |n_|
          _node n_
        end
      end

      def __super * zero_or_more  # `super()` #testpoint1.13

        # the zero or more children is an argument list

        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __return n_=nil  # #testpoint1.31
        _any_node n_  # see #common-jump
      end

      # -- control flow

      def __begin *zero_or_more
        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __kwbegin * zero_or_one_or_two

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

      def __ensure any_head, any_body

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

      def __rescue begin_body, *res_bodies, mystery_last

        # syntax sidebar:
        # you can have multiple rescue clauses
        # (as seen in (at writing) common/lib/skylab/common/autoloader/file-tree-.rb:215)

        # we still haven't figured out what the last item is for #todo

        # (the typical rescue clause is 3 elements long)

        _node begin_body  # a `begin` block or 1 statement

        res_bodies.each do |n_|
          send CHILDREN_OF_RES_BODY___.fetch( n_.type ), * n_.children
        end

        if mystery_last
          this_is_something  # not sure, a ensure? but didn't we cover that?
        end
      end

      CHILDREN_OF_RES_BODY___ = {
        resbody: :__resbody,
      }

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

      def __until_post cond, kwbeg  # #testpoint1.29
        _condition cond
        _expect_kwbegin kwbeg
      end

      def __while_post cond, kwbeg
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

      def __until cond, body  # #testpoint1.26
        _condition cond
        _node body
      end

      def __while cond, body
        _condition cond
        _node body
      end

      def __break n_=nil
        _any_node n_  # see #common-jump
      end

      def __next n_=nil
        _any_node n_  # see #common-jump
      end

      def __redo n_=nil
        _any_node n_  # see #common-jump
      end

      begin

        # syntax sidebar: :#common-jump:

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

      def __case scrutinized, *one_or_more_whens, any_else_node

        # syntax sidebar: case statements are fun

        # we do some "by hand" parsing of these because of the relatively
        # particular structure of `case` (switch) expressions when compared
        # to other language features:

        # the first component is an expression for the value under scrutiny
        # (superficially like the same slot in `if` but not really).

        # jumping to the end of the feature for a moment, the last component
        # is the `else` expression.  NOTE if an `else` clause isn't present
        # in the feature instance, this value is `nil`; i.e this "slot"
        # always exists whether or not it has anything in it (necessarily).

        # the remaining (at least one) components (offsets 1 thru N-2) are `when`
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
          send CHILDREN_OF_CASE___.fetch( n_.type ), n_
        end

        _any_node any_else_node
      end

      CHILDREN_OF_CASE___ = {
        when: :__when,  # :#here1
      }

      def __when n_
        a = n_.children
        len = a.length
        1 < len || interesting
        0.upto( len - 2 ) do |d|
          _node a[d]  # if the scrutnized value is `===` this..
        end
        _any_node a.last  # do this (maybe do nothing)
      end

      def __if condition, if_trueish_do_this, else_do_this

        # (an `unless` expression gets turned into `if true, no-op else ..`)

        _condition condition
        _any_node if_trueish_do_this
        _any_node else_do_this
      end

      def _condition n_
        # condition expression (its trueishness determines doo-hah)
        _node n_
      end

      # -- assignment

      def __match_with_lvasgn left_node, right_node  # #testpoint1.48
        _node left_node
        _node right_node
      end

      def __masgn mlhs, right_node
        :mlhs == mlhs.type || oops
        __mlhs_this_one_form mlhs
        _node right_node
      end

      def __mlhs_this_other_form * one_or_more
        one_or_more.each do |n_|
          _expect :arg, n_
        end
      end

      def __mlhs_this_one_form mlhs
        mlhs.children.each do |n_|
          __assignable_in_mlhs n_
        end
      end

      def __op_asgn assignable, sym, rhs
        _assignable assignable
        _symbol sym  # :+
        _node rhs
      end

      def __or_asgn assignable, rhs
        _assignable assignable
        _node rhs
      end

      def __and_asgn assignable, rhs  # #testpoint1.25
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

        m = CHILDREN_OF_ASSIGNMENT___.fetch n.type
        _a = _pre_descend m, n
        send m, * _a
      end

      CHILDREN_OF_ASSIGNMENT___ = {
        # ( these are repeats of symbols, but shorter versions.. #todo )
        # ( if these have context-consistent variations in their signature,
        #   are they really variations of the same symbol or are they
        #   different symbols? :#provision1.2)

        casgn: :__NOT_short_casgn,  # #testpoint1.6
        gvasgn: :__short_gvasgn,
        ivasgn: :__short_ivasgn,
        lvasgn: :__short_lvasgn,
      }

      def __NOT_short_casgn wat, const
        if wat
          self._COVER_ME__this_one_term__  # #todo
        end
        _symbol const
      end

      def __const_assign any_const, sym, rhs=nil

        if any_const
          __expression_of_module any_const  # fixture file: literals and assigment
        else
          NOTHING_  # our first fixture file
        end

        _symbol sym

        _any_node rhs
      end

      def __short_gvasgn sym
        _symbol sym
      end

      def __gvasgn sym, rhs
        _symbol sym
        _node rhs
      end

      def __ivasgn sym, rhs
        _symbol sym
        _node rhs
      end

      def __short_ivasgn sym
        _symbol sym
      end

      def __short_lvasgn sym
        _symbol sym
      end

      def __lvasgn sym, rhs
        _symbol sym
        _node rhs
      end

      # ~

      def __lvar sym
        _symbol sym
      end

      def __gvar sym  # #testpoint1.44

        # (interesting, rescuing an exception is syntactic sugar for `e = $!`)
        # (see also `nth_ref` which looks superficially like a global)

        _symbol sym
      end

      # (tombstone: __ivar)

      # -- special section on expression of modules

      def __expression_of_module n

        # another (TEMPORARY) "foolhardy" [#doc.G] (see)

        case n.type
        when :const ; _node n  # can recurse back to here
        when :cbase ; _node n  # `< ::BasicObject`
        when :self  ; _node n  # #testpoint1.5
        when :lvar  ; _node n  # #testpoint1.27
        when :ivar  ; _node n  # #testpoint1.30
        when :send  ; _node n  # #testpoint1.39
        when :begin ; _node n  # #testpoint1.4
        else
          anything_is_possible_here_but_lets_make_a_note_of_it
        end
      end

      # (tombstone: __const)

      def __cbase
        NOTHING_
      end

      # -- magic variables (globals) and similar

      def __nth_ref d  # `$1` #testpoint1.3
        _integer d
      end

      # -- literals

      def __hash *zero_or_more
        zero_or_more.each do |n_|
          send CHILDREN_OF_HASH___.fetch( n_.type ), * n_.children
        end
      end

      CHILDREN_OF_HASH___ = {
        pair: :__pair,  # #todo not exposed
      }

      def __pair left_node, right_node
        _node left_node
        _node right_node
      end

      def __array * zero_or_more
        zero_or_more.each do |n_|
          _node n_
        end
      end

      def __regexp * one_or_more

        len = one_or_more.length
        if 1 < len
          0.upto( len - 2 ) do |d|
            # like double-quoted strings, these can be any expressions
            _node one_or_more[ d ]
          end
        end

        CHILDREN_OF_REGEXP___.fetch( one_or_more.last.type ) && fail  # see
      end

      CHILDREN_OF_REGEXP___ = {
        regopt: NOTHING_,  # #todo further testing is needed to determine
        # if this is a problem on our end or the remote end (we think the
        # latter); the fact that we aren't ever getting any children under
        # this node.. #open :[#020.C]
      }

      def __dsym * zero_or_more
        zero_or_more.each { |n_| _node n_ }  # #double-quoted-string-like
      end

      def __xstr * zero_or_more  # #testpoint1.2
        zero_or_more.each { |n_| _node n_ }  # #double-quoted-string-like
      end

      def __dstr * zero_or_more

        # syntax sidebar:

        # a double-quoted string will parse into `str` unless (it seems)
        # it has interpolated parts. presumably they must alternate between
        # string and expression, but can start with either, we don't bother
        # assertint which.

        zero_or_more.each { |n_| _node n_ }  # #double-quoted-string-like
      end

      # :#double-quoted-string-like:
      # for all of these, it's possible to have an empty symbol, backticks, etc
      # (as seen in (at writing) basic/lib/skylab/basic/module/creator.rb:193)

      def __str s
        _string s
      end

      def __sym sym
        _symbol sym
      end

      def __irange begin_node, end_node
        _node begin_node
        _node end_node
      end

      def __erange begin_node, end_node
        _node begin_node
        _node end_node
      end

      def __float f
        ::Float === f || interesting
      end

      def __int d
        _integer d
      end

      def _singleton_classable n

        # another (TEMPORARY) "foolhardy" [#doc.G]

        case n.type

        when :self   ; _node n   # `def self.xx`        #testpoint1.38
        when :lvar   ; _node n   # `def o.xx`           #testpoint1.46
        when :const  ; _node n   # `class << Foo::Bar`  #testpoint1.47
        when :begin  ; _node n   #                      #testpoint1.1
        else
          interesting
        end
      end

      def _CVME n  # (exactly [#doc.H])

        io = $stderr
        o = caller_locations( 1, 1 )[ 0 ]
        io.puts "in this method: #{ o.base_label } (line #{ o.lineno })"
        io.puts "(as seen in (at writing) #{ @CURRENT_FILE }:#{ n.loc.line })"
        exit 0
      end

      # -- "keywords" (and those literals)

      def __self
        NOTHING_
      end

      def __false
        NOTHING_
      end

      def __true
        NOTHING_
      end

      def __nil
        NOTHING_
      end

      # -- "type" assertion *of* terminal components

      def _string x
        ::String === x || interesting
      end

      def _symbol x
        ::Symbol === x || interesting
      end

      def _integer d
        ::Integer === d || interesting
      end

      # --

      def _in_stack_frame n, & p
        @_node_dispatcher.stack.in_stack_frame__ p, n
      end

      def _pre_descend m, n
        @_node_dispatcher.pre_descend__ m, n
      end
    # -

    # ==

    Here___ = self

    # ==
    # ==
  end
end
# #history-A.5: begin to remove methods obviated by declarative structures
# #history-A.4: extracted longer comments, many mechanics out to own files
# #history-A.3: converted hard-coded hook methods to "expand" nodes via method argument signature
# #history-A.2 (can be temporary): remove last traces of 'ruby_parser'
# #history-A.1: begin refactor from 'ruby_parser' to 'parser'
# #born

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

        @_structured_nodes = Home_::CrazyTownMagnetics_::
          SemanticTupling_via_Node.structured_nodes_as_feature_branch

        @_FOR_TRANSITION_cache_one = {}

        @_node_dispatcher = o
      end

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
            if asc.is_terminal
              asc.assert_type_of_terminal_value_ x
            elsif x
              _node x
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
        and: nil,
        and_asgn: nil,
        arg: nil,
        args: nil,
        array: nil,
        begin: nil,
        block: :__block,
        blockarg: nil,  # #testpoint1.40
        block_pass: :__block_pass,
        break: nil,
        case: nil,
        casgn: nil,  # (formerly __const_assign)
        cbase: :__cbase,
        class: nil,
        const: nil,
        def: nil,
        defined?: nil,
        defs: :__defs,
        dstr: nil,
        dsym: nil,
        ensure: nil,
        erange: nil,
        false: nil,
        float: nil,
        gvar: nil,
        gvasgn: nil,
        hash: nil,
        irange: nil,
        if: nil,
        int: nil,
        ivar: nil,
        ivasgn: nil,
        kwbegin: nil,
        kwoptarg: :__kwoptarg,  # #testpoint1.49
        lvar: nil,
        lvasgn: nil,
        match_with_lvasgn: :__match_with_lvasgn,
        masgn: nil,
        mlhs: nil,  # (formerly: __mlhs_this_other_form)
        module: nil,
        next: nil,
        nil: nil,
        nth_ref: :__nth_ref,
        op_asgn: nil,
        optarg: nil,
        or: nil,
        or_asgn: nil,
        pair: nil,
        procarg0: :__procarg0,
        redo: nil,
        regexp: nil,
        regopt: nil,
        rescue: nil,
        resbody: nil,
        restarg: :__restarg,
        return: nil,
        self: nil,
        send: nil,
        sclass: :__singleton_class_block,
        splat: nil,
        str: nil,
        super: nil,
        sym: nil,
        true: nil,
        when: nil,
        until: nil,
        until_post: nil,
        while: nil,
        while_post: nil,
        xstr: nil,
        yield: nil,
        zsuper: nil,
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

      # (tombstone: __args)

      # (tombstone: __arg)

      def __kwoptarg sym, default_value
        _symbol sym
        _node default_value
      end

      # (tombstone: __optarg)

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

      # (tombstone: __blockarg)

      # -- language features that look like method calls

      # ~ boolean operators (pretend they're special methods (functions)))

      # (tombstone: __or)

      # (tombstone: __and)

      # (tombstone: __defined?)

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

      # (tombstone: __splat) (was a foolhardy [#doc.G] GONE)

      def __block_pass n_
        # for when a proc is passed as a block argument,
        # as in:
        #     foomie.toumie( & xx(yy(zz)) )  # (the part beginning with `&` & ending with `zz))`
        #                    ^^^^^^^^^^^^

        _node n_
      end

      # -- can only happen within a method

      # (tombstone: __yield)

      # (tombstone: __zsuper)

      def __super_as_block_child * args

        # #todo - is the same as next
        # with no arg: #testpoint1.12
        # with some args: #testpoitn1.12.B

        args.each do |n_|
          _node n_
        end
      end

      # (tombstone: __super)

      # (tombstone: __return)

      # -- control flow

      # (tombstone: __begin)

      # (tombstone: __kwbegin)

      # (tombstone: __ensure)

      # (tombstone: __rescue)

      # (tombstone: __until_post)

      # (tombstone: __while_post)

      # (tombstone: __until)

      # (tombstone: __while)

      # (tombstone __break)

      # (tombstone: __next)

      # (tombstone: __redo)

      # (tombstone: __when)

      # (tombstone: __case)

      # (tombstone: __if)

      # -- assignment

      def __match_with_lvasgn left_node, right_node  # #testpoint1.48
        _node left_node
        _node right_node
      end

      # (tombstone: __masgn)

      # (tombstone: __mlhs_this_other_form)

      # (tombstone: __op_asgn)

      # (tombstone: __or_asgn)

      # (tombstone: __and_asgn)

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

      # (tombstone: __const_assign)

      def __short_gvasgn sym
        _symbol sym
      end

      def __gvasgn sym, rhs
        _symbol sym
        _node rhs
      end

      # (tombstone: __ivasgn)

      def __short_ivasgn sym
        _symbol sym
      end

      def __short_lvasgn sym
        _symbol sym
      end

      # (tombstone: __lvasgn)

      # ~

      # (tombstone: __lvar)

      # (tombstone: __gvar)

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

      # (tombstone: __hash)

      # (tombstone: __pair)

      # (tombstone: __array)

      # (tombstone: __regexp)

      # (tombstone: __dsym)

      # (tomstone: __xstr)

      # (tomstone: __dstr) (had syntax sidebar)

      # :#double-quoted-string-like:
      # for all of these, it's possible to have an empty symbol, backticks, etc
      # (as seen in (at writing) basic/lib/skylab/basic/module/creator.rb:193)

      # (tombstone: __str)

      # (tombstone: __sym)

      # (tombstone: __irange)

      # (tombstone: __erange)

      # (tomstone: __float)

      # (tombstone: __int)

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

      # (tombstone: __self)

      # (tombstone: __false)

      # (tombstone: __true)

      # (tombstone: __nil)

      # -- "type" assertion *of* terminal components

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

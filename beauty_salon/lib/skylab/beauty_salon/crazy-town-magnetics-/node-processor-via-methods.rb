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
        elsif m
          m
        else
          kristen_chenowythe
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
        block: nil,
        blockarg: nil,  # #testpoint1.40
        block_pass: nil,
        break: nil,
        case: nil,
        casgn: nil,  # (formerly __const_assign)
        cbase: nil,
        class: nil,
        const: nil,
        def: nil,
        defined?: nil,
        defs: nil,
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
        kwoptarg: nil,
        lambda: nil,
        lvar: nil,
        lvasgn: nil,
        match_with_lvasgn: nil,
        masgn: nil,
        mlhs: nil,  # (formerly: __mlhs_this_other_form)
        module: nil,
        next: nil,
        nil: nil,
        nth_ref: nil,
        op_asgn: nil,
        optarg: nil,
        or: nil,
        or_asgn: nil,
        pair: nil,
        procarg0: nil,
        redo: nil,
        regexp: nil,
        regopt: nil,
        rescue: nil,
        resbody: nil,
        restarg: nil,
        return: nil,
        self: nil,
        send: nil,
        sclass: nil,
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

      # (tombstone: __sclass)

      # (tombstone: __module)

      # -- method definition and related

      # (tombstone: __defs)

      # (tombstone: __def)

      # ~ (blocks are like procs are like method defs..)

      # (tombstone: __block)

      # (tombstone: __lambda_as_block_child)

      # (tombstone: __zsuper_as_block_child)

      # (tombstone: __args)

      # (tombstone: __arg)

      # (tombstone: __kwoptarg)

      # (tombstone: __optarg)

      # (tombstone: __restarg)

      # (tombstone: __procarg0)

      # (tombstone: __blockarg)

      # -- language features that look like method calls

      # ~ boolean operators (pretend they're special methods (functions)))

      # (tombstone: __or)

      # (tombstone: __and)

      # (tombstone: __defined?)

      # -- calling methods

      # (tombstone: __send_as_block_child)

      # (tombstone: __send)

      # (tombstone: __splat) (was a foolhardy [#doc.G] GONE)

      # (tombstone: __block_pass)

      # -- can only happen within a method

      # (tombstone: __yield)

      # (tombstone: __zsuper)

      # (tombstone: __super_as_block_child)

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

      # (tombstone: __match_with_lvasgn)

      # (tombstone: __masgn)

      # (tombstone: __mlhs_this_other_form)

      # (tombstone: __op_asgn)

      # (tombstone: __or_asgn)

      # (tombstone: __and_asgn)

      # (tombstone: __const_assign)

      # (tombstone: __gvasgn)

      # (tombstone: __ivasgn)

      # (tombstone: __lvasgn)

      # ~

      # (tombstone: __lvar)

      # (tombstone: __gvar)

      # (tombstone: __ivar)

      # -- special section on expression of modules

      # (tombstone: __const)

      # (tombstone: __cbase)

      # -- magic variables (globals) and similar

      # (tombstone: __nth_ref)

      # -- literals

      # (tombstone: __hash)

      # (tombstone: __pair)

      # (tombstone: __array)

      # (tombstone: __regexp)

      # (tombstone: __dsym)

      # (tomstone: __xstr)

      # (tomstone: __dstr) (had syntax sidebar)

      # (tombstone: __str)

      # (tombstone: __sym)

      # (tombstone: __irange)

      # (tombstone: __erange)

      # (tomstone: __float)

      # (tombstone: __int)

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

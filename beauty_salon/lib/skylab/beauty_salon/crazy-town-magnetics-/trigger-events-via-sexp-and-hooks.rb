module Skylab::BeautySalon

  class CrazyTownMagnetics_::TriggerEvents_via_Sexp_and_Hooks < Common_::MagneticBySimpleModel

    # this is the thing that does the thing

    begin

      attr_writer(
        :sexp,
        :code_selector,
        :replacement_function,
        :listener,
      )

      def execute

        if false
        require 'pp'
        pp @sexp
        exit 0
        end

        @_debug_IO = $stderr

        _expression @sexp
        ::Kernel._OKAY
      end

      def _expression s

        _sym = s.fetch 0
        _m = EXPRESSIONS___.fetch _sym
        send _m, s
      end

      EXPRESSIONS___ = {
        array: :__array,
        attrasgn: :__attrasng,
        block: :_block,
        break: :__break,
        call: :__call,
        cdecl: :__const_declaration,
        class: :__class,
        colon2: :__colon2,
        colon3: :__colon3,
        const: :__const,
        defn: :__defn,
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
        rescue: :__rescue,
        while: :__while,
        zsuper: :__zsuper,
      }

      def __class s
        # s.fetch 1  # name thing - ignored for now
        # s.fetch 2  # parent class thing - ignored for now

        _tapeworm 3, s
      end

      def __module s
        # s.fetch 1  # name thing - ignored for now
        d = s.length
        case d
        when 3 ; _expression s.fetch 2
        when 2 ; NOTHING_
        else ; never
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

        blk = s.fetch(1)
        :block == blk.fetch(0) || fail
        _block blk  # re-use the same thing used for an "ordinary" block

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

      def __while s
        d = s.length
        4 == d || oops
        false == s.fetch(3) || interesting__readme__
        # (we're expecting the above to be true when normal, false when our style)
        # (NOTE) skipping descent into conditional expression

        _expression s.fetch 2
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

      def __break s
        1 == s.length || expecting_this
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
        _skip :colon2
      end

      def __colon3 s
        _skip :colon3
      end

      def __gvar s
        # (interesting, rescuing an exception is syntactic sugar for `e = $!`)
        2 == s.length || oops
        ::Symbol === s[1] || oops
      end

      def __ivar s
        2 == s.length || interesting
        ::Symbol === s[1] || interesting
        _skip :ivar
      end

      def __lit s
        _skip :lit
      end

      def __zsuper s
        1 == s.length || interesting
      end

      def __nil s
        1 == s.length || fail
      end

      def _skip sym
        @_debug_IO.puts "(skipping: #{ sym })"
      end
    end

    # ==
    # ==
  end
end
# #born

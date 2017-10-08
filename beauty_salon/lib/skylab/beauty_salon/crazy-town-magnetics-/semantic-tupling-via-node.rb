module Skylab::BeautySalon

  module CrazyTownMagnetics_::SemanticTupling_via_Node  # see :[#022]

    # experiment.

    class << self
      define_method :structured_nodes_as_feature_branch, ( Lazy_.call do
        CrazyTownMagnetics_::NodeProcessor_via_Module[ Here___ ]
      end )
    end  # >>

    o = CrazyTownMagnetics_::NodeProcessor_via_Module
    GrammarSymbol__ = o::GrammarSymbol

    #
    # Base classes for grammar symbol classes that have the same structure
    #

    class BoolAsgn__ < GrammarSymbol__
      children(
        :assignableforoperator,
        :right_hand_side_expression,
      )
    end

    class CommonArg__ < GrammarSymbol__
      children(
        :as_symbol_symbol_terminal,
      )
    end

    class CommonRange__ < GrammarSymbol__
      children(
        :begin_expression,
        :end_expression,
      )
    end

    class CommonSingleton__ < GrammarSymbol__
      children(
      )
    end

    module Items

      #
      # Literals
      #

      # Singletons

      # nil (placeheld)

      class Nil < CommonSingleton__
      end

      # true (placeheld)

      class True < CommonSingleton__
      end

      # false (placeheld)

      class False < CommonSingleton__
      end

      # Numerics

      # integer (placeheld)

      class Int < GrammarSymbol__
        children(
          :as_integer_integer_terminal,
        )
      end

      # float (placeheld)

      class Float < GrammarSymbol__
        children(
          :as_float_float_terminal,
        )
      end

      # rational (placeheld)
      # #open [#045] we don't even know how to make his. it's not Rational( 1 )

      # complex (placeheld)
      # #open [#045] not yet needed for our corpus

      # Strings

      # str (placeheld)

      class Str < GrammarSymbol__
        children(
          :as_string_string_terminal,
        )
      end

      # dstr (placeheld)

      class Dstr < GrammarSymbol__

        # syntax sidebar:

        # a double-quoted string will parse into `str` unless (it seems)
        # it has interpolated parts. presumably they must alternate between
        # string and expression, but can start with either, we don't bother
        # asserting which. #double-quoted-string-like

        children(
          :one_or_more_SEE_ME_expressions,
        )
      end

      # __FILE__ (placeheld)

      # #open [#045] wow is this really nowhere in our corpus?

      # Symbols

      # sym (placeheld)

      class Sym < GrammarSymbol__
        children(
          :as_symbol_symbol_terminal,
        )
      end

      # dsym (placeheld)

      class Dsym < GrammarSymbol__
        # #double-quoted-string-like
        children(
          :zero_or_more_SEE_MEE_expressions,
        )
      end

      # Executable strings

      # xstr (placeheld)

      class Xstr < GrammarSymbol__
        # #testpoint1.2
        # #double-quoted-string-like
        children(
          :zero_or_more_SEE_ME_expressions,
        )
      end

      # Indented (interpolated, noninterpolated, executable) strings

      # (this section is relevant to the builder class but not us.
      # it's here for consistency/completeness.)

      # Regular expressions

      # regopt (placeheld)

      class Regopt < GrammarSymbol__

        # #todo further testing is needed to determine if this is a problem
        # on our end or the remote end (we think the latter); the fact that
        # we aren't ever getting any children under this node.. #open :[#020.C]
        # #testpoint1.53

        children(
        )
      end

      # regexp (placeheld)

      class Regexp < GrammarSymbol__
        children(
          :zero_or_more_expressions,  # #double-quoted-string-like
          :regexopt,
        )
      end

      # Arrays

      # array (placeheld)

      class Array < GrammarSymbol__
        children(
          :zero_or_more_expressions,
        )
      end

      # splat (placeheld)

      class Splat < GrammarSymbol__

        # it appears (unsurprisingly, in hindsight) that the accompanying
        # term to a splat (its operand) can be any expression. in the legacy
        # way (pre structured uber alles) we didn't really think about this
        # so we ended up with imperative code that had specific handling of
        # every type of expression that followed a splat in our corpus.
        #
        # we have dissolved this specific handling in the code because it
        # was incorrect. ("incomplete" if you insist.) however we have
        # preserved the testpoint associations with their corresponding
        # types because A) maybe we'll want it and B) it's sort of an
        # interesting snapshot of the code pragmatics in our corpus.
        #

        # we used to cover these with dedicated assertive code (the
        # oldschool equivalent to today's type) that was "foolhardy" [#doc.G]
        #
        #   - begin  #testpoint1.14
        #   - const  #testpoint1.15
        #   - block  #testpoint1.16
        #   - send  #testpoint1.17
        #   - ivar  #testpoint1.18
        #   - lvar  #testpoint1.19
        #   - asgn  #testpoint1.23
        #   - case #testpoint1.24
        #   - array #testpoint1.50

        children(
          :expression,
        )
      end

      # Hashes

      # pair (placeheld)

      class Pair < GrammarSymbol__
        children(
          :key_expression,
          :value_expression,
        )
      end

      # kwsplat (placeheld)

      # #open [#045] is this really nowhere in our corpus?

      # hash (placeheld)

      class Hash < GrammarSymbol__
        children(
          :zero_or_more_pairs,
        )
      end

      # Ranges

      # irange (placeheld)

      class Irange < CommonRange__
      end

      # erange (placeheld)

      class Erange < CommonRange__
      end

      #
      # Access
      #

      # self (placeheld)

      # ident (placeheld)

      # ivar (placeheld)

      class Ivar < GrammarSymbol__
        children(
          :symbol_terminal,
        )
      end

      # gvar (placeheld)

      # cvar (placeheld)

      # back_ref (placeheld)

      # nth_ref (placeheld)

      # lvar (placeheld)

      class Lvar < GrammarSymbol__
        children(
          :symbol_terminal,
        )
      end

      # const (placeheld)

      class Const < GrammarSymbol__

        # TODO - #here2

        def _to_friendly_string
          my_s = symbol.id2name
          sn = any_parent_const_expression
          if sn
            buff = sn._to_friendly_string  # #TODO there are tons of holes here
            buff << COLON_COLON_ << my_s
          else
            my_s
          end
        end

        children(
          :any_parent_const_expression,
          :symbol_symbol_terminal,
        )
      end

      # __ENCODING__ (placeheld)

      #
      # Assignment
      #

      # cvasgn (placeheld)

      # #open [#045] never seen before

      # ivasgn (placeheld)

      class Ivasgn < GrammarSymbol__
        children(
          :ivar_as_symbol_symbol_terminal,
          :zero_or_one_right_hand_side_expression,  # #testpoint1.54
        )
      end

      # gvasgn (placeheld)

      class Gvasgn < GrammarSymbol__
        children(
          :UMM_symbol_terminal,
          :zero_or_one_right_hand_side_expression,
        )
      end

      # casgn (placeheld)

      class Casgn < GrammarSymbol__

        # :#here2 this is structurally a subset of the other guy

        # deep form: fixture file: literals and assigment
        # non-deep form: fixture file: the first one

        children(
          :any_PARENT_CONST_expression,
          :SYMBOL_symbol_terminal,
          :zero_or_one_right_hand_side_expression,
        )
      end

      # lvasgn (placeheld)

      class Lvasgn < GrammarSymbol__
        children(
          :lvar_as_symbol_symbol_terminal,
          :zero_or_one_right_hand_side_expression,  # #testpoint1.54
        )
      end

      # and_asgn (placeheld)

      class AndAsgn < BoolAsgn__  # #testpoint1.25
      end

      # or_asgn (placeheld)

      class OrAsgn < BoolAsgn__
      end

      # op_asgn (placeheld)

      class OpAsgn < GrammarSymbol__
        children(
          :assignableforoperator,
          :SIGN_SYMBOL_symbol_terminal,  # :+, etc
          :right_hand_side_expression,
        )
      end

      # mlhs (placeheld)

      class Mlhs < GrammarSymbol__  # #testpoint1.10

        # (presumably: 'multi left-hand side' or something)

        children(
          :one_or_more_assignableformlhss,  # YUCK that name TODO
        )
      end

      # masgn (placeheld)

      class Masgn < GrammarSymbol__

        children(
          :mlhs,
          :right_hand_side_expression,
        )
      end

      #
      # Class and module definition
      #

      # class (placeheld)

      class Class < GrammarSymbol__

        def to_description
          "class: #{ todo_module_identifier_const._to_friendly_string }"
        end

        children(
          :todo_module_identifier_const,
          :any_superclass_expression,  # TODO: group: "expression of module"
          :any_body_expression,
        )

        IS_BRANCHY = true
      end

      # sclass (placeheld)

      # module (placeheld)

      class Module < GrammarSymbol__

        def to_description
          "module: #{ todo_module_identifier_const._to_friendly_string }"
        end

        children(
          :todo_module_identifier_const,
          :any_body_expression,
        )

        IS_BRANCHY = true
      end

      #
      # Method (un)definition
      #

      # def (placeheld)

      class Def < GrammarSymbol__

        def to_description
          "def: #{ symbol }"
        end

        children(
          :symbol_terminal,
          :args,
          :any_BODY_expression,
        )

        IS_BRANCHY = true
      end

      # defs (placeheld)

      # undef (placeheld)

      # alias (placeheld)

      #
      # Formal arguments
      #

      # args (placeheld)

      class Args < GrammarSymbol__
        children(
          :zero_or_more_argfellows,
        )
      end

      # arg (placeheld)

      class Arg < CommonArg__

      end

      # optarg (placeheld)

      class Optarg < GrammarSymbol__  # #testpoint1.41

        children(
          :as_symbol_symbol_terminal,
          :default_value_expression,
        )
      end

      # restarg (placeheld)

      # kwarg (placeheld)

      # kwoptarg (placeheld)

      # kwrestarg (placeheld)

      # shadowarg (placeheld)

      # blockarg (placeheld)

      class Blockarg < CommonArg__  #testpoint1.40

      end

      # procarg0 (placeheld)

      # Ruby 1.8 block arguments

      # NOTE - we are skipping this section for now

      # wontdo: (arg, arg_expr, restarg, restarg_expr, blockarg, blockarg_expr)

      # MacRuby Objective-C arguments

      # NOTE - we are skipping this section for now

      # wontdo: (objc_kwarg, restarg, objc_restarg)

      #
      # Method calls
      #

      # csend (placeheld)

      # send (placeheld)

      class Send < GrammarSymbol__

        children(
          :any_XXX_receiver_expression,
          :method_name_symbol_terminal,
          :zero_or_more_XXX_arg_expressions,
        )

        IS_BRANCHY = false
      end

      # lambda (placeheld)

      # block (placeheld)

      # (NOTE - we might be missing some stuff near above)

      # block_pass (placeheld)

      # not (placeheld)

      # match_with_lvasgn (placeheld)

      #
      # Control flow
      #

      # Logical operations: and, or

      # and (placeheld)

      # or (placeheld)

      # Conditionals

      # if (placeheld)

      # Case matching

      # when (placeheld)

      class When < GrammarSymbol__

        children(
          :one_or_more_matchable_expressions,
          :any_consequence_expression,
        )
      end

      # case (placeheld)

      class Case < GrammarSymbol__

        # the history of this symbol is of particular significance. its
        # method-based predecessor had a giant comment blurb (commemorated
        # under #history-A.3) explaining the peculiar grammatical
        # characteristics of the AST for case expressions (EXPR when+ EXPR?).
        #
        # its code was considerably more lines and considerably less readable.
        # that this is now served so succinctly by the component grammar is
        # no coincidence: we had exactly this challenging (er) case in mind
        # when we designed it. element-by-element you can read the archived
        # comment and see descriptions that foretold its features.
        #
        # (specifically, "one or more", "any-ness", groups.)

        children(
          :scrutinized_expression,
          :one_or_more_whens,
          :any_else_expression,
        )
      end

      # Loops

      # while (placeheld)

      # until (placeheld)

      # while_post (placeheld)

      # until_post (placeheld)

      # for (placeheld)

      # Keywords

      # (NOTE - for now we are extrapolating the extend of this from ruby24.y
      # we greped for the builder method then reduced this with scripting:)

      # break (placeheld)

      # defined? (placeheld)

      # next (placeheld)

      # redo (placeheld)

      # retry (placeheld)

      # return (placeheld)

      # super (placeheld)

      # yield (placeheld)

      # zsuper (placeheld)

      # BEGIN, END

      # preexe (placeheld)

      # postexe (placeheld)

      # Exception handling

      # resbody (placeheld)

      # rescue (placeheld)

      # ensure (placeheld)

      #
      # Expression grouping
      #

      class Begin < GrammarSymbol__

        children(
          :zero_or_more_expressions,
        )
      end

      # begin (placeheld)

      # kwbegin (placeheld)
    end

    these_four_asgn = [
      :casgn,
      :gvasgn,
      :ivasgn,
      :lvasgn,
    ]

    GROUPS = {  # exactly [#022.I]
      argfellow: [
        :arg,
        :blockarg,
        :kwoptarg,
        :mlhs,
        :optarg,
        :procarg0,
        :restarg,
      ],
      arg: [
        :arg,
      ],
      args: [
        :args,
      ],
      assignableformlhs: [

        :arg,

        # (this is compared to :#here1)
        # TODO - do you really want this distinction? compare and contrast

        :send,  # #testpoint1.9
          # a send that ends up thru sugar calling `foo=`

        :splat,  # #testpoint1.8
          # you can splat parts of the list

        * these_four_asgn,  # plain old ivars etc #testpoint1.34
      ],
      assignableforoperator: [

        # (compare this to #here1)

        # what are the things that can be the left side of a `||=` or a `+=`
        # or the several others? lvars, ivars, gvars, but also a "send" which
        # gets "sugarized":
        #
        #   o.foo ||= :x
        #
        # what happens there is that the method `foo` is called then (IFF it's
        # false-ish) the method `foo=` is called. this isn't reflected in the
        # parse tree.

        * these_four_asgn,
        :send,   # #testpoint1.22
      ],
      const: [
        :const,
      ],
      mlhs: [
        :mlhs,
      ],
      pair: [
        :pair,
      ],
      regexopt: [
        :regopt,
      ],
      when: [
        :when,
      ],
    }

    TERMINAL_TYPE_SANITIZERS = {  # (explained at [#022.F])
      string: -> x do
        ::String === x
      end,
      symbol: -> x do
        ::Symbol === x
      end,
      float: -> x do
        ::Float === x
      end,
      integer: -> x do
        ::Integer === x
      end,
    }

    IRREGULAR_NAMES = {
      :defined? => :X__defined_question_mark__,
    }

    # ==

    # ==

    COLON_COLON_ = '::'.freeze
    Here___ = self

    # ==
    # ==
  end
end
# #history-A.4: when we introduced inheritence
# :#history-A.3: as referenced
# #pending-rename: "structured node" or similar
# #history-A.2: move oldschool support out so it's just constituents
# #history-A.1: inject comment placeholder for every grammar symbol saw visually
# #born.

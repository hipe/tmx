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

    class CommonArg__ < GrammarSymbol__
      children(
        :as_symbol_symbol_terminal,
      )
    end

    module Items

      #
      # Literals
      #

      # Singletons

      # nil (placeheld)

      class Nil < GrammarSymbol__  # #open #[022.E]
        children(
        )
      end

      # true (placeheld)

      # false (placeheld)

      # Numerics

      # integer (placeheld)

      class Int < GrammarSymbol__
        children(
          :as_integer_integer_terminal,
        )
      end

      # float (placeheld)

      # rational (placeheld)

      # complex (placeheld)

      # Strings

      # str (placeheld)

      # dstr (placeheld)

      # __FILE__ (placeheld)

      # Symbols

      # sym (placeheld)

      # dsym (placeheld)

      # Executable strings

      # xstr (placeheld)

      # Indented (interpolated, noninterpolated, executable) strings

      # (this section is relevant to the builder class but not us.
      # it's here for consistency/completeness.)

      # Regular expressions

      # regopt (placeheld)

      # regexp (placeheld)

      # Arrays

      # array (placeheld)

      # splat (placeheld)

      # Hashes

      # pair (placeheld)

      # kwsplat (placeheld)

      # hash (placeheld)

      # Ranges

      # irange (placeheld)

      # erange (placeheld)

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

      # ivasgn (placeheld)

      class Ivasgn < GrammarSymbol__
        children(
          :ivar_as_symbol_symbol_terminal,
          :right_hand_side_expression,
        )
      end

      # gvasgn (placeheld)

      # casgn (placeheld)

      # lvasgn (placeheld)

      class Lvasgn < GrammarSymbol__
        children(
          :lvar_as_symbol_symbol_terminal,
          :right_hand_side_expression,
        )
      end

      # and_asgn (placeheld)

      # or_asgn (placeheld)

      # op_asgn (placeheld)

      # mlhs (placeheld)

      # masgn (placeheld)

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

    GROUPS = {
      argfellow: [
        :arg,
        :blockarg,
        :kwoptarg,
        :mlhs,
        :optarg,
        :procarg0,
        :restarg,
      ],
      args: [
        :args,
      ],
      const: [
        :const,
      ],
      when: [
        :when,
      ],
    }

    TERMINAL_TYPE_SANITIZERS = {  # (explained at [#022.F])
      symbol: -> x do
        ::Symbol === x
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

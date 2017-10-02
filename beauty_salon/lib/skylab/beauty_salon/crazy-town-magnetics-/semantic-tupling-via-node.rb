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

    module Items

      #
      # Literals
      #

      # Singletons

      # nil (placeheld)

      # true (placeheld)

      # false (placeheld)

      # Numerics

      # integer (placeheld)

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
          :symbol_expression_component,
        )
      end

      # gvar (placeheld)

      # cvar (placeheld)

      # back_ref (placeheld)

      # nth_ref (placeheld)

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
          :symbol_expression_component,
        )
      end

      # __ENCODING__ (placeheld)

      #
      # Assignment
      #

      # cvasgn (placeheld)

      # ivasgn (placeheld)

      # gvasgn (placeheld)

      # casgn (placeheld)

      # lvasgn (placeheld)

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
          :symbol_expression_component,
          :WHAT_IS_ARGS_expression,
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

      # arg (placeheld)

      # optarg (placeheld)

      # restarg (placeheld)

      # kwarg (placeheld)

      # kwoptarg (placeheld)

      # kwrestarg (placeheld)

      # shadowarg (placeheld)

      # blockarg (placeheld)

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
          :method_name_expression_component,
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

      # case (placeheld)

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

      # begin (placeheld)

      # kwbegin (placeheld)
    end

    GROUPS = {
      const: [
        :const,
      ],
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
# #pending-rename: "structured node" or similar
# #history-A.2: move oldschool support out so it's just constituents
# #history-A.1: inject comment placeholder for every grammar symbol saw visually
# #born.

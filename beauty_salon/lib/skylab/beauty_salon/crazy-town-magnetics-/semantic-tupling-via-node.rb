module Skylab::BeautySalon

  module CrazyTownMagnetics_::SemanticTupling_via_Node  # see :[#022]

    # experiment.

    class << self
      define_method :tuplings_as_feature_branch, ( Lazy_.call do
        CrazyTownMagnetics_::NodeProcessor_via_Module[ Constituents___ ]
      end )
    end  # >>

    o = CrazyTownMagnetics_::NodeProcessor_via_Module
    Tupling__ = o::Tupling
    Component__ = o::Component

    module Constituents___

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

      # gvar (placeheld)

      # cvar (placeheld)

      # back_ref (placeheld)

      # nth_ref (placeheld)

      # const (placeheld)

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

      # sclass (placeheld)

      # module (placeheld)

      #
      # Method (un)definition
      #

      # def (placeheld)

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

      class Class < Tupling__

        COMPONENTS = {
          module_identifier: Component__[
            offset: 0,
            via: :String_via_module_identifier,
          ],
        }

        def to_description
          "class: #{ module_identifier }"
        end

        def module_identifier
          _lazy_auto_getter_
        end
      end

      class Module < Tupling__

        COMPONENTS = {
          module_identifier: Component__[
            offset: 0,
            via: :String_via_module_identifier,
          ],
        }

        def to_description
          "module: #{ module_identifier }"
        end

        def module_identifier
          _lazy_auto_getter_
        end
      end

      class Def < Tupling__

        COMPONENTS = {
          method_name: Component__[
            offset: 0,
            via: :Symbol_via_symbol,
          ],
        }

        def to_description
          "def: #{ method_name }"
        end

        def method_name
          _lazy_auto_getter_
        end
      end

      class Send < Tupling__

        COMPONENTS = {
          method_name: Component__[
            offset: 1,
            type: :symbol,
            via: :Symbol_via_symbol,
          ]
        }

        def method_name= x
          _lazy_auto_setter_ x
        end

        def method_name
          _lazy_auto_getter_
        end
      end

      Items = nil  # NOTE - etc
      IRREGULAR_NAMES = nil  # NOTE - this is NOT structurally where this goes
    end

    # ==

    # ==

    # ==
    # ==
  end
end
# #history-A.2: move oldschool support out so it's just constituents
# #history-A.1: inject comment placeholder for every grammar symbol saw visually
# #born.

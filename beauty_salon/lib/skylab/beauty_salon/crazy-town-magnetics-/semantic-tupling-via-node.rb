module Skylab::BeautySalon

  module CrazyTownMagnetics_::SemanticTupling_via_Node  # see :[#022]

    # experiment.

    class << self

      define_method :specific_tupling_or_generic_tupling_for, -> do

        cache = {}

        class_via_node_type = -> k do
          cache.fetch k do
            cls = Me___.operator_branch.lookup_softly k
            cls ||= GenericTupling___
            cache[ k ] = cls
            cls
          end
        end

        -> n do
          _cls = class_via_node_type[ n.type ]
          _cls.via_node_ n
        end
      end.call

      def operator_branch
        @___ob ||= Home_::CrazyTownMagnetics_::NodeProcessor_via_Module[ Constituents___ ]
      end
    end  # >>

    Tupling__ = ::Class.new  # (re-opens below)

    class Component__

      class << self
        alias_method :[], :new
        undef_method :new
      end  # >>

      def initialize offset: nil, type: nil, via: nil
        @offset = offset
        type and @type_symbol = type
        via and @_via_ = via
        freeze
      end
    end  # (re-opens below)

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
            via: :String_via_module_identifier__,
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
            via: :String_via_module_identifier__,
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
            via: :Symbol_via_symbol__,
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
            via: :Symbol_via_symbol__,
          ]
        }

        def method_name= x
          _lazy_auto_setter_ x
        end

        def method_name
          _lazy_auto_getter_
        end
      end
    end

    # ==

    class GenericTupling___ < Tupling__

      def to_description
        @node.type.id2name
      end
    end

    class Tupling__

      class << self
        alias_method :via_node_, :new
        undef_method :new
      end  # >>

      def initialize n
        @node = n
        # (can't freeze because we derive things lazily e.g #here1) :#here2
      end

      def new_by
        mutable = self.class.allocate
        mutable.__init_as_recorder
        yield mutable
        mutable.__finish_mutation_against @node
      end

      def __init_as_recorder
        @_pending_writes_ = []
      end

      def __finish_mutation_against node

        _a_a = remove_instance_variable :@_pending_writes_

        shallowly_mutable_array = node.children.dup

        _a_a.each do |(d, x)|  # #here3
          shallowly_mutable_array[ d ] = x
        end

        shallowly_mutable_array.freeze

        _new_properties = { location: node.location }

        @node = node.updated(
          nil,
          shallowly_mutable_array,
          _new_properties,
        )

        self  # not freezing because #here2
      end

      def to_code
        # (we know we want to improve this but we are locking it down)
        Home_.lib_.unparser.unparse @node
      end

      # --
      #   these are insane but it's OK. the first time they are called, they
      #   ** REWRITE THE METHOD OF THE ACTUAL CLASS ** (not singleton class)

      def _lazy_auto_setter_ x

        m = caller_locations( 1, 1 )[0].base_label.intern

        cmp = _component_via_symbol m[ 0 ... -1 ].intern

        _method_body = Writers__.const_get( cmp._via_, false )[ m, cmp ]

        _redefine_method _method_body, m

        send m, x  # dogfood
      end

      def _lazy_auto_getter_

        m = caller_locations( 1, 1 )[0].base_label.intern

        cmp = _component_via_symbol m

        _method_body = Readers__.const_get( cmp._via_, false )[ m, cmp ]

        _redefine_method _method_body, m

        send m  # dogfood
      end

      def _redefine_method method_body, m
        cls = self.class
        cls.send :undef_method, m
        cls.send :define_method, m, method_body
      end

      def _component_via_symbol sym
        self.class::COMPONENTS.fetch sym
      end

      # --

      def begin_lineno__
        @node.location.first_line
      end

      def end_lineno__
        @node.location.last_line
      end

      def node_loc  # meh
        @node.loc
      end
    end

    # ==

    Writers__ = ::Module.new
    Readers__ = ::Module.new

    Readers__::String_via_module_identifier__ = -> cmp_sym, cmp do

      Memoize_into_ivar__.call cmp_sym, cmp do |offset|
        -> do
          _sym_a = Symbol_array_via_module_identifier_recursive__[ @node.children[ offset ] ]
          _sym_a.join( COLON_COLON_ ).freeze
        end
      end
    end

    # ~

    Writers__::Symbol_via_symbol__ = -> cmp_sym, cmp do
      -> sym do
        @_pending_writes_.push [ cmp.offset, sym ] ; sym  # per #here3
      end
    end

    Readers__::Symbol_via_symbol__ = -> cmp_sym, cmp do

      Memoize_into_ivar__.call cmp_sym, cmp do |offset|
        -> do
          sym = @node.children[ offset ]
          ::Symbol === sym || fail
          sym
        end
      end
    end

    Memoize_into_ivar__ = -> cmp_sym, cmp, & pp do

      p = pp[ cmp.offset ]
      ivar = :"@___GENERATED_#{ cmp_sym }"
      -> do
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          x = instance_exec( & p )
          instance_variable_set ivar, x  # :#here1
          x
        end
      end
    end

    # ==

    Symbol_array_via_module_identifier_recursive__ = -> n do

      # :#temporary-spot-1

      if :const == n.type
        a = n.children
        2 == a.length || fail
        recu = a[0]
      end

      res_a = if recu
        Symbol_array_via_module_identifier_recursive__[ recu ]
      else
        []
      end

      case n.type
      when :const
        c = a[1]
        ::Symbol === c || fail
        res_a.push c
      when :cbase
        # test_support/lib/skylab/test_support.rb:2
        res_a.push NOTHING_
      when :self
        res_a.push :self  # meh
      else
        self._COVER_ME___weahhhh___
      end
    end

    # ==

    class Component__

      attr_reader(
        :offset,
        :type_symbol,
        :_via_,
      )
    end

    # ==

    COLON_COLON_ = '::'
    Me___ = self

    # ==
    # ==
  end
end
# #history-A.1: inject comment placeholder for every grammar symbol saw visually
# #born.

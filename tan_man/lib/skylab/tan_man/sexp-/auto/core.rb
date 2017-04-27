module Skylab::TanMan

  module Sexp_::Auto

    # an experiment in the automatic generation of abstract syntax trees
    # (classes perchance to have objects) dynamically from the syntax nodes
    # of a parse from a Treetop grammar.

    class << self

      attr_accessor :do_debug

      def debug_stream
        Home_.lib_.some_stderr
      end
    end

    @do_debug = true  # true until you know enough to find this line

    CUSTOM_PARSE_TREE_METHOD_NAME__ = :tree

  extend( module BuildMethods

    # These Build Methods build sexps ("trees") from syntax nodes, possibly
    # creating sexp classes as necessary.
    #
    # This module will typically be used as follows: descendant modules of
    # this module will typically be extended by for e.g. toplevel modules in
    # this library, and possibly generated Sexp_ classes for use in
    # recursive calls to builder methods.

    def [] syntax_node # inheritable API entrypoint
      node2tree syntax_node, nil, nil # no class, no member_name
    end

    def add_instance_methods tree_cls

      mod = instance_methods_module

      if mod
        tree_cls.include mod
      end

      _rule_as_const = Common_::Name::ConversionFunctions::Constantize[ tree_cls.rule ]
      _const_path = [ :RuleEnhancements, _rule_as_const ]  # :#magic-name
      _mod = tree_cls.grammar.anchor_module

      im = _const_path.reduce _mod do |mod_, const|

        mod_.const_defined? const, false or break  # one end of [#078]
        mod_.const_get const, false
      end

      if im
        tree_cls.include im
      end

      NIL
    end

    def build_element_names i # extent: * defs, 1 call

      # For this basic auto sexp implementation for deciding what the
      # member names should be, we 1) take the methods
      # of interest and then 2) strip out the ones that end with numbers
      # with the assumption that they are repeated, with the reasoning that
      # if it were important you would put a label on it.
      # Return a frozen doohah.  Do not rely on generated properties of inf.

      i.methods_of_interest.reject( & With_numbers_ ).freeze
    end

    With_numbers_ = -> member_i { NUM_RX_ =~ member_i.to_s }

    NUM_RX_ = /\d+\z/

    def build_members_of_interest i
      # For this basic auto sexp implementation we assume that the
      # members of interest are one and the same with all the named members.
      # Return an frozen doohah.  Hacks are not yet run.  Gen'd props are.
      # nil gets you all members
      nil
    end

    def build_tree_class i # extent: solo def, 1 call
      members = build_element_names i
      tree_class = ::Class.new(::Struct.new(* members)) # (bc extension modules)
      tree_class.extend module_methods_module
      tree_class._members = members.freeze
      tree_class.expression = i.expression
      tree_class.grammar = i.grammar_facade
      tree_class.rule = i.rule
      tree_class.members_of_interest = build_members_of_interest(i) || members
      add_instance_methods tree_class
      # There might be issues with hacks with more broad patterns intercepting
      # all potential matches with hacks with more narrow patterns so
      # order might be important here.

      i.tree_class and fail('sanity') ; i.tree_class = tree_class # sorry

      hack =   Auto_::Hacks__::HeadTail.match i  # run hacks
      hack ||= Auto_::Hacks__::RecursiveRule.match i
      hack and hack.commit!

      tree_class
    end

    def inference2tree o # extent: solo def, 2 calls
      if o.member and Auto_::Hacks__::MemberName.hack_matches_member_name o.member
        Auto_::Hacks__::MemberName.tree o
      elsif o.element_names_are_inferrable
        tree_class = if o.sexps_module.const_defined?( o.sexp_const, false )
          o.sexps_module.const_get o.sexp_const, false
        else
          o.sexps_module.const_set o.sexp_const, build_tree_class(o)
        end
        tree_class.tree o
      else
        # "puek ahead" assuming this might be a semantic kleene group.
        # if any of the children has an extension module, make a generic list.
        # Note that we have *no* parent tree class per above, and no elem name.
        a = if o._node.elements
          o._node.elements.map do |n|
            Auto_::Inference.get(n, nil, nil)
          end
        end
        if a and a.any? { |x| x.the_expression_name_is_inferrable or x.element_names_are_inferrable }
          list = list_class.new a.length
          a.each_with_index { |_inf, idx| list[idx] = inference2tree(_inf) }
          list
        else
          Auto_::Factories::TextValue.tree o
        end
      end
    end

    def instance_methods_module
      Auto_::InstanceMethods
    end

    def list_class
      Auto_::List
    end

    def module_methods_module
      sexp_builder_anchor_module.const_get :ModuleMethods, false
    end

    def node2tree node, parent_class, member_i # extent: solo def, 2 calls
      # don't call node.tree because that can call this
      inference2tree Auto_::Inference.get(node, parent_class, member_i)
    end

    def sexp_builder_anchor_module # experimental
      Auto_
    end

    self
  end )

  module ModuleMethods

    # This module or descendant modules will be included by generated
    # Sexp_ ("tree") classes.

    include BuildMethods # node2tree et. al

    # extent: solo def, 2 calls

    def element2tree element, member_i
      if element
        if element.respond_to? CUSTOM_PARSE_TREE_METHOD_NAME__
          element.send CUSTOM_PARSE_TREE_METHOD_NAME__  # careful!
        else
          node2tree element, self, member_i
        end
      end  # else typically is trailing optional node
    end

    attr_accessor :expression
    attr_accessor :grammar # a Grammar::Facade
    def _hacks ; @_hacks ||= [] end #debugging-feature-only
    attr_writer :_members # experimental frozen persistent object
    def _members ; @_members ||= members.freeze end
    attr_accessor :members_of_interest

    def parse rule_i, string, err_p=nil  # for hacks
      parser = grammar.build_parser_for_rule rule_i
      syn_node = parser.parse string
      if syn_node
        element2tree syn_node, :"xyzzy_#{ rule_i }"
      elsif err_p
        err_p[ parser ]
      else
        raise Parse_Failure.new( __say_parse_failed parser )
        UNABLE_
      end
    end

    def __say_parse_failed parser
      "#{ name } parse failed - #{ parser.failure_reason || '(no reason?)' }"  # (method is not our name)
    end

    attr_accessor :rule

    def tree inference
      child_a = members_of_interest.map do |member_i|
        element2tree inference._node.send(member_i), member_i
      end
      new( * child_a )
    end
  end

  Parse_Failure = ::Class.new ::RuntimeError

  module InstanceMethods

    # all methods defined here must end in a '_' per [#bs-029.5] - methods that
    # look "normal" is a namespace left open entirely for business (i.e rules
    # in the grammar).

    def is_list_  # is this sexp node a list-like node?
      false
    end

    def duplicate_except_ * except

      Auto_::DuplicatedSexp_via_Members_and_Sexp__.call(
        self.class.new, except, members, self )
    end
  end

  class List < ::Array

    include InstanceMethods

    def duplicate_except_

      d = length

      self._NEVER_CALLED__lost_contact_this_refactor__  # before #history-A

      Auto_::DuplicatedSexp_via_Members_and_Sexp__.call(
        self.class.new(d), :xxxx, d.times.to_a, self )
    end

    def is_list_
      true
    end
  end

  # --*--

  class ContentTextValue

    # Exeperimental: Use this as a sexp builder in your grammars (with []) where
    # you want to flatten a rule into its text value, but rather than use
    # just a string as the Sexp_ node, you want this one extra level in it as
    # a wrapper.
    #
    # This is a tree building strategy that: gives you a struct
    # with a single member called content_text_value that holds
    # the text_value of the syntax node. Experimental!
    #

    include InstanceMethods

    class << self
      def [] syntax_node
        new syntax_node.text_value
      end
      # alias_method :_members, :members
    end

    def initialize x
      @content_text_value = x
    end

    def duplicate_except_
      dup
    end

    def initialize_copy _
      @content_text_value = @content_text_value.dup
      nil
    end

    def [] sym
      if :content_text_value == sym
        @content_text_value
      else
        raise ::NameError, "no member '#{ x }' in struct"
      end
    end

    attr_reader :content_text_value

    def normalized_string
      @content_text_value
    end

    def set_normalized_string string
      fail 'implement me' # as [#053]
    end

    def unparse
      @content_text_value
    end

    def write_bytes_into y
      s = @content_text_value.to_s
      y << s
      s.length
    end
  end

  # --*--

  class Inference

    def initialize * a
      @extension_module_metas, @member, @_node, @_parent_class, @tree_lass = a
    end

    def members
      [ :extension_module_metas, :member, :tree_class, :_node, :_parent_class ]
    end

    attr_reader :extension_module_metas, :member, :_node, :_parent_class

    attr_accessor :tree_class


    # The Inference of a synax node is for "inferring" what Sexp_ class to use
    # for a given node from its extension modules.  We crawl up backwards from
    # the first extension module to infer things like the sexp wrapper module.

    cache = {}  # for some algorithms we might try look-ahead to infer names

    factory = nil

    define_singleton_method :get do |node, parent_class, member_i|
      if cache.key? node.object_id
        i = cache[node.object_id]
        fail 'sanity' if i._parent_class.object_id != parent_class.object_id
        fail 'sanity' if i.member != member_i
        i
      else
        cache[node.object_id] = factory[ node, parent_class, member_i ]
      end
    end

    custom_parse_tree_method_name = CUSTOM_PARSE_TREE_METHOD_NAME__

    factory = -> node, parent_class, member_i do
      a = node.extension_modules
      if a.empty? # possibly a kleene group!
        new nil, member_i, node, parent_class
      else
        # We have at least one extension module so we can definitely infer
        # a const name. But can we infer the names of the elements?
        # We can if we have 'methods of interest' that would come from an
        # extension module  Note, unfortunately, that we have to sidestep
        # the extension module that gets created by us with a method called
        # [custom_parse_tree_method_name]. It's a dodgy move, but this whole
        # house is dodgy o_O
        i = a.length # left vs. right -- ick!!
        last = [0, i - 2].max # any second to last one
        found = nil
        while (i -= 1) >= last
          methods = a[i].instance_methods
          if ! (methods.empty? or
                methods.include?(custom_parse_tree_method_name)) then
            found = i ; break
          end
        end
        metas = a.map { |mod| Auto_::ExtensionModuleMeta[mod] }
        if found
          Auto_::Inference_WithElements.new(
            metas, member_i, node, parent_class, found)
        else
          Auto_::Inference_WithConst.new(
            metas, member_i, node, parent_class)
        end
      end
    end

    def element_names_are_inferrable
      methods_of_interest_can_be_determined
    end

    def the_expression_name_is_inferrable # is the expression name inferrable?
      false
    end

    def members_of_interest
      tree_class.members_of_interest
    end

    def has_members_of_interest
      ! tree_class.nil?
    end

    def methods_of_interest_can_be_determined # are we able to determine methods of interest?
      false
    end

    def rule? # is the rule name inferrable?
      false
    end
  end

  class Inference_WithConst < Inference

    # What can we do with a node with one extension module?

    include Sexp_::Inflection::Methods # symbolize, chomp_digits

    def members
      [ * super, :expression, :rule, :sexp_const, :sexps_module ]
    end

    def expression
      symbolize(sexp_const.to_s).intern
    end

    def the_expression_name_is_inferrable
      true
    end

    def grammar_facade
      const = "#{ expression_extension_module_meta.grammar_const }#{
        }GrammarFacade".intern
      if ! anchor_module.const_defined? const, false
        anchor_module.const_set( const,
          Sexp_::Grammar::Facade.new( anchor_module,
            expression_extension_module_meta.grammar_const ) )
      end
      anchor_module.const_get const, false
    end

    def rule
      symbolize(expression_extension_module_meta.tail_stem.to_s).intern
    end

    def rule?
      true
    end

    # Given that the extension modules Foo0, Foo1, Foo2 exist, we infer that
    # there is a non-terminal "foo" for which we will use a sexp class
    # whose constant will  be "Foo" (in some module); and the nonterminal
    # symbol has two constituent child symbols Foo0 and Foo1, for which we will
    # also make Sexp_ classes with those same names. (So note then that there
    # will *not* be a sexp class called Foo2, rather we just call that one Foo.)
    #
    # (In such a series, the "outermost" node gets the highest number.)
    #
    # So in this example, (using a notation where:
    #
    #   <first em name> => <sexp const name>
    #
    # ) we get:
    #
    #   Foo0 => Foo0, Foo1 => Foo1, BUT : Foo2 => Foo

    def sexp_const
      ( SEXP__.fetch grammar_module do |grammar_module|
        SEXP__[ grammar_module ] = (
         ::Hash.new do |hsh, const|
            stem = chomp_digits const
            arr = (
              STEM__.fetch grammar_module do |gram_mod|
                STEM__[gram_mod] = (
                  ::Hash.new do |h, stm|
                    i = 0 ; a = [ ] ; gm = gram_mod
                    loop do
                      a.push "#{ stm }#{ i }".intern
                      gm.const_defined? "#{ stm }#{  i += 1  }" or break
                    end
                    h[ stm ] = a
                  end
                )
              end
             )[ stem ]
            hsh[const] = arr.last == const ? stem.intern : const
          end
        )
      end )[ expression_extension_module_meta.tail_const ]
    end

    STEM__ = {}  # grammar_mod => :Foo => [:Foo0, :Foo1, :Foo2]

    SEXP__ = {}  # grammar_mod => { :Foo3 => :Foo, :Foo2 => :Foo2, ... }

    def sexps_module
      # auto-vivify a module to hold generated sexps
      anchor_module.const_defined?( :Sexps, false ) ?
        anchor_module.const_get( :Sexps, false ) :
        anchor_module.const_set( :Sexps, ::Module.new )
    end

  private

    def anchor_module
      expression_extension_module_meta.anchor_module
    end

    def expression_extension_module_meta
      extension_module_metas.last
      # to see why this is last and not first, see test grammr 60
    end

    def grammar_module
      expression_extension_module_meta.grammar_module
    end
  end

  class Inference_WithElements < Inference_WithConst

    def initialize *a, methods_idx
      @methods_idx = methods_idx
      super(* a )
    end

    def members
      [ * super, :methods_of_interest ]
    end

    def methods_of_interest
      extension_module_metas[ @methods_idx ].module.instance_methods
    end

    def methods_of_interest_can_be_determined
      true
    end
  end

  class ExtensionModuleMeta

    # There are so many inflection-heavy hacks going on that it is useful
    # to have this wrapper around extension modules.  Note we flyweight them.

    include Sexp_::Inflection::Methods

    cache = ::Hash.new { |h, mod| h[mod] = new mod }

    define_singleton_method :[] do |mod|
      cache[mod]
    end

    def initialize mod
      @module = mod
    end

    def anchor_module
      @anchor_module ||= bld_anchor_mod
    end

    def grammar_const
      prts[ -2 ]
    end

    def grammar_module
      @grammar_module ||= anchor_module.const_get(grammar_const, false)
    end

    def inspect #debugging-feature-only
      "#<ExtMod:#{tail_const}>"
    end

    attr_reader :module

    def tail_const
      @tail_const ||= prts.last.intern
    end

    def tail_stem
      @tail_stem ||= chomp_digits(tail_const)
    end

  private

    def bld_anchor_mod
      Home_.lib_.module_lib.value_via_parts_and_relative_path prts, '../..'
    end

    def prts
      @prts ||= @module.name.split CONST_SEP_
    end
  end

  # --*--

  Factories = ::Module.new  # experimental namespace for 'static' factories

  module Factories::TextValue

    extend module Methods

      def tree o
        s = o._node.text_value
        s if EMPTY_S_ != s  # easier for boolean logic
      end

      self
    end
  end

  Auto_ = self

  # --*--

  module Lossless

    # "lossless" means the sexp can recreate faithfully (losslessly) the
    # entirety of the source input string.
    #

  module BuildMethods

    include Auto_::BuildMethods

    def build_element_names i # extent: * defs, 1 call

      # This is ridiculously sinful but useful (experimental, too):
      #
      # In theory, for any given syntax node that corresponds to a rule
      # component (that is, the syntax node has an extension module that
      # we can derive the rule name and component number from), such syntax
      # nodes will always have a fixed number of (possibly nil) children
      # elements (specifically, it has an "elements" array).
      #
      # (As a corollary, then, the syntax nodes that represent Kleene groups
      # do not have extension modules -- they have a variable number of
      # elements.  All of this might be wrong.)
      #
      # So here's the sinful part: we use object_id's of child syntax
      # nodes to determine positionally which node labels go where.
      # Those children elements without easily derivable names will be
      # labeled e0..eN, where N is the offset of the element (so the N's
      # of the eN elements will not necessarily be contiguous numbers.)

      node_id_to_method = { }
      # first iterate over the methods of interest
      i.methods_of_interest.each do |meth|
        _node = i._node.send(meth) or fail('sanity - member of int. must exist')
        node_id_to_method[_node.object_id] = meth
      end
      # then iterate over all the elements
      i._node.elements.each_with_index.map do |syn_node, idx|
        node_id_to_method[syn_node.object_id] || "e#{idx}".intern
      end
    end

    def build_members_of_interest i
      i.methods_of_interest.reject( & With_numbers_ ).freeze # again, sic
    end

    def instance_methods_module
      Auto_::Lossless::InstanceMethods
    end

    def list_class
      Auto_::Lossless::List
    end
  end

  extend BuildMethods

  module ModuleMethods
    include Auto_::ModuleMethods
  end

  module InstanceMethods

    include Auto_::InstanceMethods

    def description
      unparse
    end

    def unparse
      y = []
      write_bytes_into y
      y.join EMPTY_S_
    end

    def write_bytes_into y
      d = 0
      each do |el|
        el || next
        if el.respond_to? :ascii_only?
          y << el
          d += el.length
        elsif el.respond_to? :write_bytes_into
          d += el.write_bytes_into y
        else
          self._STRANGE_SHAPE__for_element__not_string__not_component__  # #todo
        end
      end
      d
    end
  end

  class List < Auto_::List
    include Auto_::Lossless::InstanceMethods
  end

  # --*--

  Recursive = ::Module.new

  module Recursive::BuildMethods

    include BuildMethods

    Recursive.extend self # a toplevel entrypoint for these builder methods

    def sexp_builder_anchor_module
      Recursive
    end
  end

  module Recursive::ModuleMethods

    include Lossless::ModuleMethods

    include Lossless::Recursive::BuildMethods  # for #recursive call

    def tree inference # the #recursive call
      elements = inference._node.elements
      (_members.length == elements.length) or fail('sanity: wrong # of els')
      prev = nil
      _children = elements.zip(_members).map do |element, member_i|
        tree = element2tree element, member_i
        begin                                  # hack alert - for performance &
          prev.respond_to?( :ascii_only? ) or break  # readability for now we do this
          prev.include? 'example' or break     # ugliness like so
          hack = Sexp_::Prototype.match prev, tree, self, member_i
          hack or break                        # the hack might create a node
          tree = hack.commit!                  # where before there was none
        end while nil
        prev = tree # (used as result of map block)
      end
      new(* _children)
    end
  end
  end
  end
end
# #history-A (can be temporary) as referenced

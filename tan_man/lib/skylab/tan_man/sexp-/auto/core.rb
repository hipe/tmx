module Skylab::TanMan

  module Sexp_::Auto

    # an experiment in the automatic generation of abstract syntax trees
    # (classes perchance to have objects) dynamically from the syntax nodes
    # of a parse from a Treetop grammar.

    # we hate disclaimers like this but this library (deeply historic)
    # deserves one: this was architected long before we started practicing
    # "composition over inheritance" and so in its heyday it became
    # something of a mixin-module soup. although we have tried to modernize
    # naming, this underlying architecture remains, and can be confusing.

    # the three main exposure points (parts of its public API) of the
    # subject are "sexp auto" (the toplevel module that contains everything),
    # "sexp auto lossless", and "sexp auto lossess recursive"; each
    # manifesting as a module. this file develops them in a cascade, with
    # each next facility introducing its new mechanic while depending on the
    # previous facility.

    # in its implementation, each facility might typically have its own
    # variant of some or all of these components: a "build methods", a
    # "module methods", and an "instance methods" module. new in this
    # refactor, all (counting) would-be-12-ish of these modules are
    # housed flatly alongside each other in the expected order, and each
    # has a single const name that reflects both the component's purpose
    # and (for components of the latter two facilities) its facility
    # affilition.

    CUSTOM_PARSE_TREE_METHOD_NAME__ = :_to_final_parse_tree_

  module BuildMethods_

    # These Build Methods build sexps ("trees") from syntax nodes, possibly
    # creating sexp classes as necessary.
    #
    # This module will typically be used as follows: descendant modules of
    # this module will typically be extended by for e.g. toplevel modules in
    # this library, and possibly generated sexp classes for use in
    # recursive calls to builder methods.

    def [] syntax_node  # inheritable API entrypoint
      _tree_via_syntax_node syntax_node, nil, nil  # no class, no member_name
    end

    def __add_instance_methods tree_cls

      mod = _instance_methods_module_

      if mod
        tree_cls.include mod
      end

      _rule_as_const = Common_::Name::ConversionFunctions::Constantize[ tree_cls.rule_symbol ]
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

    def _build_element_names_ o

      # For this basic auto sexp implementation for deciding what the
      # member names should be, we 1) take the methods
      # of interest and then 2) strip out the ones that end with numbers
      # with the assumption that they are repeated, with the reasoning that
      # if it were important you would put a label on it.
      # Return a frozen doohah.  Do not rely on generated properties of inf.

      o.to_methods_of_interest.reject( & With_numbers__ ).freeze
    end

    def _build_members_of_interest_ o

      # For this basic auto sexp implementation we assume that the
      # members of interest are one and the same with all the named members.
      # Return an frozen doohah.  Hacks are not yet run.  Gen'd props are.
      # nil gets you all members

      NOTHING_
    end

    def __build_tree_class o  # o = "inference with elements"

      members = _build_element_names_( o ).freeze

      moi = _build_members_of_interest_ o
      if ! moi
        moi = members  # hi.
      end

      _sct_class = Give_it_a_name___[ ::Struct.new( * members ) ]  # :#cov2.3

      cls = ::Class.new _sct_class

      cls.extend _module_methods_module_

      cls.__init_sexp_class(
        moi,
        members,
        o.__build_grammar_facade,
        o.__to_expression_symbol,
        o.to_rule_symbol_,
      )

      __add_instance_methods cls

      # There might be issues with hacks with more broad patterns intercepting
      # all potential matches with hacks with more narrow patterns so
      # order might be important here.

      o.tree_class && self._SANITY  # eew
      o.tree_class = cls

      hack =   Auto_::Hacks__::HeadTail.match_inference o  # run hacks
      hack ||= Auto_::Hacks__::RecursiveRule.match_inference o
      if hack
        hack.call
      end

      cls
    end

    def _tree_via_inference o

      yes = Auto_::Hacks__::MemberName.tree_proc_via_inference__ o
      if yes
        yes[]

      elsif o.element_names_are_inferrable

        mod = o._sexps_module ; c = o._sexp_const

        if mod.const_defined? c, false
          cls = mod.const_get c, false
        else
          cls = __build_tree_class o
          mod.const_set c, cls
        end

        cls.final_parse_tree_via_inference_ o
      else

        # "peek ahead" assuming this might be a semantic kleene group :#here2.
        # if any of the children has an extension module, make a generic list.
        # Note that we have *no* parent tree class per above, and no elem name.

        sns = o.syntax_node.elements
        if sns
          a = sns.map do |sn|
            Inference_for_[ sn ]
          end
        end

        _yes = if a
          a.any? do |inf|
            inf.the_expression_name_is_inferrable || inf.element_names_are_inferrable
          end
        end

        if _yes

          list = _list_class_.new a.length

          a.each_with_index do |inf, d|
            list[ d ] = _tree_via_inference inf
          end

          list
        else
          s = o.syntax_node.text_value
          if s.length.nonzero?  # easier for boolean logic to map these out
            s
          end
        end
      end
    end

    def _instance_methods_module_
      InstanceMethods_
    end

    def _list_class_
      List_
    end

    def _module_methods_module_
      ModuleMethods_
    end

    def _tree_via_syntax_node sn, parent_class, member_sym

      # don't call node._to_final_parse_tree_ because that can call this

      _inf = Inference_for_[ sn, parent_class, member_sym ]
      _tree_via_inference _inf
    end
  end

  extend BuildMethods_

  Give_it_a_name___ = -> do
    d = 0
    -> x do
      Generated___.const_set :"Rule_#{ d += 1 }", x
      x
    end
  end.call

  Generated___ = ::Module.new

  module ModuleMethods_

    # This module or descendant modules will be included by generated
    # sexp ("tree") classes.

    include BuildMethods_

    def __init_sexp_class members_of_interest, frozen_members, grammar_facade, expression_sym, rule_sym

      @members_of_interest = members_of_interest
      @_use_members = frozen_members
      @grammar = grammar_facade
      @expression_symbol = expression_sym
      @rule_symbol = rule_sym
      NIL
    end

    def tree_via_syntax_node_ sn, member_sym
      if sn
        if sn.respond_to? CUSTOM_PARSE_TREE_METHOD_NAME__
          sn.send CUSTOM_PARSE_TREE_METHOD_NAME__  # careful!
        else
          _tree_via_syntax_node sn, self, member_sym
        end
      end  # else typically is trailing optional node
    end

    def parse rule_sym, string, err_p=nil  # for hacks
      parser = grammar.build_parser_for_rule rule_sym
      syn_node = parser.parse string
      if syn_node
        tree_via_syntax_node_ syn_node, :"xyzzy_#{ rule_sym }"
      elsif err_p
        err_p[ parser ]
      else
        raise ParseFailure___.new __say_parse_failed parser
        UNABLE_
      end
    end

    def __say_parse_failed parser
      "#{ name } parse failed - #{ parser.failure_reason || '(no reason?)' }"  # (method is not our name)
    end

    def final_parse_tree_via_inference_ inference

      child_a = members_of_interest.map do |member_sym|

        _x = inference.syntax_node.send member_sym

        tree_via_syntax_node_ _x, member_sym
      end

      new( * child_a )
    end

    def _use_members
      @_use_members ||= members.freeze
    end

    attr_reader(
      :expression_symbol,
      :grammar,  # a grammar facade
      :members_of_interest,
      :rule_symbol,
    )
  end

  ParseFailure___ = ::Class.new ::RuntimeError

  module InstanceMethods_

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

  class List_ < ::Array

    include InstanceMethods_  # it appears that we overwrite every method, but this is necessary .. why? #todo

    def duplicate_except_
      self._WAS_NOT_COVERED__but_read_me__  # in #tombstone-A.2 is beginning of a rabbit hole
    end

    def is_list_
      true
    end
  end

  # --*--

  class ContentTextValue  # yes, #public-API

    # Exeperimental: Use this as a sexp builder in your grammars (with []) where
    # you want to flatten a rule into its text value, but rather than use
    # just a string as the sexp node, you want this one extra level in it as
    # a wrapper.
    #
    # This is a tree building strategy that: gives you a struct
    # with a single member called content_text_value that holds
    # the text_value of the syntax node. Experimental!
    #

    include InstanceMethods_

    class << self
      def [] syntax_node
        new syntax_node.text_value
      end
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

    def normal_content_string_

      # (no need to unescape here - it's already unescaped)

      @content_text_value
    end

    def set_normalized_string string
      fail 'implement me' # as [#053]
    end

    def unparse
      @content_text_value
    end

    def write_bytes_into y
      s = @content_text_value
      if s
        s.ascii_only?  # #todo
        y << s
        s.length
      else
        self._COVER_ME
        0
      end
    end

    attr_reader(
      :content_text_value,
    )
  end

  # --*--

  Inference_for_ = -> do

    cache = {}  # for some algorithms we look-ahead to infer names #here2

    -> sn, parent_class=nil, member_sym=nil do
      o = cache[ sn.object_id ]
      if o
        o.parent_class.object_id == parent_class.object_id || self._SANITY
        member_sym == o.member_symbol || self._SANITY
        o
      else
        o = Build_inference___[ sn, parent_class, member_sym ]
        cache[ sn.object_id ] = o
        o
      end
    end
  end.call

  Build_inference___ = -> sn, parent_class, member_sym do

    a = sn.extension_modules

    if a.length.zero?  # possibly a kleene group

      Inference_.new nil, member_sym, sn, parent_class
    else
      # from this one extension module we can infer a const name. but can we
      # infer the names of its elements? we can if we have "methods of
      # interest" that would come from an extension module. hackishly avoid
      # oru own extension module for checking for the existence of our magic
      # name..

      d = a.length  # left vs. right -- ick!!
      last = [ 0, d - 2 ].max  # any second to last one

      while ( d -= 1 ) >= last

        methods = a[ d ].instance_methods
        if methods.length.zero?
          next
        end
        if methods.include? CUSTOM_PARSE_TREE_METHOD_NAME__
          next
        end
        found_d = d
        break
      end

      metas = a.map { |mod| ExtensionModuleReflection___[ mod ] }

      if found_d
        InferenceWithElements___.new(
          found_d, metas, member_sym, sn, parent_class )
      else
        InferenceWithConst__.new(
          metas, member_sym, sn, parent_class )
      end
    end
  end

  class Inference_

    # this is perhaps the workhorse node of the whole library: the
    # "inference" of a synax node is for "inferring" what sexp class to use
    # for a given node from its extension modules.  We crawl up backwards
    # from the first extension module to infer things like the sexp wrapper
    # module.

    def initialize metas, member_sym, syntax_node, parent_class

      @extension_module_metas = metas
      @member_symbol = member_sym
      @parent_class = parent_class
      @syntax_node = syntax_node
    end

    attr_writer(
      :tree_class,
    )

    def element_names_are_inferrable
      methods_of_interest_can_be_determined
    end

    def members_of_interest
      @tree_class.members_of_interest
    end

    def has_members_of_interest
      @tree_class
    end

    attr_reader(
      :extension_module_metas,
      :member_symbol,
      :parent_class,
      :syntax_node,
      :tree_class,
    )

    def the_expression_name_is_inferrable  # is the expression name inferrable?
      false
    end

    def methods_of_interest_can_be_determined  # are we able to determine methods of interest?
      false
    end

    def is_rule  # is the rule name inferrable?
      false
    end
  end

  class InferenceWithConst__ < Inference_

    # What can we do with a node with one extension module?

    def __to_expression_symbol
      Symbol_via_const__[ _sexp_const ]
    end

    def the_expression_name_is_inferrable
      true
    end

    def __build_grammar_facade

      head_const = _expression_extension_module_meta.grammar_const
      c = :"#{ head_const }GrammarFacade"

      mod = anchor_module
      if mod.const_defined? c
        mod.const_get c, false
      else
        faça = Sexp_::Grammar::Facade.new mod, head_const
        mod.const_set c, faça
        faça
      end
    end

    def to_rule_symbol_
      Symbol_via_const__[ _expression_extension_module_meta.tail_stem ]
    end

    def is_rule
      true
    end

    # Given that the extension modules Foo0, Foo1, Foo2 exist, we infer that
    # there is a non-terminal "foo" for which we will use a sexp class
    # whose constant will be "Foo" (in some module); and the nonterminal
    # symbol has two constituent child symbols Foo0 and Foo1, for which we will
    # also make sexp classes with those same names. (so note then that there
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

    -> do

      # (as an amusing and possibly didactic point of history (perhaps for
      # some kind of case-study), the pre-refactor of what used to be in this
      # scope (#tombstone-A.2) was undecipherable #eyeblood, but also it was
      # more than 3x shorter.  it's still a bit painful..)

      stem_const_via_native_const_via_grammar_mod = {}
        # grammar_mod => { :Foo3 => :Foo, :Foo2 => :Foo2, ... }

      define_method :_sexp_const do
        grammar_mod = grammar_module
        _h = stem_const_via_native_const_via_grammar_mod.fetch grammar_mod do
          x = Hash_of__use_const_via_given_const__[ grammar_mod ]
          stem_const_via_native_const_via_grammar_mod[ grammar_mod ] = x
          x
        end
        _const = _expression_extension_module_meta.tail_const
        _h[ _const ]
      end

      Hash_of__use_const_via_given_const__ = -> grammar_mod do
        ::Hash.new do |h, const|
          x = Find__use_const__via_given_const___[ const, grammar_mod ]
          h[ const ] = x
          x
        end
      end

      Find__use_const__via_given_const___ = -> const, grammar_mod do
        const_head = Chomp_digits__[ const ]
        _a = Consts_via_const_head___[ const_head, grammar_mod ]
        if const == _a.last  # when it would be `FooBar0`, result in `FooBar` instead
          const_head
        else
          const
        end
      end

      native_const_array_via_stem_const_via_grammar_mod = {}
        # grammar_mod => :Foo => [:Foo0, :Foo1, :Foo2]

      Consts_via_const_head___ = -> const_head, grammar_mod do

        # what are the `Foo0`, `Foo1`, `Foo2`, etc for any given `Foo`?
        # since this list is fixed per grammar module, we memoize it there.

        _ary_via_head = native_const_array_via_stem_const_via_grammar_mod.fetch grammar_mod do
          x = Hash_of__consts_via_const__via_grammar_mod___[ grammar_mod ]
          native_const_array_via_stem_const_via_grammar_mod[ grammar_mod ] = x
          x
        end
        _ary_via_head[ const_head ]
      end

      Hash_of__consts_via_const__via_grammar_mod___ = -> grammar_mod do
        ::Hash.new do |h, const_head|
          a = Array_of_defined_consts_via___[ grammar_mod, const_head ]
          h[ const_head ] = a
          a
        end
      end

      Array_of_defined_consts_via___ = -> mod, const_head do

        # determine what the `Foo0`, `Foo1`, `Foo2`, etc are for any given
        # `Foo` in the given module. (i.e solve for N in 0..N). result is
        # the actual array of consts of `Foo0`, `Foo1`, `Foo2` etc.

        a = [] ; d = 0
        const = :"#{ const_head }#{ d }"
        begin
          a.push const
          d += 1
          const = :"#{ const_head }#{ d }"
        end while mod.const_defined? const
        a
      end
    end.call

    def _sexps_module

      # auto-vivify a module for holding generated sexps

      mod = anchor_module
      if mod.const_defined? SEXPS__, false
        mod.const_get SEXPS__, false
      else
        x = ::Module.new
        mod.const_set SEXPS__, x
        x
      end
    end

    SEXPS__ = :Sexps

  private

    def anchor_module
      _expression_extension_module_meta.anchor_module
    end

    def _expression_extension_module_meta
      extension_module_metas.last
      # to see why this is last and not first, see test grammr 60
    end

    def grammar_module
      _expression_extension_module_meta.grammar_module
    end
  end

  class InferenceWithElements___ < InferenceWithConst__

    def initialize methods_idx, *a
      @methods_idx = methods_idx
      super( * a )
    end

    def to_methods_of_interest
      extension_module_metas[ @methods_idx ].module.instance_methods
    end

    def methods_of_interest_can_be_determined
      true
    end
  end

  class ExtensionModuleReflection___

    # There are so many inflection-heavy hacks going on that it is useful
    # to have this wrapper around extension modules.  Note we flyweight them.

    cache = ::Hash.new { |h, mod| h[mod] = new mod }

    define_singleton_method :[] do |mod|
      cache[mod]
    end

    def initialize mod
      @module = mod
    end

    def anchor_module
      @anchor_module ||= __build_anchor_mod
    end

    def grammar_const
      _name_const_strings[ -2 ]
    end

    def grammar_module
      @grammar_module ||= anchor_module.const_get(grammar_const, false)
    end

    def inspect  #debugging-feature-only
      "#<ExtMod:#{ tail_const }>"
    end

    def tail_stem
      @___tail_stem ||= Chomp_digits__[ tail_const ]
    end

    def tail_const
      @___tail_const ||= _name_const_strings.last.intern
    end

    def __build_anchor_mod
      Home_.lib_.module_lib.value_via_parts_and_relative_path _name_const_strings, '../..'
    end

    def _name_const_strings
      @___name_const_strings ||= @module.name.split CONST_SEP_
    end

    attr_reader(
      :module,
    )
  end

  # --*--

    # "lossless" means the sexp can recreate faithfully (losslessly) the
    # entirety of the source input string.
    #

  module LosslessBuildMethods_

    include BuildMethods_

    def _build_element_names_ o

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

      method_via_object_id = {}

      # first, only for the methods of interest make a note of the
      # object ID of the element

      sn = o.syntax_node

      o.to_methods_of_interest.each do |m|
        _sn_ = sn.send m
        _sn_ || self._SANITY__member_must_exist__
        method_via_object_id[ _sn_.object_id ] = m
      end

      # then map each element such that we end up with an array of
      # the member names, variously meaningful or derived

      sn.elements.each_with_index.map do |syn_node, idx|
        method_via_object_id[ syn_node.object_id ] || :"e#{ idx }"
      end
    end

    def _build_members_of_interest_ o
      o.to_methods_of_interest.reject( & With_numbers__ ).freeze  # again, sic
    end

    def _module_methods_module_
      super  # hi.
    end

    def _instance_methods_module_
      LosslessInstanceMethods__
    end

    def _list_class_
      LosslessList___
    end
  end

  module Lossless
    extend LosslessBuildMethods_
  end

  # (there is no longer LosslessModuleMethods :#here1, #history-A.1)

  module LosslessInstanceMethods__

    include InstanceMethods_

    def description
      self._WHERE  # #todo
      unparse
    end

    def unparse
      unparse_into ""
    end

    def unparse_into y
      write_bytes_into y
      y
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

  class LosslessList___ < List_
    include LosslessInstanceMethods__
  end

  # --*--

  module LosslessRecursiveBuildMethods_

    include LosslessBuildMethods_

    def _module_methods_module_
      LosslessRecursiveModuleMethods___
    end

    def _instance_methods_module_
      super  # hi.
    end
  end

  module LosslessRecursive
    extend LosslessRecursiveBuildMethods_
  end

  module LosslessRecursiveModuleMethods___

    include ModuleMethods_  # (because there are no LosslessModuleMethods #here1)

    include LosslessRecursiveBuildMethods_  # for #recursive call

    def final_parse_tree_via_inference_ inference  # the #recursive call

      elements = inference.syntax_node.elements
      mems = _use_members

      mems.length == elements.length || self._SANITY__wrong_number_of_elements__

      # hack alert - for performance & readability for now we do this
      # ugliness.. the hack might create a node where before there was none

      prev = nil

      _children = elements.zip( mems ).map do |syntax_node, member_sym|

        tree = tree_via_syntax_node_ syntax_node, member_sym

        if Is_string_that_includes_the_special_string___[ prev ]
          hack = Sexp_::Prototype.match prev, tree, self, member_sym
          if hack
            tree = hack.commit!
          end
        end

        prev = tree  # (used as result of map block)
      end

      new( * _children )
    end

    Is_string_that_includes_the_special_string___ = -> do
      example_s = 'example'
      -> prev do
        if prev.respond_to? :ascii_only?
          prev.include? example_s
        end
      end
    end.call
  end

    # ==

    Symbol_via_const__ = -> do
      rx = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/
      -> nt_const_sym do
        nt_const_sym.id2name.gsub rx do
          "_#{ $1 || $2 }"
        end.downcase.intern
      end
    end.call

    Chomp_digits__ = -> do
      rx = /\A(?<stem>[^0-9]+)[0-9]+\z/
      -> const do
        md = rx.match const
        md || self._SANITY__expecting_this_to_end_in_digits__
        md[ :stem ].intern
      end
    end.call

    With_numbers__ = -> do
      rx = /\d+\z/
      -> member_sym do
        rx =~ member_sym
      end
    end.call

    # ==

    Auto_ = self

    # ==
    # ==
  end
end
# :#tombstone-A.3 debugging output to stderr
# :#tombstone-A.2 (can be temporary) (as referenced 2x)
# :#history-A.1 (can be temporary) (as referenced)
# #history-A (can be temporary) as referenced

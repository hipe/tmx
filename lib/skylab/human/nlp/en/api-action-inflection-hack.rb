module Skylab::Human

module NLP::EN::API_Action_Inflection_Hack  # see [#018]. was: [#sl-123] exempt

  # This is a weird old (and fun) #experiment that is salvaged from porcelain.
  # Watch for it to cross-fertilize with instances of action inflection
  # happening elsewhere as [#018].

  # See notes at `NLP::EN::POS::Noun` to see how far down the
  # inflection-hacking rabbit hole goes.

  # Don't be decieved, we don't want self.extended [#sl-111] pattern here,
  # you just extend this module and you get this one knob:


  def inflection
    # Classes or modules that extend this badboy get an `inflection` knob
    # that does stuff..

    @inflection ||= Inflection.new self
  end

  module Dupe                     # (apparently some mess of a dsl for deep-
                                  # duping)

    def self.extended mod # [#sl-111]
      mod.send :include, Dupe::InstanceMethods
    end

    def dupes * a
      @dupes ||= bld_dupe_array
      @dupes.concat( a - @dupes )
    end

    attr_writer :dupes

    private def bld_dupe_array
      anc = Dupe.detect_ancestor_respond_to self, :dupes
      if anc
        acn.dupes.dup
      else
        []
      end
    end

    -> o do

      o[ :detect_ancestor_respond_to ] = -> klass, method_i do
        # will need to change if we want to support modules
        klass.ancestors[ 1 .. -1 ].detect do |mod|
          mod.respond_to? method_i
        end
      end

    end.call -> do
      o = -> i, p do
        define_singleton_method i, -> * a do
          if a.length.zero?
            p
          else
            p[ * a ]
          end
        end
      end
      class << o
        alias_method :[]=, :call
      end
      o
    end.call
  end

  module Dupe::InstanceMethods

    def dupes *a
      @dupes ||= self.class.dupes.dup
      @dupes.concat(a - @dupes)
    end


    attr_writer :dupes


    def dupe! other
      other.dupes.each do |prop|
        othr = other.send prop

        if othr.respond_to? :dupe!
          send( prop ).dupe! othr
          next
        end

        if ! instance_variable_defined?( "@#{ prop }" ) ||
             instance_variable_get( "@#{ prop }" ).nil?
        then
          # note it's a copy by reference (except ofc. for final values)
          instance_variable_set "@#{ prop }", othr
        end
      end
    end
  end

  Brackets_method__ = -> mod do
    mod.module_exec do
      def [] i
        send self.class::H__.fetch( i )
      end
      #
      self::H__ = H__
    end
  end
  H__ = { noun: :noun, verb: :verb }.freeze

  class Lexemes # this is the core of the hack

    extend Dupe

    def noun
      @noun ||= bld_noun
    end

    def bld_noun  # #note-130
      chain = Home_.lib_.basic::Module.chain_via_module @klass
      mod = chain[ -2 ].value_x
      mod_ = chain[ -3 ].value_x
      if mod_ && mod_.respond_to?( :unbound_action_box )
        if mod == mod_.unbound_action_box
          do_hop = true
        end
      end

      word = Callback_::Name.
        via_const( chain[ do_hop ? -3 : -2 ].name_symbol ).as_human.dup

      word.gsub! PLURAL_RX__, EMPTY_S_  # :+#singularize-hack
      NLP::EN::POS::Noun[ word ]
    end

    PLURAL_RX__ = /s\z/

    def noun= x
      self.dupes |= [:noun] # duplicate this setting down to subclasses
      use = if x.respond_to? :plural then x else
        NLP::EN::POS::Noun[ x ]
      end
      @noun = use
      x
    end

    define_method :verb do
      @verb ||= NLP::EN::POS::Verb[ Callback_::Name.via_const( name_pieces.last ).as_human ]
    end

    def verb= x
      # note we don't bother with duping this down to subclasses!
      use = if x.respond_to? :preterite then x else
        NLP::EN::POS::Verb[ x ]
      end
      @verb = use
      x
    end

    Brackets_method__[ self ]

  private

    def initialize klass
      @klass = klass
    end

    def name_pieces
      @name_pieces ||= @klass.to_s.split CONST_SEP_
    end

    CONST_SEP_ = '::'
  end

  class Inflect

    # for setting how to inflect things

    Home_.lib_.parse::DSL_DSL.enhance self do
      atom_accessor :noun
      atom_accessor :verb
    end

    def initialize
      @noun = :singular
      @verb = :lemma
    end

    Brackets_method__[ self ]
  end

  class Inflected

    # DSL-ish wrapper for getting the inflected string of the component

    def noun
      @inflection.lexemes.noun.send @inflection.inflect.noun
    end

    def verb
      @inflection.lexemes.verb.send @inflection.inflect.verb
    end

  private

    def initialize inflection
      @inflection = inflection
    end
  end

  class Inflection
    extend Dupe

    dupes :lexemes

    def inflect
      @inflect ||= Inflect.new
    end

    def inflected
      @inflected ||= Inflected.new self
    end

    def lexemes
      @lexemes ||= Lexemes.new @klass
    end

    def get_bound_pos_for_exponent_i i

      _lex = lexemes[ i ]
      _inf_i = inflect[ i ]
      _lex << _inf_i
    end

  private

    def initialize klass
      @klass = klass
      anc = Dupe.detect_ancestor_respond_to klass, :inflection
      if anc
        dupe! anc.inflection
      end
    end
  end
end
end

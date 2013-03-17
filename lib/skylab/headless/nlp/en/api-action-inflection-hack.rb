module Skylab::Headless::NLP::EN::API_Action_Inflection_Hack # [#sl-123] exempt

  # This is a weird old (and fun) #experiment that is salvaged from porcelain.
  # Watch for it to cross-fertilize with instances of action inflection
  # happening elsewhere as [#hl-018].

  # See notes at `NLP::EN::POS::Noun` to see how far down the
  # inflection-hacking rabbit hole goes.

  # Don't be decieved, we don't want self.extended [#sl-111] pattern here,
  # you just extend this module and you get this one knob:

  MetaHell = ::Skylab::MetaHell
  NLP = ::Skylab::Headless::NLP # (future-proof parts in case not [#sl-123])

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

    def dupes *a
      @dupes ||= begin
         anc = Dupe::FUN.detect_ancestor_respond_to[ self, :dupes ]
         if anc
           dupes = anc.dupes.dup
         else
           dupes = [ ]
         end
         dupes
      end
      @dupes.concat( a - @dupes )
    end

    attr_writer :dupes

    o = { }

    o[:detect_ancestor_respond_to] = -> klass, method do
      # will need to change if we want to support modules
      klass.ancestors[1..-1].detect { |m| m.respond_to? method }
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

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

  class Lexemes # this is the core of the hack

    extend Dupe

    rx = /([a-z])([A-Z])/

    humanize = -> str do
      str.gsub( rx ){ "#{$1} #{$2}" }.downcase
    end
                                  # automagic is not without its price: in
                                  # order to infer a noun stem from your
                                  # action class name, we will start by assuming
                                  # it is in either the second- or third-to-
    define_method :noun do        # last 'name piece.' (assumption [#hl-018])
      @noun ||= begin             # To find the appropriate action constants
        seen = [ ] ; hop = false  # for the noun, we crawl down the entire
        name_pieces.reduce( ::Object ) do |m, x| # const tree and back up again
          m.const_defined?( x, false ) or break
          y = m.const_get x, false # part-way bc of [#hl-035] - if there is a
          seen.push y             # pure box module, (that is, a module whose
          y                       # only purpose is to be a clean namespace
        end                       # to hold only constituent items), then such
        ok = seen.length.zero?
        ok ||= -> do              # modules usually do *not* have business
          res = seen[-2]          # semantics - that is, they sometimes do *not*
          begin                   # have a meaningful name as far as we're
            o = seen[-3] or break # concerned here. So if there is such a
            o.respond_to?( :action_box_module ) or break # module, we want to
            o.action_box_module == res or break # `hop` over it, thereby
            hop = true            # not using it as a basis for our
          end while nil           # noun stem, but rather the const above it
          true
        end.call
        if ok
          word = humanize[ name_pieces[ hop ? -3 : -2 ] ]
          if 's' == word[-1]      # #singularize hack
            word = word.sub( /s\z/, '' )
          end
          NLP::EN::POS::Noun[ word ]
        end
      end
    end

    def noun= x
      self.dupes |= [:noun] # duplicate this setting down to subclasses
      use = if x.respond_to? :plural then x else
        NLP::EN::POS::Noun[ x.to_s ]
      end
      @noun = use
      x
    end

    define_method :verb do
      @verb ||= NLP::EN::POS::Verb[ humanize[ name_pieces.last ] ]
    end

    def verb= x
      # note we don't bother with duping this down to subclasses!
      use = if x.respond_to? :preterite then x else
        NLP::EN::POS::Verb[ x ]
      end
      @verb = use
      x
    end

  protected

    def initialize klass
      @klass = klass
    end

    attr_reader :klass

    def name_pieces
      @name_pieces ||= klass.to_s.split '::'
    end
  end

  class Inflect

    # for setting how to inflect things

    extend MetaHell::DSL_DSL

    dsl_dsl do
      atom_accessor :noun
      atom_accessor :verb
    end

    def initialize
      @noun = :singular
      @verb = :lemma
    end
  end

  class Inflected

    # DSL-ish wrapper for getting the inflected string of the component

    def noun
      @inflection.lexemes.noun.send @inflection.inflect.noun
    end

    def verb
      @inflection.lexemes.verb.send @inflection.inflect.verb
    end

  protected

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

  protected

    def initialize klass
      @klass = klass
      anc = Dupe::FUN.detect_ancestor_respond_to[ klass, :inflection ]
      if anc
        dupe! anc.inflection
      end
    end
  end
end

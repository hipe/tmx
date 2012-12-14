module Skylab::Headless::NLP::EN::API_Action_Inflection_Hack # [#sl-123] exempt

  # This is a weird old (and fun) #experiment that is salvaged from porcelain.
  # Watch for it to cross-fertilize with instances of action inflection
  # happening elsewhere as [#hl-018].

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



  class StringAsStem < ::String
    class << self
      alias_method :[], :new
    end
  end



  class VerbStem < StringAsStem
    def progressive
      "#{ self }ing"
    end
  end



  class NounStem < StringAsStem
    def plural
      "#{ self }s" # fine for now
    end

    def singular
      to_s       # but be careful!
    end
  end



  class Stems # this is the core of the hack
    extend Dupe

    def initialize klass
      @klass = klass
    end

    def name_pieces
      @name_pieces ||= begin # #todo break the below and then etc.
        @klass.to_s.gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase.split('::')
      end
    end

    def noun
      @noun ||= NounStem[ name_pieces[-2] ]
    end

    def noun= mixed
      self.dupes |= [:noun] # duplicate this setting down to subclasses
      ::String === mixed and mixed = NounStem[ mixed ]
      @noun = mixed
    end

    def verb
      @verb ||= VerbStem[ name_pieces.last ]
    end
  end



  class Inflect
    # for setting how to inflect things
    #

    def noun *a
      if 0 == a.length
        @noun ||= :singular
      else
        send :noun=, *a
      end
    end

    attr_writer :noun
  end



  class Inflected
    # for getting the inflected thing
    #

    attr_reader :inflection

    def noun
      inflection.stems.noun.send inflection.inflect.noun
    end

  protected

    def initialize inflection
      @inflection = inflection
    end
  end



  class Inflection
    extend Dupe

    dupes :stems

    def inflect
      @inflect ||= Inflect.new
    end

    def inflected
      @inflected ||= Inflected.new self
    end

    def stems
      @stems ||= Stems.new @klass
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

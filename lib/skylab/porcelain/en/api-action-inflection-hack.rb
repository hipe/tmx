module Skylab::Porcelain
  module En::ApiActionInflectionHack
    def inflection
      @inflection ||= En::ApiActionInflectionHack::Inflection.new(self)
    end
  end
end

module Skylab::Porcelain::En::ApiActionInflectionHack
  module Dupe
    def self.extended mod
      mod.send(:include, InstanceMethods)
    end
    def dupes *a
      @dupes ||= (anc = detect_ancestor_respond_to(self, :dupes) and anc.dupes.dup) || []
      @dupes.concat(a - @dupes)
    end
    attr_writer :dupes
  end
  module Dupe::UtilityMethods # for both classes and instances
    def detect_ancestor_respond_to klass, method
      # will need to change if we want to support modules
      klass.ancestors[1..-1].detect { |m| m.respond_to?(method) }
    end
  end
  module Dupe
    include UtilityMethods
  end
  module Dupe::InstanceMethods
    include Dupe::UtilityMethods
    def dupes *a
      @dupes ||= self.class.dupes.dup
      @dupes.concat(a - @dupes)
    end
    attr_writer :dupes
    def dupe! other
      other.dupes.each do |prop|
        othr = other.send(prop)
        if othr.respond_to?(:dupe!)
          send(prop).dupe! othr
        elsif ! instance_variable_defined?("@#{prop}") or instance_variable_get("@#{prop}").nil?
          instance_variable_set("@#{prop}", othr) # copy by reference (or value if it's a final value)
        end
      end
    end
  end
  class StringAsStem < String
    class << self
      alias_method :[], :new
    end
  end

  class VerbStem < StringAsStem
    def progressive
      "#{self}ing"
    end
  end

  class NounStem < StringAsStem
    def plural
      "#{self}s" # fine for now
    end
    def singular
      to_s       # but be careful!
    end
  end

  # this is the core of the hack
  class Stems
    extend Dupe

    def initialize klass
      @klass = klass
    end
    def name_pieces
      @name_pieces ||= @klass.to_s.gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase.split('::')
    end
    def noun
      @noun ||= NounStem[name_pieces[-2]]
    end
    def noun= mixed
      self.dupes |= [:noun] # duplicate this setting down to subclasses
      String === mixed and mixed = NounStem[mixed]
      @noun = mixed
    end
    def verb
      @verb ||= VerbStem[name_pieces.last]
    end
  end

  class Inflect
    # for setting how to inflect things
    #
    def noun *a
      if 0 == a.length then @noun ||= :singular else self.send(:noun=, *a) end
    end
    attr_writer :noun
  end

  class Inflected
    # for getting the inflected thing
    #
    def initialize inflection
      @inflection = inflection
    end
    attr_reader :inflection
    def noun
      inflection.stems.noun.send inflection.inflect.noun
    end
  end

  class Inflection
    extend Dupe
    dupes :stems

    def initialize klass
      @klass = klass
      if anc = detect_ancestor_respond_to(klass, :inflection)
        dupe! anc.inflection
      end
    end

    def inflect
      @inflect ||= Inflect.new
    end

    def inflected
      @inflected ||= Inflected.new(self)
    end

    def stems
      @stems ||= Stems.new(@klass)
    end

    attr_writer :stem
  end
end


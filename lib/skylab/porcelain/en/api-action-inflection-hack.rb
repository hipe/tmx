module Skylab::Porcelain
  module En::ApiActionInflectionHack
    def inflection
      @inflection ||= En::ApiActionInflectionHack::Inflection.new(self)
    end
  end
end

module Skylab::Porcelain::En::ApiActionInflectionHack

  class VerbStem < String
    class << self   ; alias_method :[], :new end
    def progressive ; "#{self}ing"           end
  end

  class NounStem < String
    class << self   ; alias_method :[], :new end
    def plural      ; "#{self}s"             end # fine for now
  end

  Stem = Struct.new(:noun, :verb)

  class Inflected < Struct.new(:noun)
  end

  class Inflection

    def initialize klass
      @klass = klass
    end

    def inflected
      Inflected.new(@klass.inflect_noun stem)
    end

    def stem
      @stem ||= begin
        name_pieces = @klass.to_s.gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase.split('::')
        Stem.new(NounStem[name_pieces[-2]], VerbStem[name_pieces.last])
      end
    end
  end
end


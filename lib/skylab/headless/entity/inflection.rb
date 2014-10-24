module Skylab::Headless

  class Entity::Inflection

    def initialize full_name_proc
      @full_name_proc = full_name_proc
    end

    def lexemes
      @lexemes ||= Lexemes_.new @full_name_proc

    end
  end

  class Entity::Inflection::Lexemes_

    def initialize full_name_proc
      @full_name_proc = full_name_proc
    end

    def noun
      @noun ||= Production_Proxy_.new( @full_name_proc )
    end
  end

  class Entity::Inflection::Lexemes_::Production_Proxy_

    def initialize full_name_proc
      stem = full_name_proc.map( :as_natural ) * TERM_SEPARATOR_STRING_
      @production = Headless_::NLP::EN::POS::Noun.produce stem
    end

    def singular
      @production.number = :singular
      @production.string
    end

    def plural
      @production.number = :plural
      @production.string
    end
  end
end

module Skylab::Headless

  class Entity::Inflection

    def initialize full_name_function
      @full_name_function = full_name_function
    end

    def lexemes
      @lexemes ||= Lexemes_.new @full_name_function

    end
  end

  class Entity::Inflection::Lexemes_

    def initialize full_name_function
      @full_name_function = full_name_function
    end

    def noun
      @noun ||= Production_Proxy_.new( @full_name_function )
    end
  end

  class Entity::Inflection::Lexemes_::Production_Proxy_

    def initialize full_name_function
      stem = full_name_function.map( :as_natural ) * ' '
      @production = Headless::NLP::EN::POS::Noun.produce stem
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

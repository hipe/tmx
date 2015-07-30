module Skylab::Brazen

  class Entity::Inflection

    # (don't use this for new code -
    #  it's ancient, moved here from [hl], might sunset)

    def initialize full_name_function

      @full_name_function = full_name_function
    end

    def lexemes

      @lexemes ||= Lexemes___.new @full_name_function
    end

    # <-

  class Lexemes___

    def initialize full_name_function
      @full_name_function = full_name_function
    end

    def noun
      @noun ||= Noun___.new @full_name_function
    end
  end

  class Noun___

    def initialize full_name_function
      stem = full_name_function.map( :as_natural ).join SPACE_
      @production = Home_.lib_.human::NLP::EN::POS::Noun.produce stem
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
  # ->
  end
end

module Skylab::Headless

  module NLP::EN::Part_Of_Speech
    # (this is the support module for the box module POS)
  end

  class NLP::EN::Part_Of_Speech::StringAsStem < ::String
    # (if this starts to feel like a hack then STAHP using it and refactor it!)

    class << self
      alias_method :[], :new
    end

  protected

    def initialize stem
      stem = stem.to_s if ::Symbol === stem # strict for now
      super
    end
  end

  module NLP::EN::POS
    # this is the box module that will hold parts of speech
  end

  class NLP::EN::POS::Noun < NLP::EN::Part_Of_Speech::StringAsStem

    def singular
      self
    end

    def singular= x
      define_singleton_method( :singular ) { x }
    end

    def plural
      "#{ self }s" # fine for now
    end

    def plural= x
      define_singleton_method( :plural ) { x }
    end
  end

  class NLP::EN::POS::Verb < NLP::EN::Part_Of_Speech::StringAsStem

    ends_with_e_rx = /e\z/i

    define_method :preterite do
      @preterite ||= begin
        if ends_with_e_rx =~ self
          "#{ $~.pre_match }ed".freeze
        else
          "#{ self }ed".freeze
        end
      end
    end

    attr_writer :preterite

    define_method :progressive do
      @progressive ||= begin
        if ends_with_e_rx =~ self
          "#{ $~.pre_match }ing".freeze
        else
          "#{ self }ing".freeze
        end
      end
    end

    attr_writer :progressive
  end
end

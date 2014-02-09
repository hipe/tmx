module Skylab::Headless

  module NLP::EN::Methods

    def self.[] mod
      mod.include self
    end

    fun = NLP::EN::Minitesimal::FUN

    define_method :an, & fun.an

    define_method :oxford_comma, & fun.oxford_comma

    alias_method :and_, :oxford_comma

    def or_ a
      oxford_comma a, ' or '
    end

    define_method :s, & fun.s

      # this is its power:
      #
      #   "#{s a, :no}known person#{s a} #{s a, :is} #{self.and a}".strip

  end
end

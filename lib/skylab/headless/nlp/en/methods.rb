module Skylab::Headless

  module NLP::EN::Methods

    # This travelled a long way to get here, it represents what used to be
    # the last holdover of nlp from porcelain.  it might just be transitional
    # until we have coverage good enought to phase-in sub-client i.m
    # everywhere instead of this yet-another-module but we'll see, maybe
    # it's ok as-is


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

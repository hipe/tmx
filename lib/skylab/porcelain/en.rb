require 'skylab/headless/core'

module Skylab::Porcelain::En
  extend ::Skylab::Autoloader

    # this looks like it is slated for deprecation for headless [#hl-003]

  module Methods

    headless = ::Skylab::Headless::NLP::EN::Minitesimal::FUN

    define_method :oxford_comma, & headless.oxford_comma
    alias_method :and, :oxford_comma
    alias_method :_and, :and      # because 'and' is a keyword, maybe prettier

    def or a
      oxford_comma a, ' or '
    end
    alias_method :_or, :or        # because 'or' is a keyword, maybe prettier

    define_method :s, & headless.s
      # "#{s a, :no}known person#{s a} #{s a, :is} #{self.and a}".strip

  end

  extend Methods # a.t.t.o.t.w some ppl still call En.oxford_comma as so
end

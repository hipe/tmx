module Skylab::Headless

  module NLP::EN::Methods

    def self.[] mod
      mod.include self
    end

    fun = NLP::EN

    [ :an, :oxford_comma, :s ].each do |i|
      define_method i, fun[ i ]
    end

    define_method :and_, fun.oxford_comma.curry[ ', ', ' and ' ]

    define_method :or_, fun.oxford_comma.curry[ ', ', ' or ' ]

      # this is its power:
      #
      #   "#{s a, :no}known person#{s a} #{s a, :is} #{self.and a}".strip

  end
end

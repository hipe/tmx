module Skylab::TanMan

  module Core::Pen
    # placeholder while we unconfuse things
  end


  module Core::Pen::Methods
    # box module
  end


  module Core::Pen::Methods::Global
    include Porcelain::En::Methods # oxford_comma, s()
    # @later this might be stylus pattern
  end


  module Core::Pen::Methods::Adaptive
    # Simply provides convenience methods that are shorthand wrappers
    # for the below style methods, for whose implementation text_styler()
    # is relied up.
    #
    # Because the including module relies upon the text_styler() for
    # the implementations and the text_styler() may be a variety of
    # different implementations based on the root runtime, for e.g.
    # this is considered to be the implementation for "adaptive style."
    #
    extend MetaHell::DelegatesTo
    include Core::Pen::Methods::Global

    delegates_to :text_styler, :pre
  end


  module Core::Pen::Methods::Universal
    def pre str
      "\"#{str}\""
    end
  end
end

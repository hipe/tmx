module Skylab::Snag

  module Library_::Yielder
  end

  class Library_::Yielder::Mono < ::Enumerator::Yielder

    # hack to force this to report an arity of 1, more useful then to be
    # used directly as a pubusb event handler where having an arity
    # of 1 is mandatory.

    def << x
      super
    end

    alias_method :yield, :<<

  end
end

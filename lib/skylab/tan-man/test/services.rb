module Skylab::TanMan::TestSupport

  module Services # being #watched [#mh-011]

    h = { }                       # the things we do for a consistent DSL

    define_singleton_method :o do |const, f|
      h[const] = f
    end

    o :JSON,     -> { require 'fileutils' ; ::FileUtils }

    o :OptParse, -> { require 'optparse' ; ::OptionParser }

    o :PP,       -> { require 'pp' ; ::PP }

    o :StringIO, -> { require 'stringio' ; ::StringIO }


    define_singleton_method :const_missing do |const|
      if h.key? const
        const_set const, h.fetch(const).call
      else
        raise ::NameError.exception( # alternately, call super -- it's neat!
          "uninitialized constant #{name}::#{const} (service not defined)" )
      end
    end
  end
end

module Skylab::TanMan::TestSupport

  module Services # being #watched [#mh-011]

    h = { }                       # the things we do for a consistent DSL

    define_singleton_method :o do |const, f|
      h[const] = f
    end

    o :FileUtils, -> { require 'fileutils' ; ::FileUtils }

    o :JSON,      -> { require 'json' ; ::JSON }

    o :OptParse,  -> { require 'optparse' ; ::OptionParser }

    o :PP,        -> { require 'pp' ; ::PP }

    o :Shellwords, -> { require 'shellwords' ; ::Shellwords }

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

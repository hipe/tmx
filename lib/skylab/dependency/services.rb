module Skylab::Dependency
  module Services # being #watched [#mh-011]

    load_method = ->(const) { "load_#{ Inflection::FUN.methodize[ const ] }" }

    define_singleton_method :const_missing do |const|
      if respond_to?( m = load_method[ const ] )
        const_set const, send(m)
      else
        fail "no such service defined - #{ const }"
        # NameError: uninitialized constant Foo::Bar
      end
    end

    define_singleton_method :o do |const, f|
      define_singleton_method( load_method[ const ] ) { f.call }
    end

    o :FileUtils, -> { require 'fileutils' ; ::FileUtils }

    o :StringIO, -> { require 'stringio' ; ::StringIO }

    o :StringScanner, -> { require 'strscan' ; ::StringScanner }

  end
end

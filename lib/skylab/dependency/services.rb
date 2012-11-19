module Skylab::Dependency
  module Services

    method = ->(const) { "load_#{ Inflection::FUN.methodify[ const ] }" }

    define_singleton_method :const_missing do |const|
      if respond_to?( m = method[ const ] )
        const_set const, send(m)
      else
        fail "no such service defined - #{ const }"
      end
    end

    define_singleton_method :o do |const, f|
      define_singleton_method( method[ const ] ) { f.call }
    end

    o :FileUtils, -> { require 'fileutils' ; ::FileUtils }

    o :StringIO, -> { require 'stringio' ; ::StringIO }

    o :StringScanner, -> { require 'strscan' ; ::StringScanner }

  end
end

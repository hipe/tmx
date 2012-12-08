module Skylab::TestSupport

  module Services

    h = { }
    define_singleton_method :o do |name, block|
      h[name] = block
    end

    o :FileUtils,     -> { require 'fileutils' ; ::FileUtils }

    o :Open3,         -> { require 'open3'     ; ::Open3 }

    o :StringIO,      -> { require 'stringio'  ; ::StringIO }

    o :Tmpdir,        -> { require 'tmpdir'    ; ::Dir } # Dir.tmpdir

    define_singleton_method :const_missing do |name|
      const_set name, h[name].call
    end
  end
end

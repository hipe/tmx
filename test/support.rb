require 'fileutils'
require 'pathname'
require 'stringio'

class ::String
  def unindent
    gsub %r{^#{Regexp.escape match(/\A[ ]*/)[0]}}, ''
  end
end


module Skylab ; end

module Skylab::TestSupport
  class MyStringIo < StringIO
    def to_s
      rewind
      read
    end
  end
  class TempDir < ::Pathname
    include FileUtils
    def prepare
      to_s =~ /\Atmp/ or return fail("we are being extra cautious")
      if exist?
        remove_entry_secure(to_s)
      elsif ! dirname.exist?
        mkdir_p dirname, :verbose => true
      end
      mkdir to_s
    end
  end
end

module Skylab
  class << TestSupport
    def tempdir path, requisite_level
      requisite_level >= 1 or raise("requisite level must always be one or above")
      pn = Pathname.new(path)
      re = Regexp.new("\\A#{requisite_level.times.map{ |_| '[^/]+' }.join('/')}")
      md = re.match(pn.to_s) or raise("hack failed: #{re} =~ #{pn.to_s.inspect}")
      if ! File.exist?(md[0])
        raise("prerequisite folder for tempdir must exist: #{md[0]}")
      end
      TestSupport::TempDir.new(path)
    end
  end
end

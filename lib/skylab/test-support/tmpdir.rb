require 'fileutils'
require 'open3'
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
    def emit type, msg
      $stderr.puts msg
    end
    def fu_output_message msg
      emit :info, msg
    end
    def initialize path, opts=nil
      super path
      @verbose = false
      @noop = false # no setter for now! b/c it introduces some issues
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    def patch str
      cd(to_s) do
        Open3.popen3('patch -p1') do |sin, sout, serr|
          sin.write str
          sin.close
          "" != (s = serr.read) and raise("patch failed(?): #{s.inspect}")
          if @verbose
            while s = sout.gets
              emit :info, s.strip
            end
          end
        end
      end
    end
    def touch_r files
      files.each do |file|
        dest_file = dest_dir = nil
        dest_path = join(file)
        if %r{/\z} =~ dest_path.to_s
          dest_dir = dest_path
        else
          dest_dir = dest_path.dirname
          dest_file = dest_path
        end
        dest_dir.exist? or  mkdir_p(dest_dir, :verbose => @verbose, :noop => @noop)
        dest_file and touch(dest_file, :verbose => @verbose, :noop => @noop)
      end
      self
    end
    def prepare
      to_s =~ /\Atmp/ or return fail("we are being extra cautious")
      if exist?
        remove_entry_secure(to_s)
      elsif ! dirname.exist?
        mkdir_p dirname, :verbose => @verbose, :noop => @noop
      end
      mkdir to_s
      self
    end
    attr_accessor :verbose
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


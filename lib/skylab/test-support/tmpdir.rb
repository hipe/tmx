require 'open3'
require 'stringio'
require File.expand_path('../test-support', __FILE__)
require 'skylab/face/path-tools'

module Skylab::TestSupport
  class Tmpdir < Skylab::Face::MyPathname
    include FileUtils
    def copy pathname, destination_basename = nil
      source = Skylab::Face::MyPathname.new(pathname.to_s)
      destination = join(destination_basename || source.basename)
      cp source.to_s, destination.to_s, verbose: @verbose, noop: @noop
    end
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
    alias_method :fileutils_mkdir, :mkdir # the name 'fu_mkdir' is already used by FileUtils!
    # experimental example interface
    def mkdir path_end, opts=nil
      my_opts = { noop: @noop, verbose: @verbose }
      opts and my_opts.merge(opts)
      fileutils_mkdir(join(path_end), opts)
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
    alias_method :fileutils_touch, :touch
    def touch file
      fileutils_touch(join(file), :verbose => @verbose, :noop => @noop)
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
        dest_file and fileutils_touch(dest_file, :verbose => @verbose, :noop => @noop)
      end
      self
    end
    def prepare
      %r{(?:^|/)tmp(?:/|$)} =~ to_s or return fail("we are being extra cautious")
      if exist?
        remove_entry_secure(to_s)
      elsif ! dirname.exist?
        mkdir_p dirname, :verbose => @verbose, :noop => @noop
      end
      fileutils_mkdir to_s
      self
    end
    attr_accessor :verbose
    def verbose!
      tap { |o| o.verbose = true }
    end
  end
end

module Skylab
  class << TestSupport
    def tmpdir path, requisite_level
      requisite_level >= 1 or raise("requisite level must always be one or above")
      pn = Pathname.new(path)
      re = Regexp.new("\\A#{requisite_level.times.map{ |_| '[^/]+' }.join('/')}")
      md = re.match(pn.to_s) or raise("hack failed: #{re} =~ #{pn.to_s.inspect}")
      if ! File.exist?(md[0])
        raise("prerequisite folder for tempdir must exist: #{md[0]}")
      end
      TestSupport::Tmpdir.new(path)
    end
  end
end


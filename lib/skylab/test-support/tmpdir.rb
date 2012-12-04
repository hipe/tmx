require 'open3'
require 'stringio'
require 'skylab/face/core' # MyPathname *only*

# maybe try not to manually beautify this file [#bs-010]
module Skylab::TestSupport
  class Tmpdir < ::Skylab::Face::MyPathname
    include ::FileUtils
    def initialize path, opts=nil
      super path
      @infostream = $stderr
      @noop = false # no setter for now! b/c it introduces some issues
      @requisite_level = 1
      @verbose = false
      opts and opts.each { |k, v| send("#{k}=", v) }
    end
    def copy pathname, destination_basename = nil
      source = ::Skylab::Face::MyPathname.new(pathname.to_s)
      destination = join(destination_basename || source.basename)
      cp source.to_s, destination.to_s, verbose: @verbose, noop: @noop
    end
    def emit _, msg
      @infostream.puts msg
    end
    def fu_output_message msg
      emit :info, msg
    end
    attr_writer :infostream
    alias_method :fileutils_mkdir, :mkdir # the name 'fu_mkdir' is already used by FileUtils!
    # experimental example interface
    def mkdir path_end, opts=nil
      my_opts = { noop: @noop, verbose: @verbose }
      opts and my_opts.merge(opts)
      fileutils_mkdir(join(path_end), my_opts)
    end
    def patch str
      cd(to_s) do
        ::Open3.popen3('patch -p1') do |sin, sout, serr|
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
    attr_accessor :requisite_level
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
      %r{(?:^|/)tmp(?:/|$)} =~ to_s or
        return fail("for now, tmpdirs must always have /tmp/ in their paths!")
      if exist?
        remove_entry_secure to_s
      elsif ! dirname.exist?
        requisite_level and requisite_level_check
        mkdir_p dirname, :verbose => @verbose, :noop => @noop
      end
      fileutils_mkdir to_s
      self
    end
    attr_accessor :verbose
    def verbose!
      self.verbose = true ; self
    end
    alias_method :debug!, :verbose! # old convention & new
  protected
    def requisite_level_check
      requisite_level > 0 or fail("requisite_level must be at least 1.")
      pn = ::Pathname.new to_s
      re = %r(\A#{ requisite_level.times.map { '[^/]+' }.join('/') })
      md = re.match(pn.to_s) or fail("hack failed: #{re} =~ #{pn.to_s.inspect}")
      unless ::File.exist? md[0]
        fail("prerequisite folder for tempdir must exist: #{ md[0] }")
      end
      nil
    end
  end

  module Tmpdir::ModuleMethods
    def tmpdir path, requisite_level=nil
      opts = { }
      requisite_level and opts[:requisite_level] = requisite_level
      Tmpdir.new(path, opts)
    end
  end
end

::Skylab::TestSupport.extend ::Skylab::TestSupport::Tmpdir::ModuleMethods

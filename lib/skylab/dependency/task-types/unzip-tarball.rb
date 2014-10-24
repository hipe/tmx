module Skylab::Dependency

  class TaskTypes::UnzipTarball < Dep_::Task

    Dep_::Lib_::Open_2[ self ]

    include Dep_::Lib_::Path_tools[].instance_methods_module

    include Dep_::TaskTypes::TarballTo::Constants

    attribute :unzip_tarball, :required => true, :pathname => true
    attribute :build_dir, :from_context => true, :pathname => true, :required => true
    attribute :output_dir

    listeners_digraph  :all,
      :info => :all, :error => :all,
      :shell => :all, :out => :all, :err => :all

    SIGNIFICANT_SECONDS = 1.0

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      unless @unzip_tarball.exist?
        # if optomistic dry run
        call_digraph_listeners(:error, "tarball not found: #{@unzip_tarball}")
        return false
      end
      if 0 == @unzip_tarball.stat.size
        call_digraph_listeners(:error, "tarball is zero length: #{@unzip_tarball}")
        return false
      end
      if unzipped_dir_path.exist?
        call_digraph_listeners(:info, "exists, won't tar extract: #{pretty_path unzipped_dir_path.to_s}")
        return true
      end
      _execute
    end
    def _execute
      cmd = "cd #{escape_path build_dir}; tar -xzvf #{escape_path @unzip_tarball.basename}"
      call_digraph_listeners(:shell, cmd)
      err = Dep_::Library_::StringIO.new
      bytes, seconds =  open2(cmd) do |on|
        on.out { |s| call_digraph_listeners(:out, s) }
        on.err { |s| call_digraph_listeners(:err, s) ; err.write(s) }
      end
      if no = err.string.split("\n").grep(/unrecognized archive format/i).first
        call_digraph_listeners(:error, "Failed to unzip: #{no}")
        return false
      end
      if seconds >= SIGNIFICANT_SECONDS
        call_digraph_listeners(:info, "read #{bytes} bytes in #{seconds} seconds.")
      end
      true
    end
    def initialize(*)
      @strips_version_number = true # unimplemented as a full settable attribute
      super
    end

    version_rx = /-#{ Dep_::Version::REGEX.source }/

    define_method :unzipped_dir_basename do
      @unzipped_dir_basename ||= begin
        str = unzip_tarball.basename.to_s.gsub(TARBALL_EXTENSION, '')
        if @strips_version_number
          str.gsub! version_rx, ''
        end
        str
      end
    end
    def unzipped_dir_path
      @unzipped_dir_path ||= build_dir.join(unzipped_dir_basename)
    end
  end
end

# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::TestSupport

  class Tmpdir < ::Pathname
    include TestSupport::Services::FileUtils

    def copy pathname, dest_basename = nil
      source = ::Pathname.new pathname.to_s
      dest = join( dest_basename || source.basename ) # where to? (basename)
      cp source.to_s, dest.to_s, noop: noop, verbose: verbose
      nil # result is undefined for now -- we might turn it into etc
    end

    alias_method :tmpdir_original_mkdir, :mkdir

    # experimental example interface
    def mkdir path_end, opts=nil
      use_opts = { noop: noop, verbose: verbose }
      use_opts.merge!( opts ) if opts
      use_path = join( path_end ).to_s
      tmpdir_original_mkdir use_path, use_opts
      nil # result is undefined for now -- we might turn it into etc
    end

    def patch str
      result = nil
      cd to_s do
        TestSupport::Services::Open3.popen3 'patch -p1' do |sin, sout, serr, w|
          sin.write str
          sin.close
          s = serr.read
          if '' != s
            raise "patch failed(?): #{ s.inspect }"
          end
          if verbose
            while s = sout.gets
              info s.strip
            end
          end
          result = w.value # exit_status
        end
      end
      result
    end

    safety_rx = %r{ / (?: tmp | T ) (?: / | \z ) }x # IMPORTANT

    define_method :prepare do
      result = nil
      sanity = -> path do         # IMPORTANT - try to avoid `rm -rf` any paths
        if safety_rx !~ path.to_s # except those under a /tmp/ or /T/ dir
          raise ::SecurityError.exception "unsafe tmpdir name - #{ path }"
        end
      end
      if exist?                   # if this pathname exists
        if ! directory?
          raise ::Errno::ENOTDIR.exception to_s
        end
        sanity[ self ]            # IMPORTANT
        if ::Dir[join '*'].any?   # are there any files in it?
          verbose and fu_output_message "rm -rf #{ to_s }"
          remove_entry_secure to_s # GULP
          result = tmpdir_original_mkdir to_s, noop: noop, verbose: verbose
        else
          verbose and fu_output_message "(already empty: #{ to_s })"
          result = nil
        end
      else
        stack = []
        pop = -> do
          currnt = self
          -> do
            if ! currnt.root? && '.' != currnt.to_s
              s = currnt.basename.to_s
              stack.push s
              currnt = currnt.dirname
            end
          end
        end.call
        0 < max_mkdirs or fail "max_mkdirs must be at least 1."
        current = self
        max_mkdirs.times do
          x = pop[ ] or break
          current = x
        end
        if ! current.exist?
          raise ::SecurityError.exception(
            "won't make more than #{max_mkdirs} dirs - #{current} must exist" )
        end                                    # so current exists,
        while ! stack.empty?
          peek = current.join stack.last
          peek.exist? or break
          stack.pop
          current = peek
        end                                    # and now current still exists.
        sanity[ current ]                      # be sure this is a /tmp/
        result = mkdir_p to_s, noop: noop, verbose: verbose
      end
      result
    end

    alias_method :tmpdir_original_touch, :touch

    def touch file
      use_path = join( file ).to_s
      tmpdir_original_touch use_path, noop: noop, verbose: verbose
      nil # result is undefined -- we might etc
    end

    def touch_r files
      files.each do |file|
        dest_file = dest_dir = nil
        dest_path = join file
        if %r{/\z} =~ dest_path.to_s
          dest_dir = dest_path
        else
          dest_dir = dest_path.dirname
          dest_file = dest_path
        end
        if ! dest_dir.exist?
          mkdir_p dest_dir, noop: noop, verbose: verbose
        end
        if dest_file
          tmpdir_original_touch dest_file, noop: noop, verbose: verbose
        end
      end
      nil
    end

  protected

    o = ::Struct.new( :infostream, :max_mkdirs, :noop, :path, :verbose ).new
    o[:infostream] = $stderr
    o[:max_mkdirs] = 1
    o[:noop] = false
    o[:verbose] = false

    # [path] [opts]
    define_method :initialize do |*args|
      x = o.dup
      if ::Hash === args.last
        args.pop.each { |k, v| x[k] = v }
      end
      if ::String === args.last or ::Pathname === args.last # ack
        x[:path] = args.pop
      end
      args.empty? or raise ::ArgumentError.exception "no"
      if ! x[:path]
        x[:path] = TestSupport::Services::Tmpdir.tmpdir
      end
      @infostream = x[:infostream]
      @max_mkdirs = x[:max_mkdirs]
      @noop = x[:noop]
      @verbose = x[:verbose]
      super x[:path]
      freeze
    end

    def fu_output_message msg
      info msg
    end

    def info msg
      infostream.puts msg
    end

    attr_reader :infostream # make it writable whenever

    attr_reader :max_mkdirs

    attr_reader :noop

    attr_reader :verbose
  end
end

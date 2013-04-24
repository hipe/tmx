# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::TestSupport

  class Tmpdir < ::Pathname

    include TestSupport_::Services::FileUtils

    def verbose!                  # see also the similar `debug!`
      @verbose = true
      self
    end

    def debug!                    # this compats with our convention org-wide
      @verbose = true             # this compats with the file utils convention
    end                           # (but see also `verbose!` chainable variant)

    attr_accessor :verbose        # yes. some clients need to be able to
                                  # set it using a variable.

    def clear                     # sugar around `prepare` that results in self.
      prepare                     # does a `rm -rf` on the temmpdir, creates!
      self
    end

    def copy pathname, dest_basename = nil
      source = ::Pathname.new pathname.to_s
      dest = join( dest_basename || source.basename ) # where to? (basename)
      cp source.to_s, dest.to_s, noop: noop, verbose: verbose
      nil # result is undefined for now -- we might turn it into etc
    end

    def mkdir path_end, opts=nil
      res = nil
      use_opts = { noop: noop, verbose: verbose }
      use_opts.merge!( opts ) if opts
      use_path = join( path_end ).to_s
      arr = ::FileUtils.mkdir use_path, use_opts
      if ::Array === arr and 1 == arr.length
        res = self.class.new arr.first
      end
      res # result is undefined for now -- the above is experimental!
    end

    def patch str
      Headless::Services::Patch.directory str, to_s, noop, verbose,
        -> e { info e }
      # (result is exit_status)
    end

    safety_rx = %r{ / (?: tmp | T ) (?: / | \z ) }x # IMPORTANT

    define_method :prepare do
      result = nil
      sanity = -> pn do         # IMPORTANT - try to avoid `rm -rf` any paths
        if safety_rx !~ pn.to_s # except those under a /tmp/ or /T/ dir
          ::Kernel.raise ::SecurityError, "unsafe tmpdir name - #{ pn }"
        end
      end
      if exist?                   # if this pathname exists
        path = to_s
        if ! directory?
          raise ::Errno::ENOTDIR.exception path
        end
        sanity[ self ]            # IMPORTANT, also out here and not down there.
        a = ::Dir[ "#{ join '{*,.?*}' }" ]  # imagine a dir with only dotfiles!
        case a.length
        when 0
          fail "sanity - this path should always have at least 1 element"
        when 1
          '/..' == a.fetch( 0 )[ -3 .. -1 ] or fail "sanity - expecting #{
            }this to be the '..' path - (filesystem issue?) #{ a[0] }"
          verbose and fu_output_message "(already empty: #{ path })"
          result = nil
        else
          verbose and fu_output_message "rm -rf #{ path }"
          if safety_rx =~ path  # twice for good measure
            remove_entry_secure path # GULP
            result = ::FileUtils.mkdir @path, noop: noop, verbose: verbose
          else
            fail "is there no god?"
          end
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
            "won't make more than #{max_mkdirs} dirs - #{current} must exist #{
            }(increase your `max_mkdirs` when you construct #{ self.class }?)"
          )
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
      pathname = join file
      tmpdir_original_touch pathname.to_s, noop: noop, verbose: verbose
      pathname
    end

    def touch_r files
      single_path = ! (::Array === files )
      if single_path
        files = [ files ]
        last_pathname = nil
      end
      files.each do |file|
        dest_file = dest_dir = nil
        if '/' == file.to_s[0]
          raise ::ArgumentError.new "must be relative - #{ file }"
        end
        dest_path = join file
        if %r{/\z} =~ dest_path.to_s
          dest_dir = dest_path
          last_pathname = dist_dir if single_path
        else
          dest_dir = dest_path.dirname
          dest_file = dest_path
          last_pathname = dest_file if single_path
        end
        if ! dest_dir.exist?
          mkdir_p dest_dir, noop: noop, verbose: verbose
        end
        if dest_file
          tmpdir_original_touch dest_file, noop: noop, verbose: verbose
        end
      end
      if single_path
        last_pathname # (we could of course adopt this to do etc)
      end
    end

    def write local_path, file_contents
      res = nil
      pathname = touch_r local_path
      if pathname
        pathname.open 'w' do |fh|
          fh.write file_contents
        end
        res = pathname
      end
      res
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
        x[:path] = TestSupport_::Services::Tmpdir.tmpdir
      end
      @infostream = x[:infostream]
      @max_mkdirs = x[:max_mkdirs]
      @noop = x[:noop]
      @verbose = x[:verbose]
      super x[:path]
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

  end
end

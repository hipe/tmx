# (predecessor to this line was poster-child beautification candidate [#bs-011])

module Skylab::TestSupport

  class Tmpdir < ::Pathname

    include Subsys::Services::FileUtils

    def debug!
      @be_verbose = true
      nil
    end

    def verbose!
      @be_verbose = true
      self  # chainable variant of above
    end

    def verbose= x
      @be_verbose = x
    end

    def clear
      prepare
      self
    end

    def copy pathname, dest_basename = nil
      source = ::Pathname.new pathname.to_s
      dest = join( dest_basename || source.basename ) # where to? (basename)
      cp source.to_s, dest.to_s, noop: @is_noop, verbose: @be_verbose
      nil # result is undefined for now -- we might turn it into etc
    end

    def mkdir path_tail, opt_h=nil
      o_h = { noop: @is_noop, verbose: @be_verbose }
      o_h.merge!( opt_h ) if opt_h
      use_path = join( path_tail ).to_s
      a = ::FileUtils.mkdir use_path, o_h
      if a.respond_to?( :each_index ) and 1 == a.length
        self.class.new a.first   # result is undefined, this is a secret experiment
      end
    end

    def patch str
      Headless::Services::Patch.directory str, to_s, @is_noop, @be_verbose,
        -> e { info e }
      # (result is exit_status)
    end

    safety_rx = %r{ / (?: tmp | T ) (?: / | \z ) }x

    # IMPORTANT see if we can avoid doing a `rm -rf` on any directory except
    # those that match the above rx.

    raise = -> *a do
      ::Kernel.raise( *a )
    end

    sanity_check_pathname = -> pn do
      safety_rx =~ pn.to_s or
        raise[ ::SecurityError, "unsafe tmpdir name - #{ pn }" ]
    end

    define_method :prepare do

      exist_notify = -> do
        path = to_s
        directory? or raise[ ::Errno::ENOTDIR, path ]
        sanity_check_pathname[ self ]
        a = ::Dir[ "#{ join '{*,.?*}' }" ]  # imagine a dir with only dotfiles
        case a.length
        when 0
          raise[ "sanity - this path should always have at least 1 element" ]
        when 1
          '/..' == a.fetch( 0 )[ -3 .. -1 ] or raise[ "sanity - expecting #{
            }this to be the '..' path - (filesystem issue?) #{ a[0] }" ]
          @be_verbose and fu_output_message "(already empty: #{ path })"
        else
          @be_verbose and fu_output_message "rm -rf #{ path }"
          if (( safety_rx =~ path or raise[ "is there no god?" ] ))  # 2x
            remove_entry_secure path  # GULP
            r = ::FileUtils.mkdir path, noop: @is_noop, verbose: @be_verbose
          end
        end
        r
      end

      not_exist_notify = -> do
        stack_a = []
        pop = -> do
          curr = self
          -> do
            if ! ( curr.root? || '.' == curr.instance_variable_get(:@path) )
              stack_a << curr.basename.to_s
              curr = curr.dirname
            end
          end
        end.call

        0 < @max_mkdirs or raise[ "max_mkdirs must be at least 1." ]

        curr = @max_mkdirs.times.reduce self do |m, _|
          ( x = pop[] ) ? x : ( break m )
        end

        curr.exist? or raise[ ::SecurityError, "won't make more than #{
          }#{ @max_mkdirs } dirs - #{ curr } must exist (increase your #{
          }`max_mkdirs` when you construct #{ self.class }?)" ]

        while ! stack_a.empty?
          (( peek = curr.join stack_a.last )).exist? or break
          stack_a.pop
          curr = peek
        end

        sanity_check_pathname[ curr ]
        mkdir_p to_s, noop: @is_noop, verbose: @be_verbose
      end

      r = if exist?
        exist_notify[]
      else
        not_exist_notify[]
      end
      r
    end

    alias_method :tmpdir_original_touch, :touch

    def touch file
      pathname = join file
      tmpdir_original_touch pathname.to_s, noop: @is_noop, verbose: @be_verbose
      pathname
    end

    def touch_r files
      single_path = ! files.respond_to?( :each_index )
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
          mkdir_p dest_dir, noop: @is_noop, verbose: @be_verbose
        end
        if dest_file
          tmpdir_original_touch dest_file, noop: @is_noop, verbose: @be_verbose
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

  private

    defaults = -> do
      o = ::Struct.new( :infostream, :max_mkdirs, :noop, :path, :verbose ).new
      o[:infostream] = Subsys::Stderr_[]
      o[:max_mkdirs] = 1
      o[:noop] = false
      o[:verbose] = false
      o.freeze
    end.call

    # [path] [opts]

    define_method :initialize do |*a|
      o = defaults.dup
      a.last.respond_to?( :each_pair ) and a.pop.each { |k, v| o[k] = v }
      if (( x = a.last )) and
          ( x.respond_to? :ascii_only? or x.respond_to? :sub_ext )
        o[:path] = a.pop
      end
      a.empty? or raise[ ::ArgumentError, "#{ a.length } unparsed args."  ]
      o[:path] ||= Subsys::Services::Tmpdir.tmpdir
      @infostream = o[:infostream]
      @max_mkdirs = o[:max_mkdirs]
      @is_noop = o[:noop]
      @be_verbose = o[:verbose]
      super o[:path]
    end

    def fu_output_message msg
      info msg
    end

    def info msg
      @infostream.puts msg
    end
  end
end

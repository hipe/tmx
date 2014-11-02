module Skylab::SubTree

  class API::Actions::Sub_Tree

    Entity_[ self,
      :properties, :err, :in_dir, :out_dir, :list, :do_force, :is_dry_run ]

    def execute
      -> do  # #result-block
        x = normalize or break x
        r = true
        while line = @list.gets
          line.chomp!
          r = process_pair @in_dir.join( line ), @out_dir.join( line )
          r or break
        end
        @list.close
        r and @err.puts "done."
        r
      end.call
    end

    def normalize
      -> do  # #result-block
        @in_dir && @out_dir && @list && @err or
          break bork "missing args"
        @in_dir.length.nonzero? && @out_dir.length.nonzero? or
          break bork "missing args"
        r = normalize_out_dir or break r
        @in_dir = ::Pathname.new @in_dir
        @in_dir.exist? or break bork "<in-dir> must exist - #{ @in_dir }"
        @list = ::File.open @list, 'r'
        true
      end.call
    end

    def normalize_out_dir
      -> do  # #result-block
        short_out_dir = ::Pathname.new( @out_dir )
        out_dir = short_out_dir.expand_path
        out_dir.exist? && ! @do_force and
          break bork "directory exists. use `--force` to OVERWRITE #{
            }existing files - #{ @out_dir }"
        @out_dir = short_out_dir
        true
      end.call
    end

    def bork msg
      @err.puts "sub-tree failed: #{ msg }"
      false
    end

    include SubTree::Library_::FileUtils

    def process_pair in_pn, out_pn
      -> do  # #result-block
        if in_pn.exist?
          if ! ( dn = out_pn.dirname ).exist?
            mkdir_p dn, verbose: true, noop: @is_dry_run
          end
          cp in_pn.to_s, out_pn.to_s, verbose: true, noop: @is_dry_run
        else
          @err.puts "(DID NOT EXIST, SKIPPING: #{ in_pn })"
        end
        true
      end.call
    end

    def fu_output_message msg
      @err.puts msg
    end
  end
end

module Skylab::PubSub

  class API::Actions::GraphViz < API::Action

    PARAMS = [ :default_outfile_name,
               :do_digraph,
               :do_guess_mod,
               :do_open,
               :do_show_backtrace,
               :do_write_files,
               :files,
               :modul,
               :outfile_name,
               :root_constant,
               :use_force
    ].each { |k| attr_writer k }

    def execute
      res = nil
      begin
        res = resolve_params or break
        res = resolve_infiles or break
        res = resolve_root_const or break
        res = resolve_mods or break
        res = resolve_jobs or break
        res = execute_jobs or break
        res = conclude_jobs
      end while nil
      res
    end

  private

    #         ~ implementation in order ~

    def resolve_infiles
      @do_guess_mod ? true : super
    end

    -> do  # `resolve_root_const`

      pathify = Autoloader::FUN.pathify
      constantize = Autoloader::FUN.constantize

      define_method :resolve_root_const do
        @mod_a = nil
        res = false

        early_ok = -> do
          res = true
          nil
        end

        idx = part_a = path = nil
        resolve_idx = -> do
          @root_constant or break early_ok[ ]
          filename = pathify[ @root_constant ]
          path = @files.fetch 0
          part_a = path.split '/'
          idx = part_a.index filename
          idx or break error "expected #{ filename.inspect } to occur in #{
            }path but it did not - #{ path }"
          true
        end

        toplevel_const = -> do
          pn = ::Pathname.new(
            "#{ part_a[ 0 .. idx ] * '/' }#{ Autoloader::EXTNAME }" )
          pn.exist? or break error( "expected to exist but did not - #{
            }#{ pn }" )
          if ! ::Object.const_defined? @root_constant
            load pn
          end
          if ! ::Object.const_defined? @root_constant
            break error( "toplevel constants #{ @root_constant.inspect } #{
             }not defined after loading file - #{ pn }" )
          end
          true
        end

        load_each_const = -> do
          rc = ::Object.const_get @root_constant
          const = part_a[ idx + 1 .. -1 ].reduce rc do |cnst, x|
            cnst.const_get constantize[ x ], false
          end
          @files.length > 1 and fail "test me - multiple files"  # todo
          @do_guess_mod = nil
          @mod_a = [ const ]
          true
        end

        -> do
          resolve_idx[ ] or break
          toplevel_const[ ] or break
          load_each_const[ ] or break
          res = true
        end.call
        res
      end
    end.call

    def resolve_mods
      if @mod_a  # then nothing
      elsif @do_guess_mod
        o = API::Tricks::Guess.new prefix, @paystream, @infostream, @files.first
        a = o.guess
        a and mod_a = a
      else
        if resolve_mod
          mod_a = [ @mod ]
        end
      end
      if @mod_a then true
      elsif ! mod_a then false else
        @mod_a = mod_a
        true
      end
    end

    def resolve_jobs  # assumes @mod
      # map / partition - turn each mod into a job, and break the jobs
      # into good jobs and bad jobs.
      job_a = [] ; bad_a = nil
      @mod_a.each do |mod|
        job = Job.new mod
        if mod.respond_to? meth
          job.event_stream_graph = mod.send meth
          job_a << job
        else
          (job.invalid_reasons ||= []) << "was expected to respond_to? #{meth}"
          ( bad_a ||= [] ) << job
        end
      end
      if job_a.length.nonzero?
        if bad_a
          bad_a.each do |j|
            info "#{ j.mod } #{ j.invalid_reasons.join ' and ' } - skipping"
          end
        end
        @job_a = job_a
        true
      else
        bad_a.each do |j|  # this implicitly expects @mod_a to be nonzero length
          error "#{ j.mod } #{ j.invalid_reasons.join ' and ' }"
        end
        false
      end
    end

    -> do

      meth = :event_stream_graph

      define_method :meth do meth end

    end.call

    Job = ::Struct.new :mod, :event_stream_graph, :outpathname, :_paystream,
      :invalid_reasons

    def execute_jobs
      if @do_write_files
        resolve_outpathnames
        resolve_outpaths
      end
      if @error_count.zero?
        @job_a.each do |job|
          render_graph job
        end
      end
      @error_count.zero?
    end

    def resolve_outpathnames
      @outfile_name or fail 'sanity'
      if am_doing_one_job
        @job_a[0].outpathname = ::Pathname.new @outfile_name
      else
        outpathname = build_outpathname_proc
        @job_a.each_with_index do |job, index|
          job.outpathname = outpathname[ index ]
        end
      end
      nil
    end

    def am_doing_one_job
      1 == @job_a.length
    end

    def build_outpathname_proc
      num_digits = 1
      current_figure = @job_a.length
      loop do
        current_figure /= 10
        current_figure == 0 and break
        num_digits += 1
      end
      fmt = "%0#{ num_digits }d"
      path_head, extname = splitpath @outfile_name
      -> job_index do
        ::Pathname.new "#{ path_head }-#{ fmt % [ job_index + 1 ] }#{ extname }"
      end  # <- the result
    end

    def splitpath path
      path && path.to_s.length.nonzero? or raise ::ArgumentError, path.inspect
      base_pn = ::Pathname.new path
      [ base_pn.sub_ext( '' ).to_s, base_pn.extname ]
    end

    def resolve_outpaths
      ok_to_clobber_rx = if am_doing_one_job
        /\A#{ ::Regexp.escape @default_outfile_name }\z/
      else
        head, extname = splitpath @default_outfile_name
        /\A#{ ::Regexp.escape head }-\d+#{ ::Regexp.escape extname }\z/
      end
      @job_a.each do |job|
        pn = job.outpathname
        if pn.exist?
          if ok_to_clobber_rx !~ pn.to_s
            if ! @use_force
              error "#{ prefix }won't overwrite without force - #{ pn }"
            end
          end
        end
      end
      nil
    end

    def render_graph job
      pay = if @do_write_files
        @infostream.write "(#{ prefix }writing #{ job.outpathname } .."
        job.outpathname.open 'w+'
      else
        @paystream
      end
      raw = job.event_stream_graph.describ
        # (expected never to fail but meh. we don't stream it because:)
      if raw && pay
        scn = Headless::Services::StringScanner.new raw ; num = 0 ; line = nil
        gets = -> do
          s = scn.scan( /[^\r\n]*\r?\n|[^\r\n]+/ )
          s and num += 1
          s
        end
        if @do_digraph
          pay.puts "digraph {"
          pay.puts "  node [shape=\"Mrecord\"]"
          pay.puts "  label=\"event stream graph for ::#{ job.mod }\""
          _gets = gets
          gets = -> { x = _gets[] and "  #{ x }" }
        end
        pay.puts( line ) while line = gets[]
        pay.write "}" if @do_digraph
        if pay.tty?
          @infostream.write "\n" if @do_digraph  # eew - digraph wo trailing nl
        else
          pay.close
          @infostream.puts "done.)"
        end
        info "(got #{ num } lines from #{ job.mod }##{ meth }#describe)"
      else
        error "`#{ @event_stream_graph.class }#describe` was falseish"
      end
      nil
    end

    def conclude_jobs
      if @error_count.zero?  # just to be sure
        if ! ( @do_write_files && @do_open ) then true else
          path_a = @job_a.reduce [] do |m, x|
            m << x.outpathname.to_s
          end
          if path_a.length.nonzero?  # jsut to be sure
            exec 'open', * path_a  # goodbye self
          end
        end
      end
    end
  end
end

module Skylab::Headless

  module CLI::Client

    Autoloader[ self ]                         # (lazy-load files under client/)

    def self.[] mod, * x_a
      Bundles__.apply_iambic_on_client x_a, mod
    end

    module Bundles__

      Actions_anchor_module = -> x_a do
        extend Headless::Action::ModuleMethods
        x = x_a.shift
        _p = if x.respond_to? :call then x
             elsif x.respond_to? :id2name then
               -> { const_get x }
             else
               -> { x }
             end
        const_set :ACTIONS_ANCHOR_MODULE, _p ; nil
      end

      Client_services = -> x_a do
        module_exec x_a, & Headless::Client::Bundles::Client_services.to_proc
      end

      DSL = -> _ do
        module_exec _, & CLI::Client::DSL::To_proc
      end

      Expressive_client = -> _ do
        module_exec _, & Headless::Pen::Bundles::Expressive_agent.to_proc
      private
        def expression_agent
          @io_adapter.pen
        end
      end

      Instance_methods = -> _ do
        include CLI::Client::InstanceMethods ; nil
      end

      Three_streams_notify = -> _ do
      private
        def errstream  # let this be the only one in the universe
          @io_adapter.errstream
        end
        def three_streams
          @io_adapter.to_three
        end
        def three_streams_notify i, o, e
          instance_variable_defined? :@io_adapter and raise "write once"
          @io_adapter = build_IO_adapter i, o, e, build_pen ; nil
        end
      end

      MetaHell::Bundle::Multiset[ self ]
    end
  end

  module CLI::Client::ModuleMethods            # future-proofing, aesthetics
    include CLI::Action::ModuleMethods
  end

  module CLI::Client::Adapter                  # for [#054] ouroboros
    MetaHell::MAARS[ self ]
  end

  module CLI::Client::InstanceMethods
    include CLI::Action::InstanceMethods
    include Headless::Client::InstanceMethods

    Adapter = CLI::Client::Adapter             # for now it is "for free"

    attr_writer :program_name                  # public for ouroboros [#054]

  private

    param_h = {
      0 => -> _ { },
      3 => -> a do
        @io_adapter = build_IO_adapter(* a )
      end
    }

    define_method :initialize do |*a|
      init_headless_sub_client nil  # modality clients are always this way
      instance_exec( a, & param_h.fetch( a.length ) )
      if self.class.respond_to? :_headless_inits and self.class._headless_inits
        _headless_inits_run  # [#052]
      end
      nil
    end

  private

    define_singleton_method :private_attr_reader, & Private_attr_reader_

    alias_method :init_headless_cli_client, :initialize
      # (`initialize` rarely gets left alone)

    def build_IO_adapter sin=$stdin, sout=$stdout, serr=$stderr, pen=build_pen
      # What is really nice is if you observe [#sl-114] and specify what
      # actual streams you want to use for these formal streams.  However
      # we grant ourself this one indulgence of specifying these most
      # conventional of defaults here, provided that this is the only place
      # library-wide that we will see a mention of these globals.

      io_adapter_class.new sin, sout, serr, pen
    end

    def infile_noun               # a bit of a hack to go with resolve_instream
      name = nil
      begin
        ref = @queue.first
        if ref && ::Symbol === ref && :help != ref  # BLEARG
          as = argument_syntax_for_method ref
          if as.length.nonzero?
            name = as.first.normalized_parameter_name
            break
          end
        end
        name = :infile  # sketchy..
      end while nil
      parameter_label name
    end

    def normalized_invocation_string  # #buck-stops: here
      program_name
    end

    def io_adapter_class
      Headless::CLI::IO_Adapter::Minimal
    end

    def info msg                  # barebones implementation as a convenience
      emit :info, msg             # for this shorthand commonly used in
      nil                         # debugging and verbose modes
    end

    def parameter_label x, idx=nil  # [#036] explains it all, somewhat
      idx = "[#{ idx }]" if idx
      if ::Symbol === x
        stem = Headless::Name::FUN.slugulate[ x ]
      else
        stem = x.name.as_slug  # errors please
      end
      em "<#{ stem }#{ idx }>"
    end

    def pen_class
      CLI::Pen::Minimal
    end

    private_attr_reader :program_name
    alias_method :program_name_ivar, :program_name

    def program_name
      program_name_ivar or ::File.basename $PROGRAM_NAME
    end

    def resolve_instream # (the probable destination of [#hl-022], in flux)

      # #experimental: Figure out which of several possible datasources should
      # be the stream for reading from based on whether the instream (stdin) is
      # a tty (interactive terminal) or not, and whether arguments exist in
      # argv, and if so, whether the number of those argv arguments is one, and
      # if so, if it is a filename that can be read (whew!)
      #
      # If it gets to this last case, (**NOTE**) it will mutate argv by shifting
      # this one arg off of it, it will open this filehandle (!!),
      # **and** reassign io_adapter.instream with this handle, possibly
      # releasing the original handle!! (For now, manifestations of this are
      # tracked org-wide with the tag #open-filehandle-1)
      #
      # This is an #experimental attempt to generalize this stuff, but is
      # probably premature in its current state, hence [#hl-022] will be
      # expected to be active for a while.
      #
      # The confusingly similarly named `resolve_upstream` is the same idea,
      # but we let that be a stub function that clients can opt-in to,
      # possibly implementing it simply by calling this.

      res = false                 # must be true on success per [#hl-023]
                                  # (imagine that false signifies a request
                                  # to display usage, invite after the error(s))
                                  # it is the default value b/c so common!

      try_instream = -> do
        res = true                # nothing to to.
      end

      ambiguous = -> do
        error "cannot resolve ambiguous instream modality paradigms --#{
          } both STDIN and #{ infile_noun } appear to be present."
      end

      try_argv = -> do
        case @argv.length
        when 0
          error "expecting: #{ infile_noun }"
          res = false
        when 1
          o = ::Pathname.new @argv.shift
          if o.exist?
            if o.directory?
              error "#{ infile_noun } is directory: #{ o }"
            else
              io_adapter.instream = o.open 'r'
              # (the above is #open-filehandle-1 --  don't loose track!)
              res = true
            end
          else
            error "#{ infile_noun } not found: #{ o }"
          end
        else
          error "expecting: #{ infile_noun } had: (#{ @argv.join ' ' })"
        end
      end

      argv = @argv.length.zero?   ? :argv_empty  : :some_argv
      term = io_adapter.instream.tty? ? :interactive : :noninteractive

      case [term, argv]
      when [:interactive,    :argv_empty] ; try_argv[ ]
      when [:interactive,    :some_argv]  ; try_argv[ ]
      when [:noninteractive, :argv_empty] ; try_instream[ ]
      when [:noninteractive, :some_argv]  ; ambiguous[ ]
      end

      res
    end
  end
end

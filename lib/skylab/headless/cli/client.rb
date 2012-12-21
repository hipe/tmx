module Skylab::Headless

  module CLI::Client
    extend Autoloader                          # (lazy-load files under client/)
  end


  module CLI::Client::ModuleMethods            # future-proofing, aesthetics
    include CLI::Action::ModuleMethods
  end


  module CLI::Client::InstanceMethods
    include CLI::Action::InstanceMethods
    include Headless::Client::InstanceMethods

  protected

    def build_io_adapter sin=$stdin, sout=$stdout, serr=$stderr, pen=build_pen
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
        if ! queue.empty?
          as = build_argument_syntax_for queue.first
          if ! as.empty?
            name = as.first.name
            break
          end
        end
        name = 'infile' # sketchy..
      end while nil
      parameter_label name
    end

    def invite_line
      "use #{ kbd "#{ normalized_invocation_string } -h" } for help"
    end

    def normalized_invocation_string
      program_name
    end

    def io_adapter_class
      Headless::CLI::IO_Adapter::Minimal
    end

    def info msg                  # barebones implementation as a convenience
      emit :info, msg             # for this shorthand commonly used in
      nil                         # debugging and verbose modes
    end

    def pen_class
      CLI::Pen::Minimal
    end

    def program_name
      (@program_name ||= nil) or ::File.basename $PROGRAM_NAME
    end

    attr_writer :program_name


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
        case argv.length
        when 0
          if suppress_normal_output
            info "No #{ infile_noun } argument present. Done."
            io_adapter.instream = nil # ok sure why not
            res = nil
          else
            error "expecting: #{ infile_noun }"
          end
        when 1
          o = ::Pathname.new argv.shift
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
          error "expecting: #{ infile_noun } had: (#{ argv.join ' ' })"
        end
      end

      argv = self.argv.empty?         ? :argv_empty  : :some_argv
      term = io_adapter.instream.tty? ? :interactive : :noninteractive

      case [term, argv]
      when [:interactive,    :argv_empty] ; try_argv[ ]
      when [:interactive,    :some_argv]  ; try_argv[ ]
      when [:noninteractive, :argv_empty] ; try_instream[ ]
      when [:noninteractive, :some_argv]  ; ambiguous[ ]
      end

      res
    end

    def suppress_normal_output!   # #experimental hack to let e.g. officious
      @suppress_normal_output = true # actions indicate that they executed, and
      self                        # if given a a choice there is no need to do
    end                           # further processing.

    attr_reader :suppress_normal_output

  end
end

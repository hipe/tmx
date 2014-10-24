module Skylab::TMX

  #                               ~ tmx ~
  #
  # (this is the jumping-off point from your sanity - the below amounts to
  # an intimation at the aspirations for what may grow to maybe become .. hl.)


  class CLI::Client < CLI_Client_[]

    # TMX::Modules::Arch.touch

    version do                    # (this is an officious facet of the lib.)
      ::Skylab.dir_pathname.join( '../../VERSION' ).read.strip
    end                           # will do either --version or --verbose
                                  # on -v "correctly" via MAGIC.

    alias_method :tmx_show_version, :show_version

    on '--verbose', 'be verbose.' do
      enable_verbose
    end

    story.option_parser do |o|    # this enables the MAGIC referred to above.
      na = ::OptionParser::Switch::NoArgument.new do
        if @argv.length.zero?
          ( @queue_a ||= [ ] ) << :show_version  # graceful exit after
        else
          enable_verbose
        end
      end
      o.top.short['v'] = na
    end

    def ping                      # (for debugging purposes we keep at least
      @out.puts "hello from tmx." # one of these lying around to test the
      @y << '(ping)'              # DSL out, if we hypothetically needed
      :ping                       # a sub-command at this node.)
    end

  private

    def initialize( * )
      super
      @mechanics.is_not_touched!
      @be_verbose = nil
    end

    def enable_verbose
      @y << '(verbose mode on.)'
      @be_verbose = true
    end

    def show_version
      rs = tmx_show_version
      if @be_verbose
        @out.puts ::RUBY_DESCRIPTION
      end
      rs
    end

    class Kernel_ < CLI_Client_[]::CLI_Kernel_  # the current way to do this :/

      def touch  # this is [#fa-038] - we get "touched" when we need to.
        ( @toucher ||= build_toucher ).touch
        is_touched!
      end

    private

      def build_toucher
        eew = parent_shell.instance_variable_get :@be_verbose
        Toucher_[ TMX::Modules, MONADIC_TRUTH__, sheet, @y, eew ]
      end
      MONADIC_TRUTH__ = -> _ { true }
    end

    Toucher_ = Lib_::Proxy_lib[].nice :touch

      # it "touchs" a command node (e.g. namespace) into life as it is needed.

    def Toucher_.[] box_mod, white, story, y, be_verbose
      pth = -> pn do
        pn.relative_path_from ::Skylab.dir_pathname
      end
      load_it = -> norm_i do
        # we cannot use autoloader/autovivifier when the module name is in
        # scream case, which some subproduct names are, hence:
        anchor = box_mod.dir_pathname.join "#{ norm_i }"
        welcome = anchor.sub_ext Autoloader_::EXTNAME
        if welcome.exist?
          y << "(leaf - #{ pth[ welcome ] })" if be_verbose
          Autoloader_.const_reduce [norm_i], box_mod  # loads it
          welcome
        else
          cli = anchor.join "cli#{ Autoloader_::EXTNAME }"
          if cli.exist?
            y << "(branch - #{ pth[ cli ] })" if be_verbose
            app_mod = Autoloader_.const_reduce [norm_i], box_mod
            app_mod.const_get :CLI, false
            cli
          else
            y << "(nothing loadable for \"#{ norm_i }\")" if be_verbose
            nil
          end
        end
      end
      tug_ns = -> bx, norm_i do
        pn = load_it[ norm_i ]
        if pn
          story.fetch_constituent norm_i do
            y << "(didn't find #{ norm_i } ns in #{ pth[ pn ] })" if be_verbose
            nil
          end
        end
      end
      new( touch: -> do
        y << "(loading all names.)" if be_verbose
        box_mod.names.each do |name|
          norm_i = name.as_slug.intern  # NOTE this is the convention
          if false == white[ norm_i ]
            y << "(disabled - #{ norm_i })" if be_verbose
          else
            story.if_constituent norm_i, nil, tug_ns
          end
        end
      end )
    end
  end
end

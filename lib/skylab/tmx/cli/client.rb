module Skylab::TMX

  #                               ~ tmx ~
  #
  # (this is the jumping-off point from your sanity - the below amounts to
  # an intimation at the aspirations for what may grow to maybe become .. hl.)


  class CLI::Client < Face::CLI

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
      @mechanics.is_not_puffed!
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

    class Mechanics_ < Face::CLI::CLI_Mechanics_  # the current way to do this :/

      def puff  # this is [#fa-038] - we get "puffed" when we need to.
        ( @puffer ||= build_puffer ).puff
        is_puffed!
      end

    private

      def build_puffer
        eew = parent_shell.instance_variable_get :@be_verbose
        white = ::Skylab::MetaHell::MONADIC_TRUTH_  # got replaced by `skip`
        Puffer_[ TMX::Modules, white, sheet, @y, eew ]
      end
    end

    Puffer_ = MetaHell::Proxy::Nice.new :puff
      # it "puffs" a command node (e.g. namespace) into life as it is needed.

    def Puffer_.[] box_mod, white, story, y, be_verbose
      pth = -> pn do
        pn.relative_path_from ::Skylab.dir_pathname
      end
      load_it = -> norm_i do
        # we cannot use autoloader/autovivifier when the module name is in
        # scream case, which some subproduct names are, hence:
        anchor = box_mod.dir_pathname.join "#{ norm_i }"
        welcome = anchor.sub_ext Autoloader::EXTNAME
        if welcome.exist?
          y << "(leaf - #{ pth[ welcome ] })" if be_verbose
          # require welcome.to_s  ; doing it the below way instead
          box_mod.const_fetch( norm_i )  # wires them for autoloading
          welcome
        else
          cli = anchor.join "cli#{ Autoloader::EXTNAME }"
          if cli.exist?
            y << "(branch - #{ pth[ cli ] })" if be_verbose
            box_mod.const_fetch( norm_i ).const_get( :CLI, false )
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
      new( puff: -> do
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

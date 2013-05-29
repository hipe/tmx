require_relative '..'

require 'skylab/face/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'

module Skylab::TMX

  #                               ~ tmx ~
  #
  # (this is the jumping-off point from your sanity - the below amounts to
  # an intimation at the aspirations for what may grow to maybe become .. hl.)

  # (although it is antithetical to the intended architecture
  # it is useful during development to be able to focus on one
  # sub-node at a time when necessary, by commenting *in* an
  # item below to *de*activate it. (comment it out to activate it! #todo))
  # (the ones de-activated below also happen to be the uninteresting,
  # really old ones)

  metadata_h = ::Hash[ [
    # :'beauty-salon',       # good - face
    :bleed,                  # #todo
    :cli,                    # 2012
    # :'cov-tree',           # good - legacy
    # :cull,                 # good - face
    # :'file-metrics',       # good - legacy
    :'git-viz',              # 2012
    :jshint,                 # 2012
    :nginx,                  # 2012
    # :permute,              # good - bleeding
    :php,                    # 2012
    # :regret,                 # TODO
    :schema,                 # 2012
    :slicer,                 # upcoming
    # :snag,                 # good - headless
    :'team-city',            # 2012
    # :'tan-man',            # good - bleeding
    # :treemap,              # good - bleeding
    :xpdf                    # 2012
  ].map { |k| [ k, false ] } ].freeze

  define_singleton_method :metadata_h do metadata_h end

  # (for each required internal library and sub-product constant, make a local
  # such constant here under our own for readability and ease of refactoring:)

  [
    :Autoloader,
    :Face,
    :MetaHell,
    :Porcelain,
    :TMX  # self too
  ].each do |c|
    const_set c, ::Skylab.const_get( c, false )
  end

  extend MetaHell::MAARS
    # now any module under `self` will autoload.

  module TMX::Modules

    # this isomorphs with the filesystem and is used to that end.
    # (note that generated namespaces will go in a sister module)

    extend MetaHell::Boxxy

  end

  class CLI < ::Skylab::Face::CLI

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

    def foo                       # (for debugging purposes we keep at least
      out.puts "foo."             # one of these lying around to test the
      @y << '(foo)'               # DSL out, if we hypothetically needed
      :foo                        # a sub-command at this node.)
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

    class Mechanics_ < Face::CLI_Mechanics_  # the current way to do this :/
      def puff  # this is [#fa-038] - we get "puffed" when we need to.
        eew = parent_shell.instance_variable_get :@be_verbose
        @puffer ||= Puffer_[ TMX::Modules, TMX.metadata_h, sheet, @y, eew ]
        @puffer.puff
        is_puffed!
      end
    end

    Puffer_ = MetaHell::Proxy::Nice.new :puff
      # it "puffs" a command node (e.g. namespace) into life as it is needed.

    def Puffer_.[] box_mod, metadata_h, story, y, be_verbose
      tug_ns = nil
      res = new( puff: -> do
        y << "(loading all names.)" if be_verbose
        box_mod.names.each do |name|
          norm_i = name.as_slug.intern  # NOTE this is the convention
          if false == metadata_h[ norm_i ]
            y << "(disabled - #{ norm_i })" if be_verbose
          else
            story.if_constituent norm_i, nil, tug_ns
          end
        end
      end )

      load_it = pth = nil
      tug_ns = -> bx, norm_i do
        pn = load_it[ norm_i ]
        story.fetch_constituent norm_i do
          raise ::RuntimeError, "didn't find #{ norm_i } ns in #{ pth[ pn ] }"
        end
      end

      pth = -> pn do
        pn.relative_path_from ::Skylab.dir_pathname
      end

      load_it = -> norm_i do
        # we cannot use autoloader/autovivifier when the module name is in
        # scream case, which some subproduct names are, hence:
        pn = box_mod.dir_pathname.join "#{ norm_i }/cli#{ Autoloader::EXTNAME }"
        if pn.exist?
          y << "(leaf - #{ pth[ pn ] })" if be_verbose
          require pn.sub_ext ''
          pn
        else
          p = pn.dirname
          y << "(branch - #{ pth[ p ] })" if be_verbose
          require p
          p
        end
      end
      res
    end
  end
end

require_relative '..'

require 'skylab/face/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'

module Skylab::TMX

  #                               ~ tmx ~
  #
  # (this is the jumping-off point from your sanity - the below amounts to
  # an intimation at the aspirations for what may grow to maybe become .. hl.)
  #


  # (although it is antithetical to the intended architecture
  # it is useful during development to be able to focus on one
  # sub-node at a time when necessary, by commenting *in* an
  # item below to *de*activate it. (comment it out to activate it! #todo))
  # (the ones de-activated below also happen to be the uninteresting,
  # really old ones)

  metadata_h = ::Hash[ [
    # :bleed,  # - ok
    :cli,
    # :'cov-tree',  # - ok
    # :'file-metrics',  # - ok
    :'git-viz',
    :jshint,
    :nginx,
    # :permute, # - ok
    :php,
    :schema,
    # :snag, # - ok
    :'team-city',
    # :'tan-man', # - ok
    # :treemap, # - ok
    :xpdf
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

  extend MetaHell::Autoloader::Autovivifying::Recursive
    # now any module under `self` will autoload.

  module TMX::Modules

    # this isomorphs with the filesystem and is used to that end.
    # (note that generated namespaces will go in a sister module)

    extend MetaHell::Boxxy

  end

  class CLI < ::Skylab::Face::CLI

    version do                    # (parent class does hackery for this)
      ::Skylab.dir_pathname.join( '../../VERSION' ).read.strip
    end                           # will do either --version or --verbose
                                  # on -v "correctly" via MAGIC.

    alias_method :tmx_show_version, :show_version
    def show_version
      rs = tmx_show_version
      if @is_verbose
        @out.puts ::RUBY_DESCRIPTION
      end
      rs
    end
    protected :show_version

    def enable_verbose
      @y << '(verbose mode on.)'
      @is_verbose = true
    end
    protected :enable_verbose

    on '--verbose', 'be verbose.' do
      enable_verbose
    end

    story.option_parser do |o|
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

  protected

    Puffer = MetaHell::Proxy::Nice.new :puff
      # it "puffs" a command node (e.g. namespace) into life as it is needed.

    def Puffer.[] box_mod, metadata_h, story, y, is_verbose
      tug_ns = nil
      res = new( puff: -> do
        y << "(loading all names.)" if is_verbose
        box_mod.names.each do |name|
          norm = name.as_slug.intern  # NOTE this is the convention
          if false == metadata_h[ norm ]
            y << "(disabled - #{ norm })" if is_verbose
          else
            story.if_element norm, nil, tug_ns
          end
        end
      end )

      load_it = pth = nil
      tug_ns = -> bx, norm do
        pn = load_it[ norm ]
        story.fetch_element norm do
          raise ::RuntimeError, "didn't find #{ norm } ns in #{ pth[ pn ] }"
        end
      end

      pth = -> pn do
        pn.relative_path_from ::Skylab.dir_pathname
      end

      load_it = -> norm do
        # we cannot use autoloader/autovivifier when the module name is in
        # scream case, which some subproduct names are, hence:
        pn = box_mod.dir_pathname.join "#{ norm }/cli#{ Autoloader::EXTNAME }"
        if pn.exist?
          y << "(leaf - #{ pth[ pn ] })" if is_verbose
          require pn.sub_ext ''
          pn
        else
          p = pn.dirname
          y << "(branch - #{ pth[ p ] })" if is_verbose
          require p
          p
        end
      end
      res
    end

    def puff  # called by the client libary when it needs everything
      @puffer ||= Puffer[ TMX::Modules, TMX.metadata_h, self.class.story,
        @y, @is_verbose ]
      @puffer.puff
      @is_puffed = true
    end

    def initialize( * )
      super
      @is_verbose = nil
      @is_puffed = false
      @all_names_are_loaded = false
    end
  end
end

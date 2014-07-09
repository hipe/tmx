module Skylab::TMX

  module Modules

    # this isomorphs with the filesystem and is used to that end.
    # (note that generated namespaces will go in a sister module)

    class << self
      alias_method :_tmx_original_constants_, :constants
    end
    module Archive
      Autoloader_[ self, :boxxy ]
    end
    Autoloader_[ self, :boxxy ]
  end

  class CLI::Client
    namespace :arch, -> do
      Modules::Arch::NS
    end, :desc, -> y do
      y << "#{ hi 'description:' } some ancient scripts, mostly installers"
      y << "  none are working, but we might one day resuscitate them."
    end, :skip, false
  end

  module Modules::Arch

    class NS < CLI_Client_[]::Namespace_
      def initialize( * )
        super
        @mechanics.is_not_touched!
      end
      use :hi
    end

    class NS::Kernel_ < CLI_Client_[]::NS_Kernel_

      def initialize( * )
        super
        @touch_story = parent_shell.class.story
        @mod_mod = TMX::Modules
        @box_mod = TMX::Modules::Archive
      end

      def touch
        box_mod = @box_mod
        box_mod.dir_pathname.children( false ).each do |pn|
          anchor = box_mod.dir_pathname.join pn
          cli = anchor.join "cli#{ Autoloader_::EXTNAME }"
          if cli.exist?
            if false  # a fallback that we keep around..
              soft_load pn, cli
            else
              direct_load pn, cli
            end
          else
            require anchor.to_s
          end
        end
        is_touched!
      end

    private

      def soft_load pn, cli
        i = pn.to_s.intern
        @touch_story.namespace i, -> do
          load_it cli
        end
      end

      # `direct_load` - given only a filename, what will it take to
      # ouroboros-ify that anchor class onto ours? we can learn something..

      def direct_load pn, cli
        kls = load_it cli
        if kls
          top_wisp = CLI_Client_[]::NS_Sheet_.new( nil ).
            init_with_local_normal_name pn.to_s.intern
          ada = kls::Adapter::For::Face
          oro = ada::Of::Sheet[ top_wisp, kls.story ]
          hotm = ada::Hotmm_[ top_wisp.name.as_slug, kls, -> { oro } ]
          oro.hotm = -> psvcs, _=nil do
            hot = hotm[ psvcs, _ ]
            r = hot.pre_execute or hot = r
            hot
          end
          @touch_story.add_namespace_sheet oro
        end
        nil
      end

      def load_it cli
        b4 = @mod_mod._tmx_original_constants_ ; res = nil
        require cli.to_s
        begin
          otr = @mod_mod._tmx_original_constants_  - b4
          otr.length.nonzero? or break
          1 == otr.length or break
          c = otr.fetch 0
          mod = @mod_mod.const_get c, false
          res = mod.const_get :CLI, false
        end while nil
        res
      end
    end
  end
end

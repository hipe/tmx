module Skylab::TMX

  class CLI::Client
    namespace :arch, -> do
      Modules::Arch::NS
    end, :desc, -> y do
      y << "#{ hi 'description:' } some ancient scripts, mostly installers"
      y << "  none are working, but we might one day resuscitate them."
    end, :skip, false
  end

  module Modules::Arch

    class NS < ::Skylab::Face::Namespace
      def initialize( * )
        super
        @mechanics.is_not_puffed!
      end
      use :hi
    end

    class NS::Mechanics_ < ::Skylab::Face::NS_Mechanics_

      def initialize( * )
        super
        @puff_story = parent_shell.class.story
        @mod_mod = TMX::Modules
        @box_mod = TMX::Modules::Archive
      end

      def puff
        box_mod = @box_mod
        box_mod.dir_pathname.children( false ).each do |pn|
          anchor = box_mod.dir_pathname.join pn
          cli = anchor.join "cli#{ Autoloader::EXTNAME }"
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
        is_puffed!
      end

    private

      def soft_load pn, cli
        i = pn.to_s.intern
        @puff_story.namespace i, -> do
          load_it cli
        end
      end

      # `direct_load` - given only a filename, what will it take to
      # ouroboros-ify that anchor class onto ours? we can learn something..

      def direct_load pn, cli
        kls = load_it cli
        if kls
          top_wisp = Face::NS_Sheet_.new( nil ).
            init_with_local_normal_name pn.to_s.intern
          ada = kls::Adapter::For::Face
          oro = ada::Of::Sheet[ top_wisp, kls.story ]
          hotm = ada::Hotmm_[ top_wisp.name.as_slug, kls, -> { oro } ]
          oro.hotm = -> psvcs, _=nil do
            hot = hotm[ psvcs, _ ]
            hot.pre_execute
            hot
          end
          @puff_story.add_namespace_sheet oro
        end
        nil
      end

      def load_it cli
        b4 = @mod_mod.boxxy_original_constants ; res = nil
        require cli.to_s
        begin
          otr = @mod_mod.boxxy_original_constants  - b4
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

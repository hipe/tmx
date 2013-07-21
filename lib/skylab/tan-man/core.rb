require_relative '..' # skylab.rb
require 'skylab/porcelain/core' # attr definer, table

module Skylab

  module TanMan

    Autoloader   = ::Skylab::Autoloader
    Bleeding     = ::Skylab::Porcelain::Bleeding
    Headless     = ::Skylab::Headless
    MetaHell     = ::Skylab::MetaHell
    PubSub       = ::Skylab::PubSub
    TanMan       = self #sl-107 (pattern)

    MetaHell::MAARS[ self ]

    CUSTOM_PARSE_TREE_METHOD_NAME_ = :tree

  end

  module TanMan::Core

    MetaHell::MAARS[ self ]

    module Event  # #stowaway all of this

      module LingualMethods

        attr_accessor :message  # k.i.w.f (i think) [#076]
        attr_accessor :is_inflected_with_action_name  # k.i.w.f (i think) [#076]
        attr_accessor :is_inflected_with_failure_reason  # [#076] k.i.w.f

      private

        def init_lingual x
          @message = x
        end
      end
    end
  end
end

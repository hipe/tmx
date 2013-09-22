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
    WRITEMODE_ = Headless::WRITEMODE_

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

  module TanMan

    Sub_Client = -> client, * x_a do
      Bundles__.apply_iambic_to_client x_a, client
    end

    module Bundles__

      Client_Services = -> a do
        module_exec a, & Headless::Client_Services.to_proc
      end

      Headless::Bundle::Multiset[ self ]
    end

    class Event_ < Headless::Event_
    end
  end
end

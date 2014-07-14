require_relative '..' # skylab.rb
require 'skylab/porcelain/core' # attr definer, table

module Skylab

  module TanMan

    Autoloader_ = ::Skylab::Callback::Autoloader
    Autoloader   = ::Skylab::Autoloader
    Callback     = ::Skylab::Callback
    Bleeding     = ::Skylab::Porcelain::Bleeding
    Headless     = ::Skylab::Headless
    MetaHell     = ::Skylab::MetaHell
    TanMan       = self #sl-107 (pattern)

    CUSTOM_PARSE_TREE_METHOD_NAME_ = :tree
    WRITEMODE_ = Headless::WRITEMODE_

  end

  module TanMan::Core

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

    TanMan::Autoloader_[ self ]
  end

  module TanMan

    Sub_Client = -> client, * x_a do
      Bundles__.apply_iambic_on_client x_a, client
    end

    module Bundles__

      Attributes = -> a do
        module_exec a, & TanMan::API::Action::Attribute_Adapter.to_proc
      end

      Client_Services = -> a do
        module_exec a, & Headless::Client_Services.to_proc
      end

      Anchored_program_name = -> _ do
        define_method :anchored_program_name do
          @request_client.anchored_program_name_for_subclient
        end ; private :anchored_program_name
        define_method :anchored_program_name_for_subclient do
          anchored_program_name
        end
      end

      Expression_agent = -> _ do
        define_method :expression_agent_for_subclient do
          expression_agent
        end
        define_method :expression_agent do
          @request_client.expression_agent_for_subclient  # #todo this is written assuming that "client services" have NOT yet replaced all the joints in the graph
        end ; private :expression_agent
      end

      MetaHell::Bundle::Multiset[ self ]
    end

    class Event_ < Headless::Event
    end

    Autoloader_[ self ]
  end
end

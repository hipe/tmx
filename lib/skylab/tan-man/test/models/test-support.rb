require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models

  ::Skylab::TanMan::TestSupport[ self ]

  include CONSTANTS

  TanMan_ = TanMan_ ; TestLib_ = TestLib_

  module InstanceMethods

    TestLib_::API_expect[ self ]

    def __old_build_controller__
      sexp = result or fail 'sanity - did parse fail?'
      request_client = TanMan_::CLI::Client.new :nein, :nein, :nein # for pen :/
      dfc = TanMan_::Models::DotFile::Controller.new request_client, 'xyzzy.dot'
      dfc.define_singleton_method :sexp do sexp end # eek
      cnt = collection_class.new dfc, sexp
      cnt
    end

    def collection_controller
      @collection_controller ||= build_collection_controller
    end

    def build_collection_controller
      send :"build_collection_controller_when_#{ produce_result_via_parse_method_i }"
    end

    def build_collection_controller_when_via_parse_via_input_file_granule_produce_result
      build_collections_controller.build_collection_controller_with(
        :input_pathname, input_file_pathname )
    end

    def build_collections_controller
      cc = collections.build_collections_controller_for_channel_and_delegate(
        :model, delegate )
      cc.on_parsing_events_subscription method :subscribe_to_parsing_events
      cc
    end

    def subscribe_to_parsing_events o
      o.on_parser_loading_info_event do |ev|
        if do_debug
          delegate.express_event ev
        end ; nil
      end
    end

    def collections
      subject_API.produce_application_kernel.models[ subject_model_name_i ]
    end
  end
end

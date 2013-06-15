module Skylab::Headless

  class Plugin::Metaservices_::Service_::Missing_

    def initialize
      raw_a = @raw_queue_a = [ ]
      @message_function = -> do  # [#it-002] NLP aggregation experiment
        Headless::Services::Basic::List::Aggregated::Articulation raw_a do
          template "{{ hst }}{{ adj1 }} has not declared the required #{
            }{{ service_i }} declared as needed by {{ pi }}{{ adj2 }}"
          on_zero_items -> { "everything was ok." }
          aggregate do
            service_i -> a do
              if 1 == a.length then "service \"#{ a.fetch 0 }\""
              else                  "services (#{ a * ', ' })" end
            end
          end
          on_first_mention do
            hst pi -> x { x.moniker }
            _flush -> x { "#{ x }." }
          end
          on_subsequent_mentions do
            hst        -> { 'it' }
            adj1       -> { ' also' }
            pi         -> { 'that puggie' }
            adj2       -> { ' either' }
            _flush     -> x { " #{ x }." }
          end
        end
      end
    end

    def host_lacks_service_for_plugin host_metasvcs, svc_i, plugin_metasvcs
      @raw_queue_a << Item_[ host_metasvcs, svc_i, plugin_metasvcs ]
      nil
    end

    Item_ = ::Struct.new :hst, :service_i, :pi

    attr_reader :message_function
  end
end

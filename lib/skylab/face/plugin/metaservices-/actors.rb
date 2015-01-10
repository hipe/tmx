module Skylab::Face

  module Plugin

    class Metaservices_

      Actors = ::Module.new

      class Actors::Missing

        def initialize
          @raw_queue_a = []
          @message_proc = bld_message_proc
        end

        attr_reader :message_proc

        def host_lacks_service_for_plugin host_metasvcs, svc_i, plugin_metasvcs
          @raw_queue_a.push(
            [ :hst, host_metasvcs, :service_i, svc_i, :pi, plugin_metasvcs ] )
          nil
        end

      private

        def bld_message_proc  # [#it-002] NLP aggregation experiment
          -> do

            common_first = -> y, x do
              y << x.moniker
            end

            _scn = Callback_::Scn.articulators.aggregating(

              :on_zero_items, -> y do
                y << "everything was ok."
              end,

              :template, "{{ hst }}{{ adj1 }} has not declared the required #{
                }{{ service_i }} declared as needed by {{ pi }}{{ adj2 }}",

              :service_i,
                :aggregate, -> y, a do
                  y << "services (#{ a * ', ' })"
                end,
                :on_first_mention, -> y, o do
                  y << "service \"#{ o }\""
                end,

              :hst,
                :on_first_mention, common_first,
                :on_subsequent_mentions, -> y, o do
                  y << 'it'
                end,

              :adj1,
                :on_subsequent_mentions_of, :field, :hst, -> y, _ do
                  y << ' also'
                end,

              :pi,
                :on_first_mention, common_first,
                :on_subsequent_mentions, -> y, _ do
                  y << 'that puggie'
                end,

              :adj2,
                :on_subsequent_mentions_of, :field, :pi, -> y, _ do
                  y << ' either'
                end )

            _upstream_scn = Callback_.stream.via_nonsparse_array @raw_queue_a
            scn_ = _scn.map_reduce_under _upstream_scn
            s_a = []
            while s = scn_.gets
              s_a.push s
            end
            s_a * '. '
          end
        end
      end
    end
  end
end

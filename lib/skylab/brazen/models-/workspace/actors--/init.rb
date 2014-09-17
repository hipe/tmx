module Skylab::Brazen

  class Models_::Workspace

    class Actors__::Init

      Actor_[ self, :properties,
        :app_name,
        :channel,
        :config_filename,
        :is_dry,
        :delegate,
        :path ]

      Entity_[]::Event::Merciless_Prefixing_Sender[ self ]

      def initialize
        super
        @channel ||= :workspace
      end

      def execute

        pn = ::Pathname.new "#{ @path }/#{ @config_filename }"

        config = Brazen_::Data_Stores_::Git_Config::Mutable.new -> ev do
          if ev.ok
            @delegate.receive_workspace_event ev
          else
            @delegate.receive_error_event ev
          end
        end  # #todo

        config.add_comment "created by #{ @app_name } #{
          }#{ ::Time.now.strftime '%Y-%m-%d %H:%M:%S' }"

        _evr = Via_Proc_Event_Receiver_.new -> ev do  # #todo
          @delegate.send :"receive_#{ @channel }_event",  ev
        end

        config.write_to_pathname pn,
          :is_dry, @is_dry,
          :event_receiver, _evr

      end
    end
  end
end

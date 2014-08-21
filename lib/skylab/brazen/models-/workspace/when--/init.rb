module Skylab::Brazen

  class Models_::Workspace

    class When__::Init

      Brazen_::Model_::Actor[ self, :properties,
        :app_name,
        :config_filename,
        :is_dry,
        :listener,
        :path ]

      Brazen_::Entity::Event::Merciless_Prefixing_Sender[ self ]

      def initialize x_a
        process_iambic_fully x_a
        @prefix = :workspace
      end

      def init
        pn = ::Pathname.new "#{ @path }/#{ @config_filename }"

        config = Brazen_::Data_Stores_::Git_Config::Mutable.new
        config.add_comment "created by #{ @app_name } #{
          }#{ ::Time.now.strftime '%Y-%m-%d %H:%M:%S' }"

        config.write_to_pathname pn, self,
          :is_dry, @is_dry,
          :prefix, :config
      end

      def on_config_wrote_file ev
        @listener.send :"on_#{ @prefix }_event", ev
      end
    end
  end
end

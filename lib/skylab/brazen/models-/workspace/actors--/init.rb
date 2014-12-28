module Skylab::Brazen

  class Models_::Workspace

    class Actors__::Init

      Actor_[ self, :properties,
        :is_dry,
        :path,
        :config_filename,
        :app_name,
        :on_event_selectively ]

      def execute
        @document = Brazen_::Data_Stores_::Git_Config::Mutable.new(
          & @on_event_selectively )
        ok = to_document_add_comment
        ok && write_document
      end

      def to_document_add_comment
        @document.add_comment "created by #{ @app_name } #{
          }#{ ::Time.now.strftime '%Y-%m-%d %H:%M:%S' }"
      end

      def write_document
        @document.write_to_path(
          ::File.join( @path, @config_filename ),
          :is_dry, @is_dry )
      end
    end
  end
end

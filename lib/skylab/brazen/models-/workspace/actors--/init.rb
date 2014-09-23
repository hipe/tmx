module Skylab::Brazen

  class Models_::Workspace

    class Actors__::Init

      Actor_[ self, :properties,
        :is_dry,
        :path,
        :config_filename,
        :app_name,
        :event_receiver ]

      def execute
        @document = Brazen_::Data_Stores_::Git_Config::Mutable.new @event_receiver
        ok = to_document_add_comment
        ok && write_document
      end

      def to_document_add_comment
        @document.add_comment "created by #{ @app_name } #{
          }#{ ::Time.now.strftime '%Y-%m-%d %H:%M:%S' }"
      end

      def write_document
        _pn = ::Pathname.new "#{ @path }/#{ @config_filename }"
        @document.write_to_pathname _pn, :is_dry, @is_dry
      end
    end
  end
end

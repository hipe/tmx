module Skylab::Brazen

  class Data_Stores_::Couch < Brazen_::Data_Store_::Model_

    class << self
      def build_collections kernel
        Collections__.new kernel
      end
    end

    Entity__ = Brazen_::Model_::Entity

    Entity__[ self, -> do
      o :desc, -> y do
        y << "manage couch datastores."
      end

      o :persist_to, :workspace

      o :description, -> y do
        y << "the name of the database"
      end,
      :ad_hoc_normalizer, -> x, val_p, ev_p, prop do
        if /\A[-a-z0-9]+\z/ =~ x
          val_p[ x ]
        else
          ev_p[ :error, :name_must_be_lowercase_alphanumeric_with_dashes,
                :name_s, x, :ok, false, nil ]
        end ; nil
      end,
      :required,
      :property, :name


      o :description, -> y do
        y << "the HTTP host to connect to (default: #{ property_default })"
      end,
      :default, 'localhost',
      :property, :host


      o :description, -> y do
        y << "the HTTP port to connect to (default: #{ property_default })"
      end,
      :default, '5984',
      :ad_hoc_normalizer, -> x, val_p, ev_p, prop do
        if x
          if /\A[0-9]{1,4}\z/ =~ x
            val_p[ x ]
          else
            ev_p[ :error, :port_must_be_one_to_four_digits, :port_s, x,
                  :ok, false, nil ]
          end
        end
      end,
      :property, :port

    end ]

    Action_Factory__ = Action_Factory.create_with self,
      Data_Store_::Action, Entity__

    Generated_Add__ = Action_Factory__.make :Add

    Generated_Rm__ = Action_Factory__.make :Remove

    module Actions

      class Add < Generated_Add__
        def produce_any_result_when_dependencies_are_met
          super
          @ent.if_valid_ensure_exists
        end
      end

      # Ls = Action_Factory__.make :List

      class Rm < Generated_Rm__
        Entity_[][ self, -> do
          o :description, -> y { y << 'always necessary for now.' },
            :flag, :property, :force
        end ]
        def produce_any_result_when_dependencies_are_met
          Couch_::Actors__::Delete_datastore[ self, @kernel ]
        end
      end
    end

    # ~ for actors

    def if_valid_ensure_exists
      if ! @dry_run && @was_valid_after_edit
        Couch_::Actors__::Ensure_datastore_exists[ self, @listener ]
      end
    end

    def put body, * x_a
      _HTTP_remote.put body, x_a
    end

    def get uri_tail, * x_a
      _HTTP_remote.get uri_tail, x_a
    end

    def delete_datastore action_props, channel, delegate
      x_a = :action_props, action_props, :channel, channel,
        :delegate, delegate, :entity_identifier_strategy, :none
      _HTTP_remote.delete x_a
    end

    def description
      "#{ @name } on #{ @host }:#{ @port }"
    end

  private

    def _HTTP_remote
      @HTTP_remote ||= HTTP_Remote__.new self, @name, @host, @port
    end

    class Collections__

      def initialize kernel
        @cache_h = {}
        @kernel = kernel
      end

      def persist_entity_to_datastore ent, ds_i
        Couch_::Actors__::Persist[ ent, ds_i, @kernel ]
      end

      def delete_entity_via_action act
        Couch_::Actors__::Delete[ act, @kernel ]
      end

      def retrieve_entity_via_name name_i, no_p
        had = true
        x = @cache_h.fetch name_i do
          had = false
        end
        if had
          if x
            x
          else
            no_p[ build_event_with :no_connection ]
          end
        else
          error = nil
          ds = Couch_::Actors__::Retrieve_datastore_entity[ name_i, @kernel, -> ev do
            error = ev
          end ]
          if error
            @cache_h[ name_i ] = UNABLE_
            no_p[ error ]
          else
            @cache_h[ name_i ] = ds
          end
        end
      end

      def remove_cached_named_connection i
        @cache_h.fetch i
        @cache_h.delete i
      end

      def build_collection_controller * five
        Couch_::Collection_Controller__.new five
      end
    end

    class HTTP_Remote__

      def initialize datastore, dbname, host, port
        @database = dbname ; @delegate = datastore
        @host = host ; @port = port
        freeze
      end

      def put body_s, x_a
        x_a.unshift :body_s, body_s
        o = build_request_response :Put, x_a
        o.send_and_receive
        deliver_response o
      end

      def get uri_tail, x_a
        x_a.unshift :URI_tail, uri_tail
        o = build_request_response :Get, x_a
        o.send_and_receive
        deliver_response o
      end

      def delete x_a
        o = build_request_response :Delete, x_a
        o.send_and_receive
        deliver_response o
      end

    private

      def build_request_response i, x_a
        Request_Response__.new x_a, i, @database, @port, @host, self
      end

      def deliver_response o
        s = o.response.message
        if s
          s.downcase! ; s.gsub! SPACE_, UNDERSCORE_
        end
        m_a = [ o.channel, WHEN_, o.response.code, s ]
        m_a.compact!
        m_i = m_a.join( UNDERSCORE_ ).intern
        o.delegate.send m_i, o
      end
      WHEN_ = 'when'.freeze

      class Request_Response__

        Actor_[ self, :properties,
          :action_props,
          :body_s,
          :channel,
          :delegate,
          :entity_identifier,
          :entity_identifier_strategy,
          :URI_tail ]

        def initialize x_a, i, database, port, host, delegate
          @action_props = nil
          @body_s = nil ; @channel = nil
          @database = database ; @delegate = delegate
          @entity_identifier_strategy = nil
          @host = host ; @HTTP_method_i = i
          @port = port
          process_iambic_fully x_a
          @need_to_prepare_URI = true
        end

        attr_reader :channel, :delegate

        def send_and_receive
          @need_to_prepare_URI && prepare_URI
          if @URI_is_OK
            do_send_and_receive
          end ; nil
        end

      private

        def prepare_URI
          @need_to_prepare_URI = false
          resolve_entity_identifier_strategy
          send :"via_#{ @entity_identifier_strategy }_resolve_URI"
          nil
        end

        def resolve_entity_identifier_strategy
          send :"resolve_entity_identifier_strategy_for_#{ @HTTP_method_i }"
        end

        def resolve_entity_identifier_strategy_for_Put
          if @entity_identifier_strategy.nil?
            @entity_identifier_strategy = :append_generated_UUID
          end ; nil
        end

        def resolve_entity_identifier_strategy_for_Get
          @entity_identifier_strategy = :append_URI_tail ; nil
        end

        def resolve_entity_identifier_strategy_for_Delete
          @entity_identifier_strategy or self._SANITY
        end

        def via_none_resolve_URI
          @URI_is_OK = true
          @URI_s = "/#{ @database }" ; nil
        end

        def via_append_URI_tail_resolve_URI
          if @URI_tail
            @URI_is_OK = true
            @URI_s = "/#{ @database }/#{ @URI_tail }" ; nil
          end
        end

        def via_entity_identifier_resolve_URI
          @URI_is_OK = @entity_identifier
          @URI_s = "/#{ @database }/#{ @entity_identifier }" ; nil
        end

        def via_append_generated_UUID_resolve_URI
          @req = Lib_::Net_HTTP[]::Get.new UUIDS_URL__
          @response = Lib_::Net_HTTP[].start @host, @port do |http|
            http.request @req
          end
          if OK_200__ == @response.code
            via_response_prepare_URI_with_generated_UUID
          else
            @URI_is_OK = false
          end ; nil
        end
        OK_200__ = '200'.freeze
        UUIDS_URL__ = '/_uuids'.freeze

        def via_response_prepare_URI_with_generated_UUID
          via_response_resolve_UUID
          @URI_is_OK = true
          @URI_s = "/#{ @database }/#{ @UUID }" ; nil
        end

        def via_response_resolve_UUID
          h = Lib_::JSON[].parse @response.body
          @UUID = h.fetch( UUIDS__ ).fetch 0 ; nil
        end
        UUIDS__ = 'uuids'.freeze

        def do_send_and_receive
          _cls = Lib_::Net_HTTP[].const_get @HTTP_method_i, false
          @req = _cls.new @URI_s
          apply_headers
          @req.body = @body_s
          @response = Lib_::Net_HTTP[].start @host, @port do |http|
            http.request @req
          end ; nil
        end

        def apply_headers
          case @HTTP_method_i
          when :Get, :Delete
          when :Put, :Post ; apply_headers_for_JSON
          end ; nil
        end

        def apply_headers_for_JSON
          @req[ CONTENT_TYPE__ ] = APPLICATION_JSON__ ; nil
        end
        CONTENT_TYPE__ = 'content-type'.freeze
        APPLICATION_JSON__ = 'application/json'.freeze

      public

        def response_body_to_completion_event * x_a, & p
          response_body_to_event do |a, h|
            a[ 0 ] = @response.message.downcase.gsub( SPACE_, UNDERSCORE_ ).intern
            a.push :message, @response.message
            h.key? 'ok' or a.push :ok, ACHEIVED_
            a.push :is_completion, true
            a.concat x_a
            p ||= -> y, o do
              y << o.message
            end
            build_event_via_iambic_and_message_proc a, p
          end
        end

        def response_body_to_error_event * x_a, & p
          response_body_to_event do |a, h|
            a[ 0 ] = h.fetch( 'error' ).intern
            a.push :ok, UNABLE_
            a.concat x_a
            p ||= -> y, o do
              y << ( o.reason || o.error )
            end
            build_event_via_iambic_and_message_proc a, p
          end
        end

        def response_body_to_event
          h = Lib_::JSON[].parse @response.body
          a = ::Array.new h.length * 2 + 1
          s_a = h.keys ; s_a.sort!
          s_a.each_with_index do |s, d|
            a[ ( d << 1 ) + 1 ] = s.intern
            a[ ( d << 1 ) + 2 ] = h.fetch s
          end
          yield a, h
        end

        attr_reader :response
      end
    end
    Couch_ = self
    Data_Store_ = Brazen_::Data_Store_
  end
end

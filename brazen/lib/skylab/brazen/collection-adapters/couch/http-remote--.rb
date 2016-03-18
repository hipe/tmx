module Skylab::Brazen

  class Collection_Adapters::Couch

    class HTTP_Remote__

      def initialize *a
        @database, @port, @host = a
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
        Request_Response__.new x_a, i, @database, @port, @host
      end

      def deliver_response o
        o.response_receiver.receive_response o
      end

      class Request_Response__

        def initialize * a
          x_a, @HTTP_method_i, @database, @port, @host = a
          @body_s = nil
          @entity_identifier_strategy = nil
          @HTTP_param_box = nil
          process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
          @need_to_prepare_URI = true
        end

        Attributes_actor_.call( self,
          add_HTTP_parameter: :custom_interpreter_method,
          body_s: nil,
          entity_identifier_strategy: nil,
          native_entity_identifier_s: nil,
          response_receiver: nil,
          URI_tail: nil,
        )

      private

        def add_HTTP_parameter=
          add_HTTP_param gets_one_polymorphic_value, gets_one_polymorphic_value
        end

      public

        attr_reader :response_receiver

        def send_and_receive
          @need_to_prepare_URI && prepare_URI
          if @URI_is_OK
            do_send_and_receive
          end ; nil
        end

      private

        def add_HTTP_param i, x  # parse them late
          bx = @HTTP_param_box ||= Box_.new
          bx.add i, x
          ACHIEVED_
        end

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

        def via___N_O_N_E___resolve_URI
          rslv_URI_via_body "/#{ @database }" ; nil
        end

        def via_append_URI_tail_resolve_URI
          if @URI_tail && @URI_tail.length.nonzero?
            rslv_URI_via_body "/#{ @database }/#{ @URI_tail }"
          else
            @URI_is_OK = false
          end ; nil
        end

        def via_native_entity_identifier_string_resolve_URI
          s = @native_entity_identifier_s
          if s && s.length.nonzero?
            rslv_URI_via_body "/#{ @database }/#{ @native_entity_identifier_s }"
          else
            @URI_is_OK = false
          end
        end

        def via_append_generated_UUID_resolve_URI

          @req = LIB_.net_HTTP::Get.new UUIDS_URL__
          @response = LIB_.net_HTTP.start @host, @port do |http|
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
          rslv_URI_via_body "/#{ @database }/#{ @UUID }" ; nil
        end

        def via_response_resolve_UUID
          h = LIB_.JSON.parse @response.body
          @UUID = h.fetch( UUIDS__ ).fetch 0 ; nil
        end
        UUIDS__ = 'uuids'.freeze


        def rslv_URI_via_body s
          @URI_s = s
          if @HTTP_param_box
            via_HTTP_param_box_rslv_URI
          else
            @URI_is_OK = true
          end ; nil
        end

        def via_HTTP_param_box_rslv_URI
          is_valid = true
          ast_s_a = []
          @HTTP_param_box.each_pair do |i, x|
            if SIMPLE_SAFETY_RX__ !~ x
              is_valid = false
              break
            end
            ast_s_a.push "#{ i }=#{ x }"
          end
          if is_valid
            @URI_s.concat "?#{ ast_s_a * '&' }"
            @URI_is_OK = true
          else
            @URI_is_OK = false
          end ; nil
        end

        SIMPLE_SAFETY_RX__ = /\A[-0-9a-z]+\z/

        def do_send_and_receive
          _cls = LIB_.net_HTTP.const_get @HTTP_method_i, false
          @req = _cls.new @URI_s
          apply_headers
          @req.body = @body_s
          @response = LIB_.net_HTTP.start @host, @port do |http|
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
          rsp_body_to_event do |a, h|
            a[ 0 ] = @response.message.downcase.gsub( SPACE_, UNDERSCORE_ ).intern
            a.push :message, @response.message
            h.key? OK__ or a.push :ok, ACHIEVED_
            h.key? CODE__ or a.push :code, @response.code.to_i
            a.push :is_completion, true
            a.concat x_a
            p ||= -> y, o do
              y << o.message
            end
            build_event_via_iambic_and_message_proc a, p
          end
        end

        def response_body_to_not_OK_event * x_a, & p
          rsp_body_to_event do |a, h|
            a[ 0 ] = h.fetch( 'error' ).intern
            a.push :ok, UNABLE_
            h.key? CODE__ or a.push :code, @response.code.to_i
            a.concat x_a
            p ||= -> y, o do
              y << ( o.reason || o.error )
            end
            build_event_via_iambic_and_message_proc a, p
          end
        end
        CODE__ = 'code'.freeze ; OK__ = 'ok'.freeze

      private

        def rsp_body_to_event  # needs block
          h = LIB_.JSON.parse @response.body
          a = ::Array.new h.length * 2 + 1
          s_a = h.keys ; s_a.sort!
          s_a.each_with_index do |s, d|
            a[ ( d << 1 ) + 1 ] = s.intern
            a[ ( d << 1 ) + 2 ] = h.fetch s
          end
          yield a, h
        end

        def build_event_via_iambic_and_message_proc a, p
          Callback_::Event.inline_via_iambic_and_any_message_proc_to_be_defaulted a, p
        end

      public

        attr_reader :response
      end

      class << self

        # syntax: | <delegate> |
        #           <channel> <delegate> |
        #           [ <name>, <value> [..]] <delegate>

        def response_receiver * x_a
          Respose_Receiver__.new_via_iambic x_a
        end
      end

      class Respose_Receiver__

        Attributes_actor_.call( self,
          :channel,
        )

        class << self

          def new_via_iambic x_a
            case x_a.length
            when 0 ; self
            when 1 ; new x_a.first
            when 2 ; new x_a.pop, x_a.unshift( :channel )
            else     new x_a.pop, x_a
            end
          end

          private :new
        end  # >>

        def initialize delegate, x_a=nil
          @channel = nil
          x_a and process_iambic_fully x_a
          @delegate = delegate
        end

        def new_with * x_a
          dup.init_dup x_a
        end
      protected
        def init_dup x_a
          process_iambic_fully x_a
          self
        end
      public

        def receive_response o
          s = o.response.message
          if s
            s.downcase! ; s.gsub! SPACE_, UNDERSCORE_
          end
          m_a = [ @channel, WHEN_, o.response.code, s ]
          m_a.compact!
          _m_i = m_a.join( UNDERSCORE_ ).intern
          @delegate.send _m_i, o
        end
      end

      WHEN_ = 'when'.freeze


    end
  end
end

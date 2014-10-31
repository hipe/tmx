require_relative 'test-support'

module Skylab::Headless::TestSupport::API

  describe "[hl] API - ping" do

    extend TS_

    with_API_module do

      module API

        Headless_::API[ self, :with_service, :with_session, :with_actions ]

        action_class

        class Action

          def initialize seed
            @client = Services_for_API_Action__.new seed.session, seed.service
            super seed.iambic
            @errstream ||= seed.errstream
          end
        end

        class Services_for_API_Action__
          Headless_::Delegating[ self ]
          delegating :to, :@service, :to_method, :object_id, :service_id
          delegating :to, :@session, %i( program_name )
          delegating :to, :@session, :to_method, :object_id, :session_id

          def initialize session, service
            @service = service ; @session = session ; nil
          end
        end

        class Actions::Ping < Action

          o :simple, :properties,
            :iambic_writer_method_to_be_provided, :ivar, :@do_say_hello,
              :say_hello_to_my_little_errstream

          def execute
            if @do_say_hello
              say_hello
            else
              get_ping_data
            end
          end

        private

          def get_ping_data
            Ping_Data__.new( @client.service_id, @client.session_id, object_id )
          end

          Ping_Data__ = ::Struct.new :service_id, :session_id, :action_id

          def say_hello_to_my_little_errstream=
            @do_say_hello = true
          end

          def say_hello
            @errstream.puts "helo"
            :_hello_
          end
        end

        session_class
        class Session
        private
          def program_name=
            @service._CHANGE_PROGRAM_NAME! iambic_property
          end
        public
          def program_name
            @service.program_name
          end
        end

        service_class
        class Service
          def initialize *_
            @program_name = nil
            super
          end
          def _CHANGE_PROGRAM_NAME! x
            @program_name = x ; nil
          end
          def program_name
            @program_name || ::File.basename( $PROGRAM_NAME )
          end
        end
        self
      end
    end

    it "loads" do
    end

    it "ping - per request service is persitent, session & action are not" do
      r = _API_invoke :ping
      r_ = _API_invoke :ping
      ( r_.action_id == r.action_id ).should eql false
      ( r_.session_id == r.session_id ).should eql false
      r_.service_id.should eql r.service_id
    end

    it "ping - everybody gets an errstream" do
      _API_invoke :ping, :say_hello_to_my_little_errstream
      expect 'helo'
      expect_no_more_lines
      @result.should eql :_hello_
    end

    it "when no action - X" do
      -> do
        _API_invoke :nope
      end.should raise_error ::NameError, /\bcannot "nope" - #{
        }there is no such constant.+\bAPI::Actions::\( ~ nope \)/
    end
  end
end

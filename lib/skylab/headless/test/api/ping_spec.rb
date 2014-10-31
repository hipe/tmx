require_relative 'test-support'

module Skylab::Headless::TestSupport::API::SSA__

  describe "[hl] API service, session & action" do

    extend TS__

    with_API_module do
      module API

        Headless_::API[ self, :with_service, :with_session, :with_actions ]

        action_class
        class Action
          def initialize x_a
            super
            @client = Services_For_API_Action__.new @service, @session
            @service = @session = nil
          end
        end

        class Services_For_API_Action__
          Headless_::Delegating[ self ]
          delegating :to, :@service, :to_method, :object_id, :service_id
          delegating :to, :@session, %i( program_name )
          delegating :to, :@session, :to_method, :object_id, :session_id

          def initialize service, session
            @service = service ; @session = session ; nil
          end
        end

        class Actions::Ping < Action

          params :say_hello_to_my_little_errstream,
            %i( has_custom_writer ivar @do_say_hello )

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
            @x_a.shift ; @do_say_hello = true ; nil
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
            @service._CHANGE_PROGRAM_NAME! @x_a.shift ; nil
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

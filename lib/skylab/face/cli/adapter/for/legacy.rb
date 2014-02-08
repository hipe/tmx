module Skylab::Face

  # `Adapter` pattern is [#hl-054]

  module Face::CLI::Adapter::For::Legacy
  end

  module Face::CLI::Adapter::For::Legacy::Of::Action_Subclient

    -> do  # `[]` defined -

      build_native = nil

      define_singleton_method :[] do |act_class, request_client, action_sheet|

        native = build_native[ act_class, request_client, action_sheet ]
        strange = native.instance_exec do
          strng = Shell_A.new(
            :didactic_invocation_string => -> do
              normalized_invocation_string
            end,
            :send => ->( *a, &b ) do
              strng.__send__( *a, &b )
            end
          )
        end
        strange
      end

      build_native = -> act_class, request_client, action_sheet do
        # the face cli mode client severs ties with the live parent request
        # client. rather, we just annotate the invocation string, and pass
        # the two output streams along.
        p, i, n = request_client.instance_exec do
          [ paystream, infostream, normalized_invocation_string ]
        end
        h = { out: p, err: i }
        h[:program_name] = "#{ n } #{ action_sheet.slug }" # full normalized etc
        act_class.new h
      end

      Shell_A = MetaHell::Proxy::Nice.new :didactic_invocation_string,
        :send
    end.call
  end
end

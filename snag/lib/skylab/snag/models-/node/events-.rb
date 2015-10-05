module Skylab::Snag

  module Models::Parse

    module Events

      Failure = Home_::Model_::Event.new :expecting, :near, :line,
                                          :lineno, :pathname  do

        message_proc do |y, o|
          _ctx = " (#{ pth o.pathname }:#{ o.lineno })"
          y << "expecting #{ o.expecting } near #{ o.near }#{ _ctx }"
        end
      end
    end
  end
end

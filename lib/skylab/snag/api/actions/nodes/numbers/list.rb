module Skylab::Snag

  class API::Actions::Nodes::Numbers::List < API::Action_

    Listener = Callback_::Ordered_Dictionary.new :error, :info, :output_line

    Entity_[ self, :make_listener_properties, :make_sender_methods ]

    def if_nodes_execute
      all_count = valid_count = 0
      all = @nodes.all.reduce_by { |_| all_count += 1 ; true }
      valid = all.reduce_by do |node|
        if node.is_valid
          true
        else
          info_event node.invalid_reason_event
          false
        end
      end
      valid = valid.reduce_by { |_| valid_count += 1 ; true }
      valid.each do |node|
        send_output_line_event node.render_identifier
      end
      info_string "found #{ valid_count } valid of #{ all_count } total nodes."
      ACHIEVED_
    end
  end
end

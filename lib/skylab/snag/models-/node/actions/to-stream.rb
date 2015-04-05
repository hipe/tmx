module Skylab::Snag

  class API::Actions::Nodes::Numbers::List < API::Action_

    Delegate = Snag_::Model_::Delegate.
      new :error_event, :error_string,
        :info_event, :info_string,
        :output_line

    Entity_.call self,

      :make_delegate_properties,
      :make_sender_methods,

      :required, :property, :working_dir

    def if_nodes_execute
      all_count = valid_count = 0
      all = @nodes.all.reduce_by { |_| all_count += 1 ; true }
      valid = all.reduce_by do |node|
        if node.is_valid
          true
        else
          receive_info_event node.invalid_reason_event
          false
        end
      end
      valid = valid.reduce_by { |_| valid_count += 1 ; true }
      valid.each do |node|
        send_output_line node.render_identifier
      end
      send_info_string "found #{ valid_count } valid of #{ all_count } total nodes."
      ACHIEVED_
    end
  end
end

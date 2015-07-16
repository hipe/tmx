module Skylab::Dependency

  class TaskTypes::Executable < Home_::Task

    attribute :executable, :required => true

    listeners_digraph  :all, :info => :all

    def execute context

      @context ||= (context[:args] || {})

      valid? or fail invalid_reason

      path = Home_.lib_.system.open2 [ 'which', executable ]
      path.strip!
      if path.length.zero?
        call_digraph_listeners(:info, "#{no 'not in PATH:'} #{executable}")
        false
      else
        call_digraph_listeners(:info, path)
        true
      end
    end
  end
end

module Skylab::Dependency

  class TaskTypes::Executable < Dep_::Task

    Dep_._lib.open_2 self

    attribute :executable, :required => true

    listeners_digraph  :all, :info => :all

    def execute context
      @context ||= (context[:args] || {})
      valid? or fail invalid_reason
      if '' == (path = open2("which #{executable}").strip)
        call_digraph_listeners(:info, "#{no 'not in PATH:'} #{executable}")
        false
      else
        call_digraph_listeners(:info, path)
        true
      end
    end
  end
end

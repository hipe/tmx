module Skylab::Treemap

  class CLI::Actions::Ping < CLI::Action

    listeners_digraph :info, :info_line, :error, help: :info

    def process
      call_digraph_listeners :info_line, "hello from treemap."
      :hello_from_treemap
    end
  end
end

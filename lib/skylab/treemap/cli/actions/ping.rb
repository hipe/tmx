module Skylab::Treemap

  class CLI::Actions::Ping < CLI::Action

    emits :info, :info_line, :error, help: :info

    def process
      emit :info_line, "hello from treemap."
      :hello_from_treemap
    end
  end
end

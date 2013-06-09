module Skylab::Face

  # ~ 5.9 - the Node facet ~
  #
  # when you need mutable node sheets you manipulate programmatically

  module CLI::Node_Facet
    def self.touch ; end  # just for loading quietly and obviously
  end

  class Node_Sheet_  # #re-open for facet 3

    remove_method :set_command_parameters_function
    def set_command_parameters_function f  # spec'd
      has_command_parameters_function and fail "sanity - clobber cpf?"
      @has_command_parameters_function = true
      @command_parameters_function_value = f
      nil
    end

    def command_parameters_function_value
      @has_command_parameters_function or fail "check `has_..` first"
      @command_parameters_function_value
    end
  end
end

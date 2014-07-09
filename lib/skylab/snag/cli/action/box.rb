module Skylab::Snag

  class CLI::Action::Box < CLI::Action

    Snag_::Lib_::CLI[]::Box[ self,
      :DSL, :leaf_action_base_class, -> { CLI::Action } ]

    def initialize client_x, _=nil  # (namespace sheet, not interesting)
      super client_x
    end                           # rc is nil when box needs a charged graph
                                  # of children to describe
  end
end

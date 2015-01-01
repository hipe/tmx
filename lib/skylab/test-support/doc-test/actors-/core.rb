module Skylab::TestSupport

  module DocTest

    Actors_ = ::Module.new

    module Actors_::Normalize_constant_name_string

      # if x is a valid (long or short, qualified or not) const name,
      # result is x. if x is not a valid const name, result depends on
      # whether a [#cb-017] "selective-listener" block was passed: if
      # yes, result is the result of the callback (whether or not the
      # would-be event was requested). if no, result is false.

      class << self
        def [] x, & oes_p
          if RX__ =~ x
            x
          elsif oes_p
            oes_p.call :error, :wrong_const_name do
              TestSupport_.lib_.event_lib.inline_not_OK_with(
                :wrong_const_name,
                  :name, x, :error_category, :name_error )
            end
          else
            UNABLE_
          end
        end
        alias_method :call, :[]
      end

      RX__ = /\A(?:::)?[A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*\z/

    end
  end
end

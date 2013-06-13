module Skylab::Basic

  class Mutex

    # (for now this is write-once but might be changed to be re-mutable
    # if ever needed.)

    def initialize
      @held_by = nil
    end

    attr_reader :held_by
    alias_method :is_held, :held_by

    def try_hold name_x, if_ok, if_already_held
      if @held_by
        if_already_held[ @held_by ]
      else
        @held_by = name_x
        if_ok[ ]
      end
    end
  end
end

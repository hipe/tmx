module Skylab::Basic

  class Mutex::Write_Once__

    def initialize name_x=nil
      @name_x = name_x
      @held_by = nil
    end

    attr_reader :held_by
    alias_method :is_held, :held_by

    # ~ :+[#mh-021] typical base class implementation:
    def dupe
      dup
    end
    def initialize_copy otr
      init_copy( * otr.get_args_for_copy ) ; nil
    end
  protected
    def get_args_for_copy
      [ @name_x, @held_by ]
    end
  private
    def init_copy x, y
      @name_x = x ; @held_by = y ; nil
    end
    # ~

  public

    def hold try_name_x
      try_hold try_name_x, EMPTY_P_, -> holder_name_x do
        raise ::ArgumentError, "#{ moniker } cannot be #{ try_name_x }, #{
          }is already #{ holder_name_x }"
      end
    end

    def try_hold holder_name_x, if_ok, if_already_held
      if @held_by
        if_already_held[ @held_by ]
      else
        @held_by = holder_name_x
        if_ok[ ]
      end
    end
  end
end

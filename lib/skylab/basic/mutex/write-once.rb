module Skylab::Basic

  class Mutex::Write_Once

    def initialize name_x=nil
      @name_x = name_x
      @held_by = nil
    end

  private

    def base_args
      [ @name_x, @held_by ]
    end

    def base_init *a
      @name_x, @held_by = a
    end

  public

    attr_reader :held_by
    alias_method :is_held, :held_by

    def hold try_name_x
      try_hold try_name_x, MetaHell::EMPTY_P_, -> holder_name_x do
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

    def dupe
      ba = base_args
      self.class.allocate.instance_exec do
        base_init( * ba )
        self
      end
    end
  end
end

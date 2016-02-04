module Skylab::MyTerm

  class Models_::Adapters

    class << self

      def interpret_compound_component p, asc, acs, & pp

        # you are receiving a request to vivify because perhaps
        #   • the interface needs you

        new.___init p, asc, acs, & pp
      end

      private :new
    end  # >>

    def ___init p, asc, acs, & pp

      @kernel_ = acs.kernel_

      # -- (might need to move this to be late)
      ada = acs.adapter
      if ada
        @_an_adapter_is_selected = true
        @_selected_adapter_name_const = ada.adapter_name_const
      else
        @_an_adapter_is_selected = false
      end

      # NOTE ETC

      p[ self ]
    end

    def __list__component_operation

      method :___list
    end

    def ___list

      st = @kernel_.silo( :Adapters ).to_load_ticket_stream

      if @_an_adapter_is_selected
        ___do_the_thing_with_the_thing st
      else
        st
      end
    end

    def ___do_the_thing_with_the_thing st

      const = @_selected_adapter_name_const

      p = -> do
        lt = st.gets
        if lt
          if const == lt.adapter_name_const
            p = st
            lt.is_selected__ = true
            lt
          else
            lt
          end
        end
      end

      Callback_.stream do
        p[]
      end
    end

    class Silo_Daemon

      def initialize k, _mod
        @kernel_ = k
      end

      def to_load_ticket_stream

        _fs = @kernel_.silo( :Installation ).filesystem

        single_mod = Home_::Image_Output_Adapters_

        _ = "#{ single_mod.dir_pathname.to_path }/[a-z0-9]*"

        _paths = _fs.glob _

        Here_::Index___.new( _paths, single_mod ).to_load_ticket_stream__
      end
    end

    Here_ = self
  end
end

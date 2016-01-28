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

      # NOTE ETC

      p[ self ]
    end

    def __list__component_operation

      method :___list
    end

    def ___list

      _fs = @kernel_.silo( :Installation ).filesystem

      _ = "#{ Home_::Image_Output_Adapters_.dir_pathname.to_path }/[a-z0-9]*"

      _paths = _fs.glob _

      Here_::Index___.new( _paths ).to_load_ticket_stream__
    end

    Here_ = self
  end
end
# #pending-rename: b.d

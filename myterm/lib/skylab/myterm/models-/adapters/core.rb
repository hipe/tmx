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
      @__selected_adapter = acs.method :adapter
      p[ self ]
    end

    def __list__component_operation

      method :___list
    end

    def ___list

      # produce a stream NOT of adapter "load ticket"s (see #spot-1)
      # but of adapter instances..

      lt_st = @kernel_.silo( :Adapters ).to_load_ticket_stream

      proto = Models_::Adapter::Instance.new_prototype_ @kernel_

      flush_the_rest_to_a_map_of_not_selected = -> do

        x = lt_st
        lt_st = nil
        x.map_by do |lt|
          proto.new_not_selected_ lt
        end
      end

      ada = @__selected_adapter.call
      if ada
        const = ada.adapter_name_const
        p = -> do
          lt = lt_st.gets
          if lt
            if const == lt.adapter_name_const
              p = flush_the_rest_to_a_map_of_not_selected[]
              ada
            else
              proto.new_not_selected_ lt
            end
          end
        end
        Callback_.stream do
          p[]
        end
      else
        flush_the_rest_to_a_map_of_not_selected[]
      end
    end

    class Silo_Daemon

      def initialize k, _mod
        @kernel_ = k
      end

      def to_load_ticket_stream
        @___lt_a ||= ___build_index
        Callback_::Stream.via_nonsparse_array @___lt_a
      end

      def ___build_index

        single_mod = Home_::Image_Output_Adapters_

        _ = "#{ single_mod.dir_pathname.to_path }/[a-z0-9]*"

        _fs = @kernel_.silo( :Installation ).filesystem

        _paths = _fs.glob _

        Here_::Index___.new( _paths, single_mod ).array
      end
    end

    Here_ = self
  end
end

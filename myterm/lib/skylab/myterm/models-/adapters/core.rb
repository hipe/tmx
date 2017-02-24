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

      # produce a stream NOT of adapter "loadable reference"s (see #spot-1)
      # but of adapter instances..

      lt_st = @kernel_.silo( :Adapters ).to_asset_reference_stream

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
        Common_.stream do
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

      def to_asset_reference_stream

        # to address the PRO's *and* CON's in [#010], the below strikes a
        # "good" compromise: assume that the filesystem can always change
        # so every single time this is requested, hit it anew. but each
        # time the filesystem results in the "same" glob result, only ever
        # calculate the index of this result once.
        # (for testing we can do a hack to cache this filessystem hit if OCD)

        _fs = @kernel_.silo( :Installation ).filesystem

        single_mod = Home_::Image_Output_Adapters_

        _glob_path = "#{ single_mod.dir_path }/[a-z0-9]*"

        paths = _fs.glob _glob_path

        cache = @kernel_.FOREVER_CACHE

        a = cache.fetch paths do  # would not scale out per namespacing
          x = Here_::Index___.new( paths, single_mod ).array
          cache[ paths ] = x
          x
        end

        Common_::Stream.via_nonsparse_array a
      end
    end

    Here_ = self
  end
end

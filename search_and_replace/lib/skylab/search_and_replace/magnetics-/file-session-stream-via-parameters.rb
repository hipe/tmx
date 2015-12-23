module Skylab::SearchAndReplace

  class Magnetics_::File_Session_Stream_via_Parameters

    class << self

      def with * x_a

        if block_given?
          self._COVER_ME
        else
          p = -> * i_a, ev_p do
            if :info != i_a.first
              raise ev_p[].to_exception
            end
          end
        end

        new.__init( x_a, & p ).execute
      end
    end  # >>

    PARAMETERS___ = {
      do_highlight: :delegated,
      for_interactive_search_and_replace: :flag,
      grep_extended_regexp_string: :delegated,
      max_file_size_for_multiline_mode: :delegated,
      read_only: :flag,
      ruby_regexp: :delegated,
      upstream_path_stream: nil,
    }

    def __init x_a, & p

      @_oes_p = p

      delegated = [] ; flag = {} ; ivars = {}
      hh = {
        flag: -> sym { flag[ sym ] = true },
        delegated: -> sym { delegated.push sym },
      }
      PARAMETERS___.each_pair do | sym, x |
        ivar = :"@#{ sym }"
        ivars[ sym ] = ivar
        instance_variable_set ivar, nil
        [ * x ].each { |k| hh.fetch( k )[ sym ] }
      end

      st = Callback_::Polymorphic_Stream.via_array x_a
      begin
        k = st.gets_one
        instance_variable_set ivars.fetch( k ), ( flag[k] ? true : st.gets_one )
      end until st.no_unparsed_exists

      @_delegated = delegated ; @_ivars = ivars

      self
    end

    def execute

      _mod = if @for_interactive_search_and_replace
        Home_::Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream
      elsif @read_only
        Home_::Magnetics_::Read_Only_File_Session_Stream_via_File_Session_Stream
      end

      _x_a = @_delegated.reduce [] do | m, sym |
        x = instance_variable_get @_ivars.fetch sym
        if x.nil?
          m
        else
          m << sym << x
        end
      end

      producer = _mod.producer_via_iambic _x_a, & @_oes_p

      path_count = 0
      @upstream_path_stream.map_reduce_by do |path|
        path_count += 1
        producer.produce_file_session_via_ordinal_and_path path_count, path
      end
    end

    Here__ = self
  end
end

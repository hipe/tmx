module Skylab::MyTerm

  module Models_::Adapter

    class Load_Ticket

      class << self
        alias_method :new_via__, :new
        private :new
      end  # >>

      def initialize stem, path, category

        @dir = nil
        @file = nil
        @stem = stem

        _recv_path path, category
      end

      def _recv_path path, category

        send CAT___.fetch( category ), path
        NIL_
      end

      alias_method :receive_other_path__, :_recv_path

      CAT___ = {
        dir: :__receive_dir,
        file: :__receive_file,
      }

      def __receive_dir x
        @dir = x ; nil
      end

      def __receive_file x
        @file = x ; nil
      end

      def close__

        if @file
          @_path_ivar = :@file
        else
          @_path_ivar = :@dir
        end
        NIL_
      end

      def path
        instance_variable_get @_path_ivar
      end
    end
  end
end

module Skylab::MyTerm

  module Models_::Adapter

    class Load_Ticket

      class << self
        alias_method :new_via__, :new
        private :new
      end  # >>

      def initialize stem, path, category, single_mod

        @_box_mod = single_mod
        @dir = nil
        @file = nil
        @is_selected__ = false
        @stem = stem

        _recv_path path, category
      end

      # -- reading

      def module  # (doesn't cache the require'ing)

        const = adapter_name.as_const

        if @_box_mod.const_defined? const, false

          @_box_mod.const_get const, false
        else
          ___load_and_autoloaderize_module const
        end
      end

      def ___load_and_autoloaderize_module const

        if @file
          self._WORKED_THEN_BECAME_UNCOVERED
          load_path = @file[ 0 ... - Autoloader_::EXTNAME.length ]
        else
          load_path = ::File.join @dir, Autoloader_::CORE_  # #violation
        end

        require load_path  # ..

        mod = @_box_mod.const_get const, false

        Autoloader_[ mod, load_path ]

        mod
      end

      def adapter_name_const
        adapter_name.as_const
      end

      def adapter_name
        @___nf ||= Callback_::Name.via_slug @stem
      end

      def is_selected
        @is_selected__
      end

      # -- writing

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

      attr_reader(
        :stem,
      )

      # -- egads

      attr_writer(
        :is_selected__,
      )
    end
  end
end
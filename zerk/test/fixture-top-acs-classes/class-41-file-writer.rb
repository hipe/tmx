module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_41_File_Writer

    class << self
      alias_method :new_cold_root_ACS_for_niCLI_test, :new
      private :new
    end  # >>

      def describe_into_under y, expag
        expag.calculate do
          y << "#{ highlight 'writes' } files"
        end
      end

      def __wazoozie_foozie__component_operation

        yield :description, -> y do
          y << "have #{ code 'fun' }"
        end

        yield :parameter, :flim_flam, :description, -> y do
          y << highlight( 'f.f' )
        end

        -> flim_flam, nim_nam, & call_p do  # see [#006]#Event-models:#ick

          if call_p
            use_p = call_p
          else
            self._COVER_ME
            use_p =  @_oes_p
          end

          use_p.call :info, :expression, :hello do | y |
            y << "hello #{ highlight flim_flam } #{ highlight nim_nam }"
          end

          12332
        end
      end

      def __nim_nam__component_association

        yield :description, -> y do
          y << highlight( 'n.n' )
        end

        -> st do
          Callback_::Known_Known[ st.gets_one ]
        end
      end

      def __sashimi__component_association

        yield :description, -> y do
          y << code( 'sakana' )
        end

        -> do
          self._K
        end
      end

      def __fantazzle_dazzle__component_association

        Faz_Daz
      end

    class Faz_Daz

      class << self

        def interpret_compound_component p
          p[ new ]
        end
      end  # >>

      def describe_into_under y, expag
        expag.calculate do
          y << code( 'yay' )
        end
      end

      def __open__component_operation

        yield(
          :parameter, :verbose, :is_flag,
            :description, -> y { y << 'tha V' },

          :parameter, :dry_run, :is_flag,

          :end
        )

        -> verbose, dry_run, file, & call_p do  # [#006]#Event-models:#ick

          self._NEAT

          if call_p
            use_p = call_p
          else
            self._COVER_ME
            use_p = @oes_p_
          end

          use_p.call :info, :expression, :k do | y |
            y << [ :file, file, * ( :V if verbose ), * ( :D if dry_run ) ].inspect
          end

          :_neat_
        end
      end
    end
  end
end

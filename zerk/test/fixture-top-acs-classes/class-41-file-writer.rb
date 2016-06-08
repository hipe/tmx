module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_41_File_Writer  # 2x

    # a 2-level structure. the first level has two primitivesques and one
    # operation and the one compound. the second level adds an operation.

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
          y << "have #{ highlight 'fun' }"
        end

        yield :parameter, :flim_flam, :description, -> y do
          y << highlight( 'f.f' )
        end

        -> flim_flam, nim_nam, & call_p do  # see [#006]#Event-models:#ick

          call_p.call :info, :expression, :hello do | y |
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
          Common_::Known_Known[ "(nn:#{ st.gets_one })" ]
        end
      end

      attr_reader :nim_nam

      def __dry_run__component_association

        yield :description, -> y do
          y << highlight( 'd.r' )
        end

        yield :flag

        -> st do
          _hi = st.gets_one
          Common_::Known_Known[ _hi ]
        end
      end

      def __fantazzle_dazzle__component_association

        Faz_Daz
      end

    class Faz_Daz

      class << self

        def interpret_compound_component p, parent_ACS
          p[ ( new parent_ACS ) ]
        end
      end  # >>

      def initialize x
        @__parent_ACS = x
      end

      def describe_into_under y, expag
        expag.calculate do
          y << highlight( 'yay' )
        end
      end

      def __open__component_operation

        yield(

          :parameter, :dry_run, :optional,  # otherwise would be req'd

          :parameter, :message, :optional,
            :description, -> y { y << highlight( 'msg' ) },

          :parameter, :verbose, :is_flag,
            :description, -> { highlight 'verie' },

          :end
        )

        -> dry_run, file, message, verbose, & call_p do  # [#006]#Event-models:#ick

          # see [#015]. these "test case references" draw from there:
          #
          #   • "dry_run"  appropriated optional (flag) #tB2
          #   • "file"  bespoke required #tB3
          #   • "message"  bespoke optional #tB4
          #   • "verbose"  bespoke optional (flag) #tB4
          #   • ("nam nam"  is in the scope set but is unstated)
          #
          # (this operation does NOT test appropriated required !#tB1).

          s = "file:#{ file }"

          if true == dry_run
            s << SPACE_ << 'D'
          end

          if message
            s << SPACE_ << "M:#{ message }"
          end

          if true == verbose
            s << SPACE_ << 'V'
          end

          nn = @__parent_ACS.nim_nam
          if nn
            s << SPACE_ << "N:#{ nn }"
          end

          call_p.call :info, :expression, :k do | y |
            y << s
          end

          NOTHING_
        end
      end
    end
  end
end

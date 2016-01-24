module Skylab::Autonomous_Component_System::TestSupport

  module Modalities::Reactive_Tree::CLI_Integration

    class << self

      def [] tcc
        Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
        tcc.include self ; nil
      end

      def kernel_
        @___kernel ||= Load_kernel___[]
      end
    end  # >>

    Load_kernel___ = -> do

      ds = Local_subject__[]::Dynamic_Source_for_Unbounds.new

      ds.add :Appie, Appie.new

      Home_.lib_.brazen::Kernel.new Here_ do | ke |
        ke.reactive_tree_seed = ds
      end
    end

    class Appie

      def build_unordered_index_stream & cli_oes_p

        @_oes_p = cli_oes_p

        Local_subject__[]::Children_as_unbound_stream[ self, & cli_oes_p ]
      end

      def __wazoozie_foozie__component_operation

        yield :description, -> y do
          y << "have #{ code 'fun' }"
        end

        yield :parameter, :flim_flam, :description, -> y do
          y << code( 'yes' )
        end

        -> flim_flam, & call_p do  # see [#006]#Event-models:#ick

          if call_p
            use_p = call_p
          else
            self._COVER_ME
            use_p =  @_oes_p
          end

          use_p.call :info, :expression, :hello do | y |
            y << "hello #{ code flim_flam }"
          end

          12332
        end
      end

      def __fantazzle_dazzle__component_association

        Faz_Daz
      end

      def receive_component_event asc, i_a, & ev_p

        @_oes_p.call( * i_a, & ev_p )
      end
    end

    class Faz_Daz

      Um_ACS_TS::Be_component[ self ]

      def describe_into_under y, expag
        expag.calculate do
          y << code( 'yay' )
        end
      end

      def __open__component_operation

        yield :parameters, :default, nil,

              :parameter, :verbose, :is_flag,
                :description, -> y { y << 'tha V' },

              :parameter, :dry_run, :is_flag,

              :end

        -> verbose=nil, dry_run=nil, file, & call_p do  # [#006]#Event-models:#ick

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

    # ~ as module

      def subject_CLI
        Home_.lib_.brazen::CLI
      end

      def get_invocation_strings_for_expect_stdout_stderr
        [ 'fam' ]
      end

      def CLI_options_for_expect_stdout_stderr

        [ :back_kernel, Here_.kernel_ ]
      end

    # ~

    Local_subject__ = -> do
      Home_::Modalities::Reactive_Tree
    end

    Here_ = self
  end
end

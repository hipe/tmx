module Skylab::MyTerm::TestSupport

  module Sandboxed_Kernels

    class << self

      def [] tcc

        tcc.send :define_singleton_method,
         :dangerous_memoize_,
           TestSupport_::DANGEROUS_MEMOIZE

        TestLib_::Future_expect[ tcc ]

        tcc.include self

        nil
      end

      define_method :_danger_memo, TestSupport_::DANGEROUS_MEMOIZE

      def _memoize sym, & p

        define_method sym, Callback_::Memoize[ & p ]
      end
    end  # >>

    # ~ assertion methods (might move) & references

    _memoize :appearance_JSON_one_ do
      <<-HERE.unindent.freeze
        {
          "adapter": "imagemagick"
        }
      HERE
    end

    def expect_failed_  # might move
      @result.should eql false
    end

    # ~ preserve entire state (including emissions) of a request

    def begin_state_
      State.new self
    end

    class State

      # visit one particular test context to capture elements of its
      # action under test for subsequent use in several assertions

      def initialize test_context

        @_test_context = test_context

        bx = Callback_::Box.new
        @__em_bx = bx

        @proc = -> * i_a, & ev_p  do

          if @_test_context.do_debug
            @_test_context.debug_IO.puts i_a.inspect
          end

          _a = bx.touch i_a do
            []
          end
          _ = Callback_.test_support::Future_Expect::Event_Record[ i_a, ev_p ]
          _a.push _

          false  # err on this side
        end
      end

      def finish

        remove_instance_variable :@proc

        _bx = remove_instance_variable :@__em_bx
        @emissions = Callback_.test_support::Future_Expect::Emissions.new _bx

        tc = remove_instance_variable :@_test_context

        @result = tc.remove_instance_variable :@result
        @kernel = tc.remove_instance_variable :@subject_kernel_
        freeze
      end

      attr_reader(
        :emissions,
        :proc,
        :kernel,
        :result,
      )
    end

    # ~

    def persistence_payload_for_font_ s  # BE CAREFUL - we don't escape the name!

      <<-HERE.unindent
        {
          "adapter": "imagemagick",
          "adapters": {
            "imagemagick": {
              "background_font" : "#{ s }"
            }
          }
        }
      HERE
    end

    # ~ mutate kernels

    _danger_memo :read_only_kernel_with_no_data_ do

      _path = TestSupport_::Fixtures.dir :empty_esque_directory

      _new_kernel_with_data_path _path
    end

    def new_mutable_kernel_with_nothing_persisted_

      hack_a_kernel_ do | o |

        o.__eradicate_thing
      end
    end

    def new_mutable_kernel_with_no_data_

      td = common_tmpdir_
      td.prepare
      _new_kernel_with_data_path td.to_path
    end

    def new_mutable_kernel_with_appearance_ string

      hack_a_kernel_ do | o |

        o.accept_persistence_payload_string string
      end
    end

    def _new_kernel_with_data_path path

      hack_a_kernel_ do | o |

        o._set_data_path path
      end
    end

    def hack_a_kernel_ & edit

      ke = start_a_kernel_
      edit_kernel_by_ ke, & edit
      ke
    end

    def start_a_kernel_
      Home_::Build_default_application_kernel___[]
    end

    def edit_kernel_by_ ke, & edit
      Edit_kernel__[ ke, & edit ]
      NIL_
    end

    class Edit_kernel__

      class << self
        def [] ke
          yield new ke
          NIL_
        end
        private :new
      end

      def initialize ke
        @_kernel = ke
      end

      # ~ manupulate dootily has

      def __eradicate_thing

        _mock_installation_method :any_existing_read_writable_IO do
          NIL_
        end ; nil
      end

      def _set_data_path path

        _mock_installation_method :_data_path do
          path
        end ; nil
      end

      def accept_persistence_payload_string string

        once = Callback_.memoize do
          require 'stringio'
          io = ::StringIO.new string
          def io.path
            "[mt]/string-IO-xizzi.json"
          end
          io
        end

        @_kernel.send :define_singleton_method, :_string_IO_for_testing_ do
          once[]
        end

        _mock_installation_method :any_existing_read_writable_IO do

          io = once[]
          io.rewind
          io
        end

        NIL_
      end

      def _mock_installation_method m, & p

        _installation_daemon.send :define_singleton_method, m, & p
        NIL_
      end

      def mess_with_installation & xxx

        TS_::Mess_With.call _installation_daemon, & xxx
      end

      def _installation_daemon
        @_kernel.silo :Installation
      end
    end

    # ~ tmpdir

    _danger_memo :common_tmpdir_ do

      _path = ::File.join Home_.lib_.system.defaults.dev_tmpdir_path, '[mt]'

      Home_.lib_.system.filesystem.tmpdir(
        :max_mkdirs, 2,
        :path, _path,
        :debug_IO, debug_IO,
        :be_verbose, do_debug,
      )
    end

    EMPTY_A_ = [].freeze
  end
end

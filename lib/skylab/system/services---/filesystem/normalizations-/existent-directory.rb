module Skylab::System

  class Services___::Filesystem

    class Normalizations_::Existent_Directory < Normalizations_::Path_Based
    private

      def initialize _fs

        @_do_create = nil
        @_IFF_not_exist_do_create = nil
        @_is_dry_run = false
        @_max_mkdirs = 1
        super
      end

      def create=
        @_do_create = true
        @_IFF_not_exist_do_create = false
        KEEP_PARSING_
      end

      def create_if_not_exist=
        @_do_create = false
        @_IFF_not_exist_do_create = true
        KEEP_PARSING_
      end

      def is_dry_run=
        @_is_dry_run = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def max_mkdirs=
        @_max_mkdirs = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      public def execute

        init_exception_and_stat_ path_

        if @stat_
          via_stat_execute   # (public API)

        else
          __when_no_stat
        end
      end

      # ~ 1 of 2 branches

      def __when_no_stat

        if ::Errno::ENOENT::Errno == @exception_.errno

          if @_IFF_not_exist_do_create || @_do_create

            _ok = __can_create
            _ok && __create
          else

            maybe_send_event :error, :enoent do

              Callback_::Event.wrap.exception @exception_, :path_hack

            end
          end
        else

          maybe_send_event :error, :strange_stat_error do
            __via_strange_stat_error_build_event
          end
        end
      end

      def __via_strange_stat_error_build_event

        _ev = Callback_::Event.wrap.exception @exception_, :path_hack

        i_a = _ev.to_iambic

        # (we used to add more members here, now we don't)

        Callback_::Event.inline_via_iambic_and_message_proc i_a, -> y, o do

          y << "cannot create #{ pth o.pathname } because #{
            }some parent path in it is #{ o.message_head.downcase }"

        end
      end

      ## ~~

      def __can_create  # assume path does not exist

        stop_p = __build_proc_for_stop_because_reached_max_mkdirs

        @_num_dirs_needed_to_create = 1  # you need to create at least the tgt
        @_curr_pn = ::Pathname.new ::File.expand_path path_

        while true  # assume current path does not exist

          if stop_p[]
            break next_i = :__cannot_create_because_path_too_deep
          end

          parent_pn = @_curr_pn.dirname

          # if parent_pn equals curr_pn then the root path doesn't exist
          # which is something we are not checking for & probably don't
          # need to except for a logic error sanity check.
          # # #todo - get rid of all hardcoded checks for '/' in univ.

          init_exception_and_stat_ parent_pn.to_path

          if @stat_
            @_pn = parent_pn
            break next_i = :__can_create_via_stat_and_existent_pn
          end

          @_num_dirs_needed_to_create += 1
          @_curr_pn = parent_pn
        end
        send next_i
      end

      def __build_proc_for_stop_because_reached_max_mkdirs

        if -1 == @_max_mkdirs
          NILADIC_FALSEHOOD_
        else
          -> do
            @_max_mkdirs < @_num_dirs_needed_to_create
          end
        end
      end

      def __cannot_create_because_path_too_deep

        maybe_send_event :error, :path_too_deep do

          build_not_OK_event_with(
            :path_too_deep,
            :path, path_, :necessary_path, @_curr_pn.to_path,
            :max_mkdirs, @_max_mkdirs,
            :necessary_mkdirs, @_num_dirs_needed_to_create,

          ) do | y, o |

            _tgt_path = o.path[ o.necessary_path.length + 1 .. -1 ]

            y << "cannot create #{ ick _tgt_path } because #{
             }would have to create at least #{ o.necessary_mkdirs } #{
              }directories, only allowed to make #{ o.max_mkdirs }, and #{
               }#{ pth o.necessary_path } does not exist."
          end
        end
        UNABLE_
      end

      def __can_create_via_stat_and_existent_pn

        if DIRECTORY_FTYPE == @stat_.ftype
          ACHIEVED_
        else
          maybe_send_event :error, :wrong_ftype do
            __via_stat_and_pn_build_wrong_ftype_event DIRECTORY_FTYPE
          end
          UNABLE_
        end
      end

      def __via_stat_and_pn_build_wrong_ftype_event expected_ftype_s

        build_not_OK_event_with( :wrong_ftype,

          :actual_ftype, @stat_.ftype,
          :expected_ftype, expected_ftype_s,
          :subject_path, @_pn.to_path,
          :target_path, path_,

        ) do | y, o |

          _tgt_path = o.target_path[ o.subject_path.length + 1 .. -1 ]

          y << "cannot create #{ _tgt_path } because #{
           }#{ pth o.subject_path } is #{ indefinite_noun o.actual_ftype }#{
            }, must be #{ indefinite_noun o.expected_ftype }"
        end
      end

      ## ~~

      def __create

        maybe_send_event :info, :creating_directory do
          build_neutral_event_with(
            :creating_directory,
            :path, path_,
          )
        end

        d = if @_is_dry_run
          0
        else
          @filesystem.mkdir path_  # result is
        end

        d.zero? or self._COVER_ME  # probably never gets here

        _build_normal_result
      end

      # ~ 2 of 2 branches

      public def via_stat_execute  # :+#public-API

        if DIRECTORY_FTYPE == @stat_.ftype

          if @_do_create

            maybe_send_event :error, :directory_exists do

              build_not_OK_event_with(
                :directory_exists,
                :path, path_ )
            end
          else

            _build_normal_result
          end
        else
          maybe_send_event :error, :wrong_ftype do

            build_wrong_ftype_event_ path_, @stat_, DIRECTORY_FTYPE
          end
        end
      end

      # ~ support

      def _build_normal_result

        Callback_::Known.new_known(
          if @_is_dry_run
            Mock_Dir__.new path_
          else
            ::Dir.new path_
          end
        )
      end

      Mock_Dir__ = ::Struct.new :to_path

      NILADIC_FALSEHOOD_ = -> { false }
    end
  end
end

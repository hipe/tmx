module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Normalization__

        class << self

          def downstream_IO * x_a
            Normalization__::Downstream_IO__.mixed_via_iambic x_a
          end

          def existent_directory * x_a
            Normalization__::Existent_Directory__.mixed_via_iambic x_a
          end

          def upstream_IO * x_a
            Normalization__::Upstream_IO__.mixed_via_iambic x_a
          end

          def unlink_file * x_a
            Normalization__::Unlink_File__.mixed_via_iambic x_a
          end
        end  # >>

        module Common_Module_Methods_

          def mixed_via_iambic x_a
            if x_a.length.zero?
              self
            else
              new do
                process_iambic_fully x_a
                clear_all_iambic_ivars
              end.produce_mixed_result
            end
          end
        end

      private

        def path_exists_and_set_stat_and_stat_error path
          @stat = ::File.stat path
          @stat_e = nil
          ACHIEVED_
        rescue ::Errno::ENOENT, Errno::ENOTDIR => @stat_e  # #todo assimilate the others
          @stat = nil
          UNABLE_
        end

        def via_stat_and_path_build_wrong_ftype_event expected_ftype_s
          build_not_OK_event_with :wrong_ftype,
              :actual_ftype, @stat.ftype,
              :expected_ftype, expected_ftype_s,
              :path, @path do |y, o|

            y << "#{ pth o.path } exists but is not #{
             }#{ indefinite_noun o.expected_ftype }, #{
              }it is #{ indefinite_noun o.actual_ftype }"
          end
        end

        def send_event ev
          @on_event[ ev ]
        end

        DIR_FTYPE_ = 'directory'.freeze

        Entity_ = Headless_._lib.entity

        Event_ = Entity_.event

        Event_.sender self

        FILE_FTYPE_ = 'file'.freeze

      end
    end
  end
end

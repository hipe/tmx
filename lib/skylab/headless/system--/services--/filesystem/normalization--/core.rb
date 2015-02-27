module Skylab::Headless

  module System__

    class Services__::Filesystem

      class Normalization__

        class << self

          def downstream_IO * x_a, & oes_p

            if 1 == x_a.length
              x_a.unshift :path
            end

            Normalization__::Downstream_IO__.mixed_via_iambic x_a, & oes_p
          end

          def existent_directory * x_a, & oes_p
            Normalization__::Existent_Directory__.mixed_via_iambic x_a, & oes_p
          end

          def members
            singleton_class.instance_methods( false ) - [ :members ]
          end

          def upstream_IO * x_a, & oes_p

            if 1 == x_a.length
              x_a.unshift :path
            end

            Normalization__::Upstream_IO__.mixed_via_iambic x_a, & oes_p
          end

          def unlink_file * x_a, & oes_p
            Normalization__::Unlink_File__.mixed_via_iambic x_a, & oes_p
          end
        end  # >>

        module Common_Module_Methods_

          def mixed_with * x_a, & oes_p
            mixed_via_iambic x_a, & oes_p
          end

          def mixed_via_iambic x_a, & oes_p
            if x_a.length.nonzero?
              ok = nil
              x = new do
                accept_selective_listener_proc oes_p
                ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
              end
              ok and x.produce_mixed_result
            else
              self
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

        def build_wrong_ftype_event_ path, stat, expected_ftype_s

          build_not_OK_event_with :wrong_ftype,
              :actual_ftype, stat.ftype,
              :expected_ftype, expected_ftype_s,
              :path, path do |y, o|

            y << "#{ pth o.path } exists but is not #{
             }#{ indefinite_noun o.expected_ftype }, #{
              }it is #{ indefinite_noun o.actual_ftype }"
          end
        end

        Entity_ = Headless_.lib_.entity

        Event_ = Entity_.event

        Event_.selective_builder_sender_receiver self

      end
    end
  end
end

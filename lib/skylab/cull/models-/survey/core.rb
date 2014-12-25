module Skylab::Cull

  class Models_::Survey < Model_

    class << self

      def any_nearest_path_via_looking_upwards_from_path arg, & oes_p

        result = nil

        x = Cull_._lib.filesystem.walk(
          :start_path, arg.value_x,
          :filename, FILENAME__,
          :ftype, DIR_FTYPE_,
          :max_num_dirs_to_look, -1,
          :prop, arg.property,
          :on_event_selectively, -> * i_a, & ev_p do
            result = oes_p[ * i_a, & ev_p ]
            UNABLE_
          end )

        x || result
      end
    end  # >>

    DIR_FTYPE_ = 'directory'.freeze
    FILENAME__ = 'cull-survey'.freeze
    UNABLE_ = false
  end
end

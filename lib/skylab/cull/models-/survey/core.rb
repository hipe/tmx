module Skylab::Cull

  class Models_::Survey < Model_

    class << self

      def any_nearest_path_via_looking_upwards_from_path arg, & oes_p

        result = nil

        x = Cull_._lib.filesystem.walk(
          :start_path, arg.value_x,
          :filename, FILENAME_,
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

    def process_first_edit  & edit_p # hook-in to [br]
      edit_p[ fes = First_Edit_Session__.new ]
      send fes.method_name, * fes.args
    end

    def when_nothing_done_during_edit_session
      nil
    end

    def create_via_path_arg pa
      @path_arg = pa
      @special_normalize_method_name = :via_path_arg_create
      ACHIEVED_
    end

    def normalize
      super && ___normalize
    end

    def ___normalize
      send @special_normalize_method_name
    end

    def via_path_arg_create
      Self_::Actors__::Create[ self ]
    end

    def handle_event_selectively
      @on_event_selectively
    end

    attr_accessor :config_path

    attr_reader :path_arg

    class First_Edit_Session__

      def initialize
        @method_name = :when_nothing_done_during_edit_session
      end

      attr_reader :method_name, :args

      def create_via_path_arg path_arg
        @args = [ path_arg ]
        @method_name = :create_via_path_arg
      end
    end

    DIR_FTYPE_ = 'directory'.freeze
    FILENAME_ = 'cull-survey'.freeze
    Self_ = self
    UNABLE_ = false
  end
end

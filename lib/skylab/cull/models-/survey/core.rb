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
      send fes.receive_first_edit_data_method_name, * fes.args
    end

    def normalize
      super && ___via_post_normalize_method_name
    end

    def ___via_post_normalize_method_name
      send @post_normalize_method_name
    end

    # ~ edit session where nothing happens is gigo

    def recv_nothing_from_edit_session
      nil
    end

    # ~ edit session for create

    def recv_edit_data_for_create_via_path_arg pa
      @path_arg = pa
      @post_normalize_method_name = :via_path_arg_create
      ACHIEVED_
    end

    attr_reader :path_arg  # talk to the actor

    def config_path
      ::File.join( @path_arg.value_x, CONFIG_FILENAME_ )
    end

    def via_path_arg_create
      Self_::Actors__::Create[ self ]
    end

    # ~ edit session for retrieve

    def recv_edit_data_for_valid_workspace_path path

      @_existent_workspace_path = path
      @post_normalize_method_name = :via_existent_workspace_path_normalize
      ACHIEVED_
    end

    def via_existent_workspace_path_normalize

      @cfg_for_read = Brazen_.data_stores::Git_Config.parse_path(
        ::File.join( @_existent_workspace_path, CONFIG_FILENAME_ ),
        & handle_event_selectively )

      if @cfg_for_read
        ACHIEVED_
      else
        @cfg_for_read
      end
    end

    def to_datapoint_stream_for_synopsis
      @cfg_for_read.to_section_stream( & handle_event_selectively ).map_by do | x |
        Self_::Models__::Section_Summary.new x
      end
    end

    # ~ shared support

    def to_event
      Brazen_.event.inline_OK_with :survey,
          :path, @path_arg.value_x,
          :is_completion, true
    end

    def handle_event_selectively
      @on_event_selectively
    end

    class First_Edit_Session__

      def initialize
        @receive_first_edit_data_method_name = :recv_nothing_from_edit_session
      end

      attr_reader :receive_first_edit_data_method_name, :args

      def create_via_path_arg path_arg
        @args = [ path_arg ]
        @receive_first_edit_data_method_name = :recv_edit_data_for_create_via_path_arg
        nil
      end

      def existent_valid_workspace_path path
        @args = [ path ]
        @receive_first_edit_data_method_name = :recv_edit_data_for_valid_workspace_path
        nil
      end
    end

    CONFIG_FILENAME_ = 'config'.freeze
    DIR_FTYPE_ = 'directory'.freeze
    FILENAME_ = 'cull-survey'.freeze
    Self_ = self
    UNABLE_ = false
  end
end

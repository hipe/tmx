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


    def process_first_edit_by & edit_p  # hook-in to [br]
      edit_p[ fes = First_Edit_Session__.new ]
      send fes.receive_first_edit_data_method_name, * fes.args
    end

    def normalize
      super && ___via_post_normalize_method_name
    end

    def ___via_post_normalize_method_name
      send @post_normalize_method, * @post_normalize_args
    end

    # ~ edit session where nothing happens is gigo

    def recv_nothing_from_edit_session
      nil
    end

    # ~ edit session for create

    def recv_create_via_mutable_arg_box bx
      @post_normalize_args = bx
      @post_normalize_method = :create_via_mutable_arg_box
      ACHIEVED_
    end

    def create_via_mutable_arg_box bx

      workspace_dir = Self_::Actors__::Create[ bx, & handle_event_selectively ]
      workspace_dir and begin
        @___path___ = workspace_dir
        ACHIEVED_
      end
    end

    # ~ edit session for retrieve

    def recv_edit_data_for_valid_workspace_path path

      @post_normalize_args = path
      @post_normalize_method = :normalize_via_existent_workspace_path

      ACHIEVED_
    end

    def normalize_via_existent_workspace_path path

      o = Brazen_.data_stores::Git_Config.parse_path(
        ::File.join( path , CONFIG_FILENAME_ ),
        & handle_event_selectively )

      o and begin
        @cfg_for_read = o
        ACHIEVED_
      end
    end

    def to_datapoint_stream_for_synopsis
      @cfg_for_read.to_section_stream( & handle_event_selectively ).map_by do | x |
        Self_::Models__::Section_Summary.new x
      end
    end

    # ~ property-level exposures

    def receive_upstream_argument arg
      upstream = Self_::Actions::Upstream.edit_entity(
          self,
          handle_event_selectively ) do | o |

        o.arg arg
      end
      if upstream
        @upstream = upstream
        maybe_send_event :info, :set_upstream do
          upstream.to_event
        end
        ACHIEVED_
      else
        upstream
      end
    end

    # ~ shared support

    def members
      [ :path ]
    end

    def to_event
      Brazen_.event.inline_OK_with :survey,
        :path, ::File.join( @___path___, FILENAME_ ),
        :is_completion, true
    end

    def handle_event_selectively
      @on_event_selectively
    end

    include Simple_Selective_Sender_Methods_

    class First_Edit_Session__

      def initialize
        @receive_first_edit_data_method_name = :recv_nothing_from_edit_session
      end

      attr_reader :receive_first_edit_data_method_name, :args

      def create_via_mutable_bound_argument_box bx
        @args = bx
        @receive_first_edit_data_method_name = :recv_create_via_mutable_arg_box
        nil
      end

      def existent_valid_workspace_path path
        @args = [ path ]
        @receive_first_edit_data_method_name = :recv_edit_data_for_valid_workspace_path
        nil
      end
    end

    module Survey_Action_Methods_
    private

      def via_path_argument_resolve_existent_survey

        path = Models_::Survey.any_nearest_path_via_looking_upwards_from_path(
          get_argument_via_property_symbol( :path ),
          & handle_event_selectively )

        path and rslv_existent_survey_via_path path
      end

      def rslv_existent_survey_via_path path
        sv = Models_::Survey.edit_entity @kernel, handle_event_selectively do | o |
          o.existent_valid_workspace_path path
        end
        if sv
          @survey = sv
          ACHIEVED_
        else
          sv
        end
      end

      def normalize_path str
        if str
          if str.length.zero?
            UNABLE_
          elsif ::File::SEPARATOR == str[ 0 ]
            str
          else
            ::File.join @survey.path, str
          end
        else
          str
        end
      end
    end

    CONFIG_FILENAME_ = 'config'.freeze
    DIR_FTYPE_ = 'directory'.freeze
    FILENAME_ = 'cull-survey'.freeze
    Self_ = self
    UNABLE_ = false
  end
end

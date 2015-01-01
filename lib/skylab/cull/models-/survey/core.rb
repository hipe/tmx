module Skylab::Cull

  class Models_::Survey < Model_

    class << self

      def any_nearest_path_via_looking_upwards_from_path arg, & oes_p

        result = nil

        x = Cull_.lib_.filesystem.walk(
          :start_path, arg.value_x,
          :filename, FILENAME_,
          :ftype, DIR_FTYPE_,
          :max_num_dirs_to_look, -1,
          :prop, arg.property,
          :on_event_selectively, -> * i_a, & ev_p do
            result = oes_p[ * i_a, & ev_p ]
            UNABLE_
          end )

        if x
          x.to_path
        else
          result
        end
      end
    end  # >>

    # ~ #hook-in to [br] edit session API

    def first_edit_shell
      First_Edit_Session__.new
    end

    def process_first_edit sh
      send sh.receive_first_edit_data_method_name, * sh.args
    end

    # ~ end

    # ~ edit session where nothing happens is gigo

    def _first_edit_when_nothing
      nil
    end

    # ~ edit session for create

    def _create_via_mutable_arg_box bx

      x = Self_::Actors__::Create[ bx, & handle_event_selectively ]
      x and begin
        @___path___ = x
        self
      end
    end

    # ~ edit session for retrieve

    def _retrieve_via_valid_path path

      cfg = Brazen_.data_stores::Git_Config.parse_path(
        ::File.join( path, CONFIG_FILENAME_ ),
        & handle_event_selectively )

      cfg and begin
        @_path = path
        @cfg_for_write = nil
        @cfg_for_read = cfg
        self
      end
    end

    def path
      @_path
    end

    private def _config
      @cfg_for_write || @cfg_for_read
    end

    def to_datapoint_stream_for_synopsis
      @cfg_for_read.to_section_stream( & handle_event_selectively ).map_by do | x |
        Self_::Models__::Section_Summary.new x
      end
    end

    # ~ subsequent edit session (edit an existing (new or persisted) survey)

    def subsequent_edit_shell  # #hook-in [br]
      Subsequent_Edit_Shell__.new
    end

    class Subsequent_Edit_Shell__

      # think of this as a structure for modeling all the changes that might
      # be (and were requested to be) made to an existing entity. first, we
      # cache all the changes here as one atomic-esque structure. then in a
      # separate step we flush the changes to the entity. then IFF flushing
      # these changes succeeds, the entity can [re-]persist itself. in this
      # way the entity can convene all attempts at persisting into one step

      def initialize
        @a = []
      end

      attr_reader :a

      def set_upstream_via_mutable_arg_box bx
        @a.push :_set_upstream_via_mutable_arg_box, bx
        nil
      end

      def delete_upstream
        @a.push :_delete_upstream, nil
        nil
      end
    end

    def process_subsequent_edit sh  # #hook-in [br]

      # for now, we assume (reasonably) that all successful edits sessions
      # mutate the entity and therefor should be persisted.

      ok = true
      sh.a.each_slice 2 do | sym, x |
        ok = send sym, x
        ok or break
      end
      ok && normalize && _end_edit_session_by_writing_self
    end

    # ~ property-level exposures

    def _set_upstream_via_mutable_arg_box bx

      upstream = Self_::Actions::Upstream.edit_entity( self, handle_event_selectively ) do | o |

        o.mutable_arg_box bx

      end

      upstream and accpt_upstream upstream
    end

    def accpt_upstream upstream

      ok = _set_monadic_slotular_section upstream.marshal_dump, :upstream

      ok and begin

        @upstream = upstream

        maybe_send_event :info, :set_upstream do
          upstream.to_event
        end

        ACHIEVED_
      end
    end

    def _delete_upstream _
      _unset_monadic_slotular_section :upstream, :no_upstream_set, :deleted_upstream
    end

    # ~ shared support

    def maybe_relativize_path path

      relpath = ::Pathname.new( path ).relative_path_from(
        ::Pathname.new( @_path ) ).to_path

      if relpath.length < path.length
        relpath
      else
        path
      end

    end

    def members
      [ :path ]
    end

    def to_event
      Brazen_.event.inline_OK_with :survey,
        :path, ::File.join( @___path___, FILENAME_ ),
        :is_completion, true
    end

  private

    def _unset_monadic_slotular_section section_symbol, no_sym, yes_sym

      cfg = cfg_for_write

      st = cfg.sections.to_stream.reduce_by do | x |
        section_symbol == x.external_normal_name_symbol
      end

      delete_these = st.to_a

      if delete_these.length.nonzero?
        a = cfg.sections.delete_these_ones delete_these
        maybe_send_event :info, yes_sym do
          bld_deleted_slotular a, yes_sym, section_symbol
        end
        ACHIEVED_
      else
        maybe_send_event :error, :no_upstream_set do
          build_not_OK_event_with :no_upstream_set
        end
        UNABLE_
      end
    end

    def bld_deleted_slotular a, yes_sym, sym

      build_event_with yes_sym,
          :symbol, sym,
          :count, a.length, :ok, true do | y, o |

        if 1 == o.count
          y << "deleted #{ par o.symbol.id2name }"
        else
          y << "deleted #{ o.count } #{ par plural_noun o.symbol.id2name }"
        end
      end
    end

    def _set_monadic_slotular_section value_string, section_symbol

      cfg = cfg_for_write

      st = cfg.sections.to_stream.reduce_by do | x |
        section_symbol == x.external_normal_name_symbol
      end

      sec = st.gets
      if sec
        change_the_name_of_this_one = sec
        sec = st.gets
        if sec
          delete_these = [ sec ]
          sec = st.gets
          while sec
            delete_these.push sec
            sec = st.gets
          end
        end
      end

      if delete_these
        cfg.sections.delete_these_ones delete_these
      end

      if change_the_name_of_this_one
        change_the_name_of_this_one.set_subsection_name value_string
      else
        _ = cfg.sections.touch_section value_string, section_symbol
        _ ? ACHIEVED_ : UNABLE_
      end
    end

    def _end_edit_session_by_writing_self
      cfg_for_write.write
    end

    def cfg_for_write
      @cfg_for_write ||= begin
        x = @cfg_for_read
        @cfg_for_read = nil
        Brazen_.data_stores::Git_Config::Mutable.parse_input_id(
          x.input_id,
          & @on_event_selectively )
      end
    end

    include Simple_Selective_Sender_Methods_

    class First_Edit_Session__

      # a frontier example of an experimental edit session category wherein
      # it ulitmately resolves to do only one thing (whatever was last)

      def initialize
        @receive_first_edit_data_method_name = :_first_edit_when_nothing
      end

      attr_reader :receive_first_edit_data_method_name, :args

      def create_via_mutable_bound_argument_box bx
        @args = bx
        @receive_first_edit_data_method_name = :_create_via_mutable_arg_box
        nil
      end

      def existent_valid_workspace_path path
        @args = path
        @receive_first_edit_data_method_name = :_retrieve_via_valid_path
        nil
      end
    end

    module Survey_Action_Methods_
    private

      def via_path_argument_resolve_existent_survey

        path = Models_::Survey.any_nearest_path_via_looking_upwards_from_path(
          get_argument_via_property_symbol( :path ),
          & handle_event_selectively )

        path and rslv_existent_survey_via_existent_path path
      end

      def rslv_existent_survey_via_existent_path path

        sv = Models_::Survey.edit_entity @kernel, handle_event_selectively do | o |
          o.existent_valid_workspace_path path
        end

        sv and begin
          @survey = sv
          ACHIEVED_
        end
      end
    end

    CONFIG_FILENAME_ = 'config'.freeze
    DIR_FTYPE_ = 'directory'.freeze
    FILENAME_ = 'cull-survey'.freeze
    Self_ = self
  end
end

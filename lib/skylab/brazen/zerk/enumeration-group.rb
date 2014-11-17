module Skylab::Brazen

  module Zerk

    class Enumeration_Group  # see #note-enum in [#062]

      def initialize i_a, group_name_i, branch
        @active_boolean = nil
        @branch = branch
        @group_name = Callback_::Name.via_variegated_symbol group_name_i
        @has_active_boolean = false
        @i_a = i_a
        @is_interactive = branch.is_interactive
      end

      attr_reader :active_boolean, :has_active_boolean

      def activate name_i
        change_did_occur = maybe_activate name_i
        if change_did_occur
          when_changed
        else
          when_not_changed
        end
      end

    private

      def maybe_activate name_i  # no not trigger persistence from here
        @active_boolean = @has_active_boolean = nil
        change_did_occur = false
        @first = nil
        @i_a.each do |i|
          boolean = @branch[ i ]
          @first ||= boolean
          if name_i == i
            if boolean.is_activated
              ok = true
            else
              ok = boolean.receive_activation
              if ok
                change_did_occur = true
              end
            end
            if ok
              @has_active_boolean = true
              @active_boolean = boolean
            end
          elsif boolean.is_activated
            _ok = boolean.receive_deactivation
            _ok and change_did_occur = true
          end
        end
        change_did_occur
      end

      def when_not_changed
        if @is_interactive
          @branch.change_focus_to @branch
        end
        PROCEDE_
      end


      def when_changed
        @branch.receive_branch_changed_notification
        if @is_interactive
          @branch.change_focus_to @branch
        end
        PROCEDE_
      end

    public

      def can_receive_focus
        false
      end

      def marshal_load name_of_active_child_string, & ev_p
        name_i = name_of_active_child_string.intern
        _ok = @branch.has_name name_i
        if _ok
          _change_did_occur = maybe_activate name_i
          _change_did_occur  # kinda nasty - this becomes 'OK'
        else
          when_marshal_load_fail name_i, ev_p
        end
      end

      def name_i
        @group_name.as_variegated_symbol
      end

      def to_body_item_value_string
      end

      def to_marshal_pair
        if @has_active_boolean
          Callback_.pair.new @active_boolean.name_i, @group_name.as_slug.intern
        end
      end

    private

      def when_marshal_load_fail name_i, ev_p
        ev_p.call :error, :marshal_load_error do
          self._ETC  # #todo
        end
        UNABLE_
      end
    end
  end
end

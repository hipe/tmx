module Skylab::TreetopTools

  class Parser::Load

    class Normalize_and_validate_paths__  # this looks like :+[#hl-022] but may not be

      Callback_::Actor.call self, :properties,
        :root_bp,
        :event_receiver  # and proprietor

      Callback_::Event.selective_builder_sender_receiver self

      def execute
        resolve_pathname_actual_a
        ok = nil
        @pathname_actual_a.each do |bp|
          ok = process_bound_property bp
          ok or break
        end
        ok
      end

      def resolve_pathname_actual_a
        @pathname_actual_a = @event_receiver.bound_parameters.where do |bp|
          if bp.known? :pathname
            bp[ :pathname ]
          end
        end.to_a ; nil
      end

      def process_bound_property bp
        if bp.value
          process_valued_bound_property bp
        else
          PROCEDE_  # it path wasn't specified, leave brittany alone
        end
      end

      def process_valued_bound_property bp
        pn = bp.value
        ok = if pn.absolute?
          PROCEDE_
        else
          expand_relative_path bp
        end
        if ok
          ok = process_absolute_bound_pathname bp
        end
        ok
      end

      def process_absolute_bound_pathname bp
        if bp.value.exist?
          process_absolute_when_exists bp
        else
          process_absolute_when_not_exists bp
        end
      end

      def process_absolute_when_exists bp
        ok = PROCEDE_
        if bp.parameter.dir?
          if ! bp.value.directory?
            send_not_directory_error bp
            ok = UNABLE_
          end
        end
        ok
      end

      def process_absolute_when_not_exists bp
        ok = PROCEDE_
        if bp.parameter.known? :exist
          if :must == bp.parameter.exist
            send_not_found_error bp
            ok = UNABLE_
          end
        end
        ok
      end

      def expand_relative_path bp
        root_pn = produce_root_pn_given_pathname_bp bp
        if root_pn
          bp.value = root_pn.join bp.value
          PROCEDE_
        else
          UNABLE_
        end
      end

      def produce_root_pn_given_pathname_bp bp
        @did_resolve_root_pn ||= resolve_root_pn( bp )
        @root_pn
      end

      def resolve_root_pn bp
        x = @root_bp.value
        if x
          if x.absolute?
            @root_pn = x
          else
            send_not_abspath_error bp
            @root_pn = false
          end
        else
          send_no_anchor_error bp
          @root_pn = false
        end
        true
      end

      def send_not_abspath_error prop
        prop_ = @root_bp
        _ev = build_not_OK_event_with :not_absolute_path, :prop, prop do |y, o|
          y << "#{ prop_.normalized_parameter_name } must be an absolute #{
            }path in order to expand paths like #{ prop.label }"
        end
        send_error_event _ev
      end

      def send_no_anchor_error prop
        prop_ = @root_bp
        _ev = build_not_OK_event_with :no_anchor_path do |y, o|
          y << "#{ prop_.normalized_parameter_name } must be set #{
            }in order to support a relative path like #{ prop.label }!"
        end
        send_error_event _ev
      end

      def send_not_directory_error prop
        _ev = build_not_OK_event_with :not_a_directory, :prop, prop do |y, o|
          y << "#{ o.prop.label } is not a directory: #{ pth prop.value }"
        end
        send_error_event _ev
      end

      def send_not_found_error prop
        _ev = build_not_OK_event_with :not_found, :prop, prop do |y, o|
          y << "#{ prop.label } not found: #{ pth prop.value }"
        end
        send_error_event _ev
      end

      def send_error_event ev
        @event_receiver.receive_error_event ev
      end
    end
  end
end

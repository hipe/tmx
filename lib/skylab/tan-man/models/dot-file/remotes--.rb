module Skylab::TanMan

  module Models

    module DotFile
      TanMan::Sub_Client[ self, :client_services, :named, :remotes__ ]
      remotes___class
      class Remotes__
        delegate :emit, :expression_agent

        def add_notify x_a
          Addition__.new( self, x_a ).flush
        end

        def get_remote_stream_notify
          Scanner_Maker__.new( self ).flush
        end

        def remove_with_dry_run_and_locator_notify dry_run, locator
          Removal__.new( self, [ :dry_run, dry_run, :locator, locator ] ).flush
        end

        def local_cfg
          _up.controllers.config.local
        end

        def rewrite_config_notify
          _cnt = _up.controllers.config ; _cfg = local_cfg
          _cnt.write_resource _cfg
        end

        def rewrite_config_with_is_dry_notify is_dry
          _cnt = _up.controllers.config ; _cfg = local_cfg
          _cnt.write_resource_with_is_dry _cfg, is_dry
        end

        def _controllers
          _up.controllers
        end

        def full_dotfile_pn
          _up.full_dotfile_pathname
        end

        def section_stream
          get_remote_stream_notify
        end
      end
    end

    class DotFile::Remotes__

      module Action_Methods__

        def initialize client, x_a=EMPTY_A_
          super()
          @client = client
          self[ x_a.shift ] = x_a.shift while x_a.length.nonzero?
          post_init
          nil
        end

        def flush
          validate && execute
        end

      private

        def post_init ; end
        def validate ; true end
        def execute ; false end

        def section_name
          [ dot_rel_pn.to_s.inspect, :remote, @remote_type,
              script_rel_pn.to_s.inspect ] * ' '
        end

        def dot_rel_pn
          @client.full_dotfile_pn.relative_path_from cfg.anchor_pathname
        end

        def script_rel_pn
          script_full_pn.relative_path_from cfg.anchor_pathname
        end

        def script_full_pn
          @sfpn ||= ::Pathname.new ::File.expand_path @script
        end

        def cfg
          @cfg ||= @client.local_cfg
        end

        def rewrite_config
          @client.rewrite_config_notify
        end

        def rewrite_config_with_is_dry is
          @client.rewrite_config_with_is_dry_notify is
        end

        def emit_error_message *a, &p
          emit_msg_notify :error, a, p
        end

        def emit_info_message *a, &p
          emit_msg_notify :info, a, p
        end

        def emit_msg_notify i, a, p
          _msg_s = @client.expression_agent.calculate( * a, & p )
          @client.emit i, _msg_s
          nil
        end
      end

      def self.Action__ * i_a, &p
        Headless::Services::Basic::Struct.new( * i_a ) do
          include Action_Methods__
          class_exec( & p )
        end
      end

      Removal__ = Action__ :dry_run, :locator do
        def post_init
          @locator or never
          nil
        end
        def execute
          found_a = [ ]
          if (( scn = @client.section_stream ))
            while (( section = scn.gets ))
              if @locator == section.locator
                found_a << section.collapse
              end
            end
          end
          case found_a.length
          when 0 ; not_found_in_stream scn
          when 1 ; remove_entity found_a[ 0 ]
          else when_multiple found_a
          end
        end
      private
        def not_found_in_stream scn
          loc = @locator ; d = scn.count
          emit_error_message do
            "#{ ick loc } was not found among #{ d } remote#{ s d }"
          end
          false
        end
        def when_multiple found_a
          d = found_a.length
          emit_info_message do
            "#{ d } remotes were found with locator #{ ick @locator }. #{
            }removing the first one found."
          end
          remove_entity found_a[ 0 ]
        end

        def remove_entity remote
          cfg.remove_entity_by_section_name remote.entity_key do |o|
            o.on_not_found -> e do
              emit_error_message( * e.to_a, & e.message_proc )
              false
            end
            o.on_success -> e do
              emit_info_message( * e.to_a, & e.message_proc )
              rewrite_config_with_is_dry @dry_run
            end
          end
        end
      end

      Addition__ = Action__( :remote_type, :script, :attribute_a,
                             :is_dry, :be_verbose ) do
        def post_init
          @script && @remote_type && @attribute_a or never
          nil
        end

        def validate
          r = false
          begin
            if ! (( pn = script_full_pn )).exist?
              @client.emit :error, ( @client.expression_agent.calculate do
                "script must first exist: #{ escape_path pn }"
              end )
              break
            end
            r = true
          end while nil
          r
        end

        def execute
          _name_s = section_name
          _y = [ :attributes, @attribute_a.map( & :to_s ) ]
          bx = Headless::Services::Basic::Box.new
          cfg.into_entity_merge_properties_emitting_to_p _name_s, _y,
            -> type_i, k, v_, v=nil do
              bx.has?( type_i ) or bx.add type_i, []
              bx[ type_i ] << [ k, v_, v ]
            end
          ev = Event__.new @remote_type, @script,
            bx[ :same ], bx[ :add ], bx[ :change ]
          @client.emit :event_structure, ev
          if ev.change_occurred
            rewrite_config
          else
            @client.emit :info, "no change in config file."
            nil
          end
        end
        #

        Event__ = self._TODO_data_event.new do |remote_type, remote_value,
            any_same_a, any_add_a, any_change_a|
          y = [ ]
          any_same_a and y << "#{ and_( any_same_a.map { |a| lbl a[ 0 ] } ) } #{
            }#{ s :was } same"
          any_add_a and y << "added #{ and_( any_add_a.map do |i, x|
            "#{ lbl i }: #{ ick x }"
          end ) }"
          any_change_a and ( -> ary do
            y << "changed #{ and_ ary.map { |a| lbl a[ 0] } } #{
              }from #{ and_ ary.map { |a| ick a[ 1 ] } } #{
              }to #{ and_ ary.map { |a| ick a[ 2 ] } }#{
              }#{ " respectively" if 1 < ary.length }"
          end )[ any_change_a ]
          s = y.length.zero? ? "nothing happened" : ( y * ' - ' )
          "#{ s } with #{ remote_type } #{ ick remote_value }"
        end
        class Event__
          def change_occurred
            !! ( @any_add_a || @any_change_a )
          end
        end
      end

      Scanner_Maker__ = Action__ do
        def execute
          fly = Remote_Fly__.new
          rx = /\A#{ ::Regexp.escape dot_rel_pn.to_s.inspect } remote (?<rest>.+)\z/
          scn = @client.local_cfg.get_section_scanner_with_map_reduce_p -> x do
            if (( md = rx.match x.key ))
              fly.set_node_and_md x, md  # `md` is used as the "entity key"!
              fly
            end
          end
          scn
        end
      end
      #
      class Scanner__ < ::Proc
        alias_method :gets, :call
        attr_accessor :rewind_p
        def rewind ; @rewind_p.call end
      end

      class Remote_Fly__

        def set_node_and_md section, md
          @is_parsed = false ; @locator_s = nil ; @md = md
          @remote_type_s = nil ; @section = section
          nil
        end

        def collapse_notify locator, md, remote_type, section
          @is_parsed = true ; @locator_s = locator ; @md = md
          @remote_type_s = remote_type ; @section = section
          nil
        end

        def members
          self.class::MEMBER_I_A__
        end
        MEMBER_I_A__ = [ :remote_type, :locator, :attributes ].freeze

        def to_a ; members.map( & method( :send ) ) end

        def entity_key
          @md.string
        end

        def remote_type
          @is_parsed or parse
          @remote_type_s
        end

        def locator
          @is_parsed or parse
          @locator_s
        end

        def attributes
          if (( a = any_attribute_a ))
            a * ', '
          end
        end
        #
        def any_attribute_a
          if (( s = @section[ 'attributes' ] ))
            if LIST_RX__ =~ s
              TanMan::Services::JSON.parse s
            end
          end
        end ; private :any_attribute_a
        #
        t = '"[^"]*"'
        LIST_RX__ = /\A\[(?:#{ t }(?:,[ ]?#{ t })*)?\]\z/  # a subset of JSON

        def collapse
          otr = self.class.new
          otr.collapse_notify locator, @md, remote_type, @section
          otr
        end

      private

        def parse
          @is_parsed = true
          md = RX__.match @md[ :rest ]
          @remote_type_s, @locator_s = ( md.captures if md )
          nil
        end
        RX__ = /\A([^ ]+) "([^"]+)"\z/
      end
    end
  end
end

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

        def local_cfg
          _up.controllers.config.local
        end

        def rewrite_config_notify
          _cfg = local_cfg ; _cnt = _up.controllers.config
          _cnt.write_resource _cfg
        end

        def _controllers
          _up.controllers
        end

        def full_dotfile_pn
          _up.full_dotfile_pathname
        end
      end
    end

    class DotFile::Remotes__

      module Action_Methods__

        def initialize client, x_a
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
      end

      def self.Action__ * i_a, &p
        Headless::Services::Basic::Struct.new( * i_a ) do
          include Action_Methods__
          class_exec( & p )
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
        Event__ = TanMan::Event_.new( :remote_type, :remote_value,
            :any_same_a, :any_add_a, :any_change_a ) do |rt, rv, s_, a_, c_|
          y = [ ]
          s_ and y << "#{ and_( s_.map { |a| lbl a[ 0 ] } ) } #{
            }#{ s :was } same"
          a_ and y << "added #{ and_( a_.map do |i, x|
            "#{ lbl i }: #{ ick x }"
          end ) }"
          c_ and y << "changed #{ and_ c_.map { |a| lbl a[ 0] } } #{
            }from #{ and_ c_.map { |a| ick a[ 1 ] } } #{
            }to #{ and_ c_.map { |a| ick a[ 2 ] } }#{
            }#{ " respectively" if 1 < c_.length }"
          s = y.length.zero? ? "nothing happened" : ( y * ' - ' )
          "#{ s } with #{ rt } #{ ick rv }"
        end
        class Event__
          def change_occurred
            !! ( @any_add_a || @any_change_a )
          end
        end
      end
    end
  end
end

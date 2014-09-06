module Skylab::Brazen

  module Entity

    class Event

      class Prototype__ < self  # :[#023].

        class << self
          def via_iambic_and_message_proc x_a, p
            Build__[ x_a, p ]
          end
        end

        class Build__

          Callback_::Actor[ self, :properties, :x_a, :message_proc ]

          def execute
            scn = Iambic_Scanner.new 0, @x_a
            cls = ::Class.new Prototype__
            _MESSAGE_PROC_ = @message_proc
            cls.class_exec do
              _TERMINAL_CHANNEL_I_ = scn.gets_one
              define_method :terminal_channel_i do _TERMINAL_CHANNEL_I_ end
              define_method :message_proc do _MESSAGE_PROC_ end
              _BOX_ = Box_.new
              while scn.unparsed_exists
                prop = Prop__.new scn.gets_one, scn.gets_one
                _BOX_.add prop.name_i, prop
                attr_reader prop.name_i
              end
              _BOX_.freeze
              define_singleton_method :prop_bx do _BOX_ end
              define_method :reflection_box do _BOX_ end
            end
            cls
          end
        end

        class Prop__
          def initialize i, x
            @name_i = i
            @name_as_ivar = :"@#{ i }"
            @default_value = x
            freeze
          end
          attr_reader :name_i, :name_as_ivar, :default_value
        end

        class << self
          def [] * x_a
            construct do
              init_via_value_x_a x_a
              freeze
            end
          end
        end

        def verb_lexeme
        end

      private

        def init_via_value_x_a x_a
          bx = reflection_box
          x_a.length.times do |d|
            instance_variable_set bx.at_position( d ).name_as_ivar, x_a.fetch( d )
          end
          x_a.length.upto( bx.length - 1 ) do |d|
            prop = bx.at_position d
            instance_variable_set prop.name_as_ivar, prop.default_value
          end ; nil
          # caller will probably freeze
        end

      protected
        def init_copy_with x_a
          bx = ivar_box
          x_a.each_slice( 2 ) do |i, x|
            instance_variable_set bx.fetch( i ), x
          end
          self
        end
      private
        def ivar_box
          self.class.ivar_bx
        end

        class << self
          def ivar_bx
            @ivar_bx ||= bld_ivar_bx
          end
        private
          def bld_ivar_bx
            bx = Box_.new
            prop_bx.each_pair do |i, prop|
              bx.add i, prop.name_as_ivar
            end
            bx.freeze
          end
        end
      end
    end
  end
end

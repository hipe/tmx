module Skylab::TanMan

  class Kernel__

    class Properties < ::Class.new( ::Class.new )  # see [#082]

      Base__ = superclass  # #note-2

      Base_ = Base__.superclass  # #note-1

      class Base__

        TanMan_::Lib_::Entity[][ self, -> do

          o :meta_property, :memoized,
            :property_hook, -> prop do
              prop.reader_method_name = :read_memoized_property
              p = -> do
                x = prop.memoized[] ; p = -> { x } ; x
              end
              prop.memoized_value_p = -> { p[] }
            end

          property_class_for_write
          class self::Property
            attr_accessor :reader_method_name, :memoized_value_p
          end

        end ]
      end

      TanMan_::Lib_::Entity[][ self, -> do

        o :memoized, -> { 'holy-smack.dot' }, :property, :default_starter_file

        o :memoized, -> do
          TanMan_::Lib_::Home_directory_pathname[].join( 'tanman-config' ).to_s
        end, :property, :global_conf_path

        o :memoized, -> { 'config' }, :property, :local_conf_config_name

        o :memoized, -> { '.tanman' }, :property, :local_conf_dirname

        o :memoized, -> { }, :property, :local_conf_maxdepth

      end ]

      class Base__

        def initialize
          freeze
        end

        def names
          self.class.properties.get_names
        end

        def any_retriever_for i
          if self.class.properties.has_name i
            self
          end
        end

        def retrieve_value i
          prop = self.class.properties.fetch i
          send prop.reader_method_name, prop
        end
      private
        def read_memoized_property prop
          prop.memoized_value_p[]
        end
      end

      class Base_

        def with_frame * a
          if 1 == a.length
            h = a.first
          else
            h = {} ; a.each_slice( 2 ) { |i, x| h[ i ] = x }
          end
          _frame = Properties::Models__::Hash_Adapter.new h
          Models__::Stack.new self do |stack|
            stack.push_frame _frame
          end
        end
      end
    end
  end
end

module Skylab::Zerk

  module CLI

    module Table

      # NOTE - this is [#050] the eventual home of "unified table". however
      # we do *NOT* want this newer file to clobber history in the older files
      # so think of everything in here as temporary, to be spliced into the
      # older files at the time of unification.

      module Models

        class Schema

          class << self
            alias_method :define, :new
            undef_method :new
          end  # >>

          def initialize
            @_receive_field = :__receive_first_field
            yield self
            @field_box.freeze
            freeze
          end

          def add_field_via_normal_name_symbol sym, * meta
            send @_receive_field, Field___.new( sym, meta )
            NIL
          end

          def __receive_first_field fld
            @field_box = Common_::Box.new
            @_receive_field = :__receive_field_normally
            send @_receive_field, fld
          end

          def __receive_field_normally fld
            @field_box.add fld.normal_name_symbol, fld
            NIL
          end

          attr_reader(
            :field_box,
          )
        end

        # ==

        class Field___

          def initialize sym, rest
            @normal_name_symbol = sym
            if rest.length.nonzero?
              @_scn = Common_::Polymorphic_Stream.via_array rest
              begin
                instance_exec( & FIELD_META___.fetch( @_scn.gets_one ) )
              end until @_scn.no_unparsed_exists
              remove_instance_variable :@_scn
            end
          end

          FIELD_META___ = {
            numeric: -> { @is_numeric = true },
          }

          def name
            @name ||= Common_::Name.via_variegated_symbol @normal_name_symbol
          end

          attr_reader(
            :is_numeric,
            :normal_name_symbol,
          )
        end

        # ==
      end
    end
  end
end

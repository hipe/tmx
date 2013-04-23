module Skylab::Cull

  class Models::Data::Source::Collection

    Face::Model.enhance( self ).services %i|
      configs
      config
      data_source
    |

    def list payload_line, error_event
      host.configs.if_config( -> do
        items = ::Enumerator.new do |y|
          data_sources.each do |ds|
            ds.if_valid -> do
              y.yield nil, "  #{ ds.explain }"
            end, -> miss_a do
              y.yield "  /* next item is invalid. it is missing#{
                }: (#{ miss_a * ', '}) */", ds.explain
            end
          end
        end
        no_comma = -> cmnt, line do
          payload_line[ cmnt ] if cmnt
          payload_line[ line ]
        end
        comma = -> cmnt, line do
          no_comma[ cmnt, "#{ line }," ]
        end
        prev = open = nil
        parse_error_o = items.each do | *pair |
          open or ( open = true and payload_line[ '[' ] )  # sorry
          if prev
            comma[ * prev ]
          end
          prev = pair
        end
        no_comma[ * prev ] if prev
        if ! parse_error_o
          if open
            payload_line[ ']' ]
          else
            payload_line[ '[ ]' ]
          end
          nil  # important
        else
          error_event[ Models::Config::File::Invalid[
            cm_invalid_reason_o: parse_error_o
          ] ]
        end
      end, error_event )
      nil
    end

    def add name, url, tag_a, is_dry_run, is_verbose, error_event, info
      host.configs.if_config( -> do
        res = nil
        host = self.host
        cnt = host[ :data, :source ].if_init_valid name, url, tag_a, -> cont do
          cont
        end, -> e do
          res = error_event[ e ]
          nil
        end
        if ! cnt then res else
         add_valid_data_source cnt, is_dry_run, is_verbose, error_event, info
        end
      end, error_event )
    end

    module Exists
    end

    Exists::Already = Models::Event.new do |name_string|
      "data source already exists, won't clobber - #{ name_string }"
    end

    def add_valid_data_source cnt, d, v, e, i
      name = cnt.name
      exists = data_sources.detect do |ds|
        name == ds.name
      end
      if exists
        e[ Exists::Already[ name_string: exists.name ] ]
      else
        host.config.insert_valid_data_source cnt, d, v, e, i
      end
    end
    private :add_valid_data_source

    -> do  # `data_sources`
      rx = /\Adata-source "([^"]+)"\z/
      fly_weight = Models::Data::Source::Flyweight.new
      define_method :data_sources do
        ::Enumerator.new do |y|
          host.config.file.if_valid( -> f do
            s = f.sections
            if s
              s.each do |sect|
                if rx =~ sect.item_name
                  fly_weight.set $~[1], sect
                  y << fly_weight
                end
              end
            end
            # important - result of each { .. } is nil iff file was valid
            nil
          end, -> invalid_reason_obj do
            # important - when file was invalid, this is the hacky way we
            invalid_reason_obj  # can get more info.
          end )
        end
      end
      private :data_sources  # just for now probably..
    end.call
  end
end

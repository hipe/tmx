module Skylab::PubSub

  class API::Actions::Fire < API::Action

    PARAMS = [ :do_show_backtrace,
               :files,
               :opendata,
               :modul,
               :stream_name
    ].each { |k| attr_writer k }

    def execute
      res = nil
      begin
        res = resolve_params or break
        res = resolve_infiles or break
        res = resolve_mod or break
        res = crux or break
      end while nil
      res
    end

  protected

    -> do  # `crux`

      opendata_h = {
        string: -> od { od[1] },
        box:    -> od { od[1].to_hash }
      }

      define_method :crux do
        payload_x = if ! @opendata then "foo" else
          opendata_h.fetch( @opendata.first )[ @opendata ]
        end
        n = @mod.instance_method(:initialize).parameters.count{|a, _| :req == a}
        obj = @mod.new(* n.times.map { } )
        did_fire = false
        obj.send :"on_#{ @stream_name }" do |x|
          did_fire = true
          if x.instance_variable_defined? :@event_stream_graph
            x.instance_variable_set :@event_stream_graph, '[..]'  # pray
          end
          @infostream.puts "OK: #{ x.inspect }"
        end
        obj.send :emit, @stream_name, payload_x
        if ! did_fire
          @infostream.puts "(#{ prefix }did not see a #{ @stream_name } #{
            }event fire.)"
        end
        true
      end
    end
  end.call
end

module Skylab::Autonomous_Component_System

  module Modalities::JSON

    Unmarshal = -> acs, cust_x, st, & pp do  # 1x

      if ! pp
        self._COVER_ME_easy
        pp = Home_.handler_builder_for acs
      end
      _oes_p = pp[ acs ]

      if st.respond_to? :read
        json = st.read
      else
        json = ""
        while line = st.gets
          json.concat line
        end
      end

      o = Here_::Interpret.new( & _oes_p )
      o.ACS = acs
      o.customization_structure_x = cust_x
      o.JSON = json

      o.context_linked_list = begin

        _context_value = -> do
          'in input JSON'
        end

        Home_.lib_.basic::List::Linked[ nil, _context_value ]
      end

      o.execute
    end

    Marshal = -> args, acs, & pp do  # 1x

      if ! pp
        self._COVER_ME_easy
        pp = Home_.handler_builder_for acs
      end
      _oes_p = pp[ acs ]

      y = args.shift

      o = Here_::Express.new( & _oes_p )

      o.downstream_IO_proc = -> do
        y
      end

      o.upstream_ACS = acs

      if args.length.nonzero?
        args.each_slice 2 do | k, x |
          o.send :"#{ k }=", x
        end
      end

      o.execute
    end

    Here_ = self
  end
end

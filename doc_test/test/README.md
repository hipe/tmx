    func = -> zero=0, num_items, num_slots do
      width_per_item = 1.0 * num_slots / num_items
      two_buffers = width_per_item - 1
      buffer_width = two_buffers / 2
      first_item = zero + buffer_width + 1
      jump_by = 1.0 + two_buffers
      num_items.times do |d|
        puts ( first_item + ( d * jump_by ) ).round
      end
      nil
    end

    func[ 9, 49 ]


03       models
09       asset document read magnetics
14       ersatz parser
19       test document read magnetics
25       test document mutation magnetics
30       [reserved for asset document mutation magnetics]
36       output adapters
41       recursion models
47       recursion magnetics
50-59    [reserverd for operations direct]
60-69 65 API
70-79 75 CLI
80-89    [reserved]
90-99    [reserved]

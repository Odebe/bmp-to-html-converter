module BTHC
  class BitmapInfo
    property :size, :width, :height, :bit_count, :bit_compression

    @size : UInt32
    @width : UInt32
    @height : UInt32
    @planes : UInt16
    @bit_count : UInt16
    @bit_compression : UInt32

    def initialize(buff)
      arr = buff.to_a
      pp arr.size
      @size = get_size(arr)
      @width = get_width(arr)
      @height = get_height(arr)
      @planes = 1_u16
      @bit_count = get_bit_count(arr)/8
      @bit_compression = get_bit_compression(arr)
    end

    private def get_size(arr)
      calc_bytes(arr, 0, 3).to_u32
    end

    private def get_width(arr)
      calc_bytes(arr, 4, 7).to_u32
    end

    private def get_height(arr)
      calc_bytes(arr, 8, 11).to_u32
    end

    private def get_bit_count(arr)
      calc_bytes(arr, 14, 15).to_u16
    end

    private def get_bit_compression(arr)
      calc_bytes(arr, 16, 19).to_u32
    end

    private def calc_bytes(arr, first_i, last_i)
      acc = 0_u16
      first_i.upto(last_i) do |i|
        next if arr[i] == 0
        acc += arr[i].to_u16 << (8*(i - first_i))
      end
      acc
    end
  end

  def get_version(arr)
    case arr[0]
    when 124
      "5"
    when 108
      "4"
    when 40
      "3"
    when 12
      "core"
    end
  end
end

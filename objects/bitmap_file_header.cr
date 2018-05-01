module BTHC
  class BitmapFileHeader
    property :bfType, :bfSize, :bfReserved, :bfOffBits

    @bfType : String
    @bfSize : UInt16
    @bfReserved : Array(UInt8)
    @bfOffBits : UInt16

    def initialize(buff)
      # buff = buff.to_a
      @bfType = get_bfType(buff)
      @bfSize = get_bfSize(buff)
      @bfReserved = get_bfReserved(buff)
      @bfOffBits = get_bfOffBits(buff)
    end

    private def get_bfType(arr)
      arr.to_a[0..1].map { |c| c.chr }.join("")
    end

    private def get_bfSize(arr)
      calc_bytes(arr, 2, 5)
    end

    private def get_bfReserved(arr)
      arr = arr.to_a[6..9]
      arr.each do |el|
        raise "error" if el != 0
      end
      arr
    end

    private def get_bfOffBits(arr)
      calc_bytes(arr, 10, 13)
    end

    private def calc_bytes(arr, first_i, last_i)
      acc = 0_u16
      first_i.upto(last_i) do |i|
        next if arr[i] == 0
        acc += arr[i].to_u16 << (8*(i - first_i))
      end
      acc.to_u16
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
end

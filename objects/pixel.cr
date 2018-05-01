module BTHC
  class Pixel
    property :red, :green, :blue, :alpha
    # @data = Array(UInt8)
    @red : UInt16
    @green : UInt16
    @blue : UInt16
    @alpha : UInt16

    def initialize(buff)
      # pp buff
      arr = buff.clone.to_a
      # pp arr
      @red = arr[0].to_u16
      @green = arr[1].to_u16
      @blue = arr[2].to_u16
      @alpha = 255_u16 # arr[3].to_u16 if !arr[3].nil?
      # arr = buff.to_a
      # @red = ""   # arr[0]
      # @green = "" # arr[1]
      # @blue = ""  # arr[2]
      # @alpha = "" # arr[3]
    end

    def set_data(buff)
      arr = buff.to_a
      @red = arr[0].to_s
      @green = arr[1].to_s
      @blue = arr[2].to_s
      @alpha = arr[3].to_s
    end

    def to_html
      "<td style=\"background-color: RGB(#{@red},#{@green},#{@blue});\"></td>"
    end
  end
end

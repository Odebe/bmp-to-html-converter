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
end

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

class PixelTable
  property :data
  @data : Array(Pixel)
  # @data : Array(Array(Pixel))
  @width : UInt32
  @height : UInt32

  def initialize(width, height)
    @width = width
    @height = height
    # @data = Array.new(@height, Array(Pixel).new(@width, Pixel.new))
    # Array.new(@height){ Array(Pixel).new(@width){ Pixel.new } }
    @data = Array(Pixel).new(@width*@height)
    pp @data.size
  end

  def to_html
    table_tag = "<table border=\"0\" style=\"border-collapse: collapse;\">"
    string = table_tag
    # (0...@height).each do |row|
    row = @height.to_i16 - 1
    while row >= 0
      string += "<tr>"
      # (0...@width).each do |col|
      col = @width.to_i16 - 1
      while col >= 0
        # puts "row: #{row}, col: #{col}"
        # puts @width
        string += @data[get_pos(row, col)].to_html
        col -= 1
      end
      string += "</tr>"
      row -= 1
    end
    string += "</table>"
  end

  def set_pixel(row, col, buff)
    @data << Pixel.new(buff)
  end

  private def get_pos(row, col)
    if @width % 2 == 0
      row*@width + col
    else
      row*(@width + 1) + col
    end
  end

  def get_pixel(row, col)
    @data[get_pos(row, col)]
    # @data[row][col]
  end

  def pix_to_html(x, y)
  end
end

class BmpFile
  def initialize(filename, result_file = "res.html")
    bitmap_file_header_size = 14
    file = File.open(filename, "r")

    buff = read_from_(file, bitmap_file_header_size)

    header = BitmapFileHeader.new(buff)
    pp header

    bitmap_info_size = header.bfOffBits - bitmap_file_header_size
    buff = read_from_(file, bitmap_info_size)

    ver = get_version(buff)
    pp ver
    pp buff[0]
    # raise "not supported version " if ver != "5"

    bitmap_info = BitmapInfo.new(buff)
    p_table = PixelTable.new(bitmap_info.width, bitmap_info.height)
    pp bitmap_info

    # pixels_count = (header.bfSize - header.bfOffBits)/bitmap_info.bit_count
    # rows_count = pixels_count/bitmap_info.height
    # pp pixels_count
    cols_count = if bitmap_info.width % 2 == 0
                   bitmap_info.width
                 else
                   bitmap_info.width + 1
                 end
    (0...bitmap_info.height).each do |row|
      (0...cols_count).each do |col|
        # (0...bitmap_info.width).each do |col|
        buff = read_from_(file, bitmap_info.bit_count)
        # puts "#{row}:#{col}"
        # pp buff
        p_table.set_pixel(row, col, buff)
        # p_table.data[row] << Pixel.new(buff.clone)
        # pp p_table.get_pixel(row, col)
      end
    end

    res = p_table.to_html
    # pp res
    (0...bitmap_info.height).each do |i|
      (0...bitmap_info.width).each do |j|
        # puts "i:#{i}, j: #{j}"
        # pp buff
        # p_table.data[i][j].set_data(buff.clone)
        # pp p_table.get_pixel(i, j)
      end
    end

    File.write(result_file, res)
    file.close
  end

  def read_from_(file, bytes)
    buff = Bytes.new(bytes)
    file.read(buff)
    buff
  end
end

print "Enter image filename: "
image_name = gets.to_s

print "Enter result filename: "
result_file = gets.to_s

BmpFile.new(image_name, result_file)

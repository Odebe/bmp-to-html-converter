module BTHC
  class BmpFile
    def initialize(filename, result_file = "res.html")
      bitmap_file_header_size = 14
      file = File.open(filename, "r")

      buff = read_from_(file, bitmap_file_header_size)

      header = BTHC::BitmapFileHeader.new(buff)
      pp header

      bitmap_info_size = header.bfOffBits - bitmap_file_header_size
      buff = read_from_(file, bitmap_info_size)

      ver = header.get_version(buff)

      pp ver
      pp buff[0]

      # raise "not supported version " if ver != "5"

      bitmap_info = BTHC::BitmapInfo.new(buff)
      p_table = BTHC::PixelTable.new(bitmap_info.width, bitmap_info.height)
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
          p_table.set_pixel(row, col, buff)
          # p_table.data[row] << Pixel.new(buff.clone)
        end
      end

      res = p_table.to_html
      # pp res
      # (0...bitmap_info.height).each do |i|
      #  (0...bitmap_info.width).each do |j|
      # puts "i:#{i}, j: #{j}"
      # pp buff
      # p_table.data[i][j].set_data(buff.clone)
      # pp p_table.get_pixel(i, j)
      #  end
      # end

      File.write(result_file, res)
      file.close
    end

    def read_from_(file, bytes)
      buff = Bytes.new(bytes)
      file.read(buff)
      buff
    end
  end
end

module BTHC
  class PixelTable
    property :data
    @data : Array(BTHC::Pixel)
    # @data : Array(Array(Pixel))
    @width : UInt32
    @height : UInt32

    def initialize(width, height)
      @width = width
      @height = height
      # @data = Array.new(@height, Array(Pixel).new(@width, Pixel.new))
      # Array.new(@height){ Array(Pixel).new(@width){ Pixel.new } }
      @data = Array(BTHC::Pixel).new(@width*@height)
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
      @data << BTHC::Pixel.new(buff)
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
end

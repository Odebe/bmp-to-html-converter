# macro require_objects(files)
#	{% for file in files %}
#		require {{file}}
#	{% end %}
# end

# require_objects Dir["./objects/*.cr"].to_a

# Dir["./objects/*.cr"].each{ |file| require file }

require "./objects/*"

module BTHC
  def self.convert
    print "Enter image filename: "
    image_name = gets.to_s

    print "Enter result filename: "
    result_file = gets.to_s

    BTHC::BmpFile.new(image_name, result_file)
  end
end

BTHC.convert

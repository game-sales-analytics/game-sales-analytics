require "fiber"

module IPGenerator
  def IPGenerator.new
    return Fiber.new do |g|
      43.upto(250) do |i|
        Fiber.yield "192.168.56.#{i}"
      end
    end
  end
end

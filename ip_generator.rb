require "fiber"

class IPGenerator
  def initialize
    @first = [192, 168, 56, 32]
    @current = @first

    @generator = Fiber.new do |g|
      while true
        last_octect = @current.last
        if last_octect + 1 >= 255
          raise 'fourth octect reached 255'
        end

        next_ip = [@first.slice(0, 3), last_octect + 1]

        Fiber.yield @current.join(".")

        @current = next_ip
      end
    end
  end

  def first
    @first.join(".")
  end

  def next
    @generator.resume
  end
end
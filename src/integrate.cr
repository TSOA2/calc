require "./parse.cr"

module Calc
  struct IG
    enum Method
      LeftHand
      RightHand
      Midpoint
      Trapezoid
      Simpsons
    end

    @method : Method
    @low : Float64
    @high : Float64
    @parts : Int64

    def initialize(@method, @low, @high, @parts)
    end

    private def delta : Float64
      (@high - @low) / @parts
    end

    private def lefthand(runner : Runner)
      s = 0.0
      x = @low
      while x < @high
        s += runner.run x
        x += delta
      end
      s * delta
    end

    private def righthand(runner : Runner)
      s = 0.0
      x = @low+delta
      while x <= @high
        s += runner.run x
        x += delta
      end
      s * delta
    end

    private def midpoint(runner : Runner)
      d = delta / 2
      s = 0.0
      x = @low+d
      while x < @high
        s += runner.run x
        x += delta
      end
      s * delta
    end

    private def trapezoid(runner : Runner)
      s = runner.run(@low) + runner.run(@high)
      x = @low+delta
      while x < @high
        s += 2 * runner.run(x)
        x += delta
      end
      s * 0.5 * delta
    end

    private def simpsons(runner : Runner)
      s = runner.run(@low) + runner.run(@high)
      i = 0
      x = @low+delta
      while x < @high
        s += (i % 2 == 0 ? 4.0 : 2.0) * runner.run(x)
        x += delta
        i += 1
      end
      s * (1.0/3.0) * delta
    end

    def integrate(runner : Runner) Float64
      case @method
      when Method::LeftHand then lefthand(runner)
      when Method::RightHand then righthand(runner)
      when Method::Midpoint then midpoint(runner)
      when Method::Trapezoid then trapezoid(runner)
      when Method::Simpsons then simpsons(runner)
      end
    end
  end
end

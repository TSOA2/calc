require "./version.cr"
require "./integrate.cr"

module Calc
  struct Options
    enum ID
      Integrate
      Derivative
      Simplify
    end

    struct IGStep
      METHOD_MAP = {
        "lefthand" => IG::Method::LeftHand,
        "righthand" => IG::Method::RightHand,
        "midpoint" => IG::Method::Midpoint,
        "trapezoid" => IG::Method::Trapezoid,
        "simpsons" => IG::Method::Simpsons,
      }

      property method : IG::Method
      property low : Float64
      property high : Float64
      property parts : Int64

      def initialize(method : String, @low, @high, @parts)
        method = METHOD_MAP[method]?
        if !method
          STDERR.puts "Invalid integration method, using default=\"midpoint\"."
          method = IG::Method::Midpoint
        end
        @method = method.not_nil!
      end
    end

    struct DVStep
      def initialize
      end
    end

    struct SPStep
      def initialize
      end
    end

    struct Step
      property id : ID
      property data : IGStep | DVStep | SPStep

      def initialize(@id, @data)
      end
    end

    property expr : String
    property steps : Array(Step)
    @args : Array(String)
    @i    : UInt64

    def initialize
      if ARGV.size == 0
        usage
        exit 1
      end

      @expr = ARGV[0]
      @steps = [] of Step
      @args = ARGV[1..ARGV.size]
      @i = 0

      while @i < @args.size
        arg = get_next.not_nil!
        case arg
        when "i"
          ig = get_integral
          if !ig
            STDERR.puts "Expected integral arguments after \"i\": method, low, high, parts."
            exit 1
          end
          @steps << Step.new(ID::Integrate, ig)
        when "d"
          @steps << Step.new(ID::Derivative, get_derivative)
        when "s"
          @steps << Step.new(ID::Simplify, get_simplify)
        end
      end
    end

    def usage
      STDERR.puts "
Usage: calc [expr] [ids]
Integration:
  calc \"x^2\" i lefthand 0 5 4
  0 = low, 5 = high, 4 = parts
  Methods:
    - lefthand   - righthand
    - midpoint   - trapezoid
    - simpsons

Derivation:
  calc \"x^2\" d

Simplification:
  calc \"5*x/5\" s

You can combine some, like derivation and simplification:
  calc \"5*x/5\" d s
      "
    end

    def get_next : String?
      if @i < @args.size
        arg = @args[@i]
        @i += 1
        arg
      end
    end

    def float_err
      STDERR.puts "Invalid formatting of number.\n"
      exit 1
    end

    def get_integral : IGStep?
      method = get_next
      if !method
        return nil
      end

      low = get_next
      if !low
        return nil
      end
      low = low.to_f64?
      if !low
        float_err
      end

      high = get_next
      if !high
        return nil
      end
      high = high.to_f64?
      if !high
        float_err
      end

      parts = get_next
      if !parts
        return nil
      end
      parts = parts.to_i64?
      if !parts
        float_err
      end

      IGStep.new(method, low.not_nil!, high.not_nil!, parts.not_nil!)
    end

    def get_derivative : DVStep
      DVStep.new
    end

    def get_simplify : SPStep
      SPStep.new
    end
  end
end

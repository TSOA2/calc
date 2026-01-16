module Calc
  module Lexer
    # The token ID
    enum ID
      X
      Number
      Lparen
      Rparen
      Plus
      Minus
      Multiply
      Divide
      Power
      None
    end

    # Holds the token ID and a value (if it has one)
    struct Token
      property id : ID
      property num : Float64

      def initialize(@id = ID::None, @num = 0.0)
      end

      def to_s(io)
        io << case @id
        in .x? then "X"
        in .number? then "Number"
        in .lparen? then "("
        in .rparen? then ")"
        in .plus? then "+"
        in .minus? then "-"
        in .multiply? then "*"
        in .divide? then "/"
        in .power? then "^"
        in .none? then "None"
        end

        if @id == ID::Number
          io << "(#{@num})"
        end
      end
    end

    # A list of tokens, with rudimentary printing added
    class TokenList < Array(Token)
      def initialize
        super
      end

      def to_s(io)
        it = each
        while !(t = it.next).is_a?(Iterator::Stop)
          io << "#{t}, "
        end
      end
    end

    private def self.get_number(expr : String, i : Int32) : { Int32, Float64 }
      num = 0.0
      while i < expr.size
        if !expr[i].ascii_number?
          if expr[i] == '.'
            i += 1
            exp = 10.0
            while i < expr.size && expr[i].ascii_number?
              num += expr[i].to_f / exp
              i += 1
            end
          end
          break
        end

        num += num*10 + expr[i].to_f
        i += 1
      end

      return { i, num }
    end

    # Convert a mathematical expression into tokens
    def self.lex(expr : String) : TokenList
      i = 0
      tokens = TokenList.new
      while i < expr.size
        c = expr[i].downcase
        if c.ascii_whitespace?
          i += 1
          next
        end

        incr = i+1
        token = Token.new
        token.id = case c
        when 'x' then ID::X
        when '(' then ID::Lparen
        when ')' then ID::Rparen
        when '+' then ID::Plus
        when '-' then ID::Minus
        when '*' then ID::Multiply
        when '/' then ID::Divide
        when '^' then ID::Power
        else
          if c.ascii_number?
            incr, token.num = get_number(expr, i)
            ID::Number
          else
            ID::None
          end
        end

        tokens << token
        i = incr
      end
      return tokens
    end
  end

  alias ID = Lexer::ID
end

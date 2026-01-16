require "./lex.cr"

module Calc
  class Parser
    alias TokList = Lexer::TokenList
    alias ID = Lexer::ID

    abstract class Node
      property id : ID
      def initialize(@id)
      end

      # All these functions are recursive.

      # Checks if node structure is constant
      abstract def is_constant : Bool

      # Clones the node structure
      abstract def clone : Node

      # Checks equality of node structures
      abstract def equals(n : Node) : Bool

      # Evaluates node structure
      abstract def eval : Float64

      # Converts structure back into human readable form
      abstract def to_s(io : IO)
    end

    class BinNode < Node
      property left : Node
      property right : Node

      def initialize(@id, @left, @right)
      end

      def is_constant : Bool
        return @left.is_constant && @right.is_constant
      end

      def clone : BinNode
        BinNode.new(@id, @left.clone, @right.clone)
      end

      def equals(n : Node) : Bool
        if n.id == @id
          @left.equals(n.as(BinNode).left) &&
            @right.equals(n.as(BinNode).right)
        else
          false
        end
      end

      def eval : Float64
        return case @id
          when ID::Plus then @left.eval + @right.eval
          when ID::Minus then @left.eval - @right.eval
          when ID::Multiply then @left.eval * @right.eval
          when ID::Divide then @left.eval / @right.eval
          when ID::Power then left.eval ** @right.eval
          else
            raise "Invalid Binary node"
        end
      end

      def to_s(io : IO)
        io << @left << " "
        io << case @id
          when ID::Plus then "+"
          when ID::Minus then "-"
          when ID::Multiply then "*"
          when ID::Divide then "/"
          when ID::Power then "^"
        end
        io << " " << @right
      end
    end

    class UnaryNode < Node
      property node : Node
      def initialize(@id, @node)
      end

      def is_constant : Bool
        return @node.is_constant
      end

      def clone : Node
        UnaryNode.new(@id, @node.clone)
      end

      def equals(n : Node) : Bool
        if n.id == @id
          @node.equals(n.as(UnaryNode).node)
        else
          false
        end
      end

      def eval : Float64
        if @id == ID::Minus
          return -@node.eval
        end
        return @node.eval
      end

      def to_s(io : IO)
        if @id == ID::Minus
          io << "-"
        end
        io << @node
      end
    end

    class NumNode < Node
      property num : Float64

      def initialize(@num, @id = ID::Number)
      end

      def is_constant : Bool
        true
      end

      def clone : Node
        NumNode.new(@num)
      end

      def equals(n : Node) : Bool
        if @id == n.id
          @num == n.as(NumNode).num
        else
          false
        end
      end

      def eval : Float64
        return @num
      end

      def to_s(io : IO)
        io << @num
      end
    end

    class XNode < Node
      property xnum : Float64*
      def initialize(@xnum, @id = ID::X)
      end

      def is_constant : Bool
        false
      end

      def clone : Node
        XNode.new(@xnum)
      end

      def equals(n : Node) : Bool
        @id == n.id
      end

      def eval : Float64
        return @xnum.value
      end

      def to_s(io : IO)
        io << "x"
      end
    end

    @toks : TokList
    @i : UInt64
    property x : Float64
    property xnum : Float64*

    def initialize(expr : String, @x = 0.0)
      @toks = Lexer.lex(expr)
      @i = 0
      @xnum = pointerof(@x)
    end

    def initialize(@toks, @x = 0.0, @i = 0)
      @xnum = pointerof(@x)
    end

    def parse : Node
      left = parse_mul
      if @i >= @toks.size
        return left
      end

      tok = @toks[@i]
      if tok.id == ID::Plus || tok.id == ID::Minus
        @i += 1
        return BinNode.new(tok.id, left, parse)
      end
      return left
    end

    private def parse_mul : Node
      left = parse_pow
      if @i >= @toks.size
        return left
      end

      tok = @toks[@i]
      if tok.id == ID::Multiply || tok.id == ID::Divide
        @i += 1
        return BinNode.new(tok.id, left, parse_mul)
      end
      return left
    end

    private def parse_pow : Node
      left = parse_unary
      if @i >= @toks.size
        return left
      end

      tok = @toks[@i]
      if tok.id == ID::Power
        @i += 1
        return BinNode.new(tok.id, left, parse_pow)
      end
      return left
    end

    private def parse_unary : Node
      if @i >= @toks.size
        raise "EOF"
      end

      tok = @toks[@i]
      if tok.id == ID::Minus
        @i += 1
        return UnaryNode.new(tok.id, parse_unary)
      end
      return parse_prim
    end

    private def parse_prim : Node
      if @i >= @toks.size
        raise "EOF"
      end

      tok = @toks[@i]
      @i += 1
      if tok.id == ID::Lparen
        left = parse
        tok = @toks[@i]
        if tok.id != ID::Rparen
          raise "Missing right parenthesis"
        end
        @i += 1
        return left
      elsif tok.id == ID::Number
        return NumNode.new(tok.num)
      elsif tok.id == ID::X
        return XNode.new(@xnum)
      else
        raise "Invalid token: #{tok}"
      end
    end
  end

  class Runner
    @x : Float64
    @parser : Parser
    getter ast : Parser::Node

    def initialize(expr : String, @x = 0.0)
      @parser = Parser.new(expr, pointerof(@x))
      @ast = @parser.parse
    end

    def initialize(@parser, @ast, @x = 0.0)
    end

    def run(@x) : Float64
      @parser.x = @x
      @ast.eval
    end

    def to_s(io)
      io << "Runner(x=#{@x}, ast=#{ast})"
    end
  end

  alias BN = Parser::BinNode
  alias NN = Parser::NumNode
end

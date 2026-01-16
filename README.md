# Calculator

## About
A commandline to calculate integrals/derivatives (and maybe more later) of
mathematical expressions. For now, the expressions can only have one variable
in them (derivatives always differentiate with respect to X, as do integrals
integrate).  

Made in school on a Chromebook using Godbolt.

## Usage
### Integration
```
calc "x^2 + 3x + 5" i midpoint 0 5 4
     ^- expression  ^ ^        ^ ^ ^- # of parts
                    ^ ^        ^ ^- high
                    ^ ^        ^- low
                    ^ ^- method
                    ^- i for integration
```

Methods include:  
* “lefthand”
* “righthand”
* “midpoint”
* “trapezoid”
* “simpsons”

A higher # of parts will give you more precision.  

### Differentiation
```
calc "x^2 + 3x + 5" d
                    ^- d for differentiation
```

Finds the derivative with respect to x.

### Simplification
```
calc "5 * x / 5 + 2 - 2" s
                         ^- s for simplification
```

Simplifies the expression by eliminating unnecessary terms, using a few rules.
There's definitely more to add here.

### Chained

You can chain together operations like this:  
```
calc "x^(3/2) - 2 * (1 / x) i d d s
```

## Building
This was also written to learn Crystal. I think it's a nice language, but I
added a Makefile for simplicity:  

### Build (debug)
```
make all
```

### Build ("release")
```
make MODE=release all
```

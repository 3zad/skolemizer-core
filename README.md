How to run:
type a formula into `input.txt` making sure to use the following syntax:
* `|` Conjunction
* `&` Disjunction
* `!` Negation
* `=` Biconditional
* `>` Implication
* `A` Universal Quantifier
* `E` Existential Quantifier
* Any lowercase letter for a variable
* Any uppercase letter (other than A and E) for a predicate

Example: `AxEyAz(P(x,y,z) & Q(x,y,z) > R(y))` is a valid formula

After that, type `dub run` into the terminal and then check out `ast.txt` and `skolemized_ast.txt`

Example output with input `(AxP(s(s(s(s(s(s(x))))))) & EyP(y) & AzP(z) & EwP(w))`:
`P(s(s(s(s(s(s(v0))))))) ∧ P(f0(v0)) ∧ P(v2) ∧ P(f1(v0,v2))`
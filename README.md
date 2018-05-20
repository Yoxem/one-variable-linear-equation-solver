# one-variable-linear-equation-solver
A program to solve one-variable linear equation. It's written in C with flex and bison.

Dependencies
---------------
* flex >= 2.6.0
* bison >= 3.0.0
* make >= 4.1
* gcc >= 5.4.0

Compile
----------
typing ``make`` in the folder of the repo.

Execute
----------
execute it with the command:

``./interp``

after showing the introdution, type the formula (eg. ``2*x+5``), then press enter to solve it. For example:

    A program to solve f(x) = 0 such that f(x) is a 1-var linear function.
    Please Enter a 1-var linear function:  2*x+5           
    ANSWER: x = -2.500000

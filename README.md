# fopt

A f2003 wrapper for calling the well-known f77 library `L-BFGS-B`. An example
of how simple this can be.

## `fortdepend`

This project also uses `fortdepend` - a python program which automatically
generates fortran dependency trees.

## `L-BFGS-B`

The `L-BFGS-B` Source distribution is not tracked, but can be obtained from [the L-BFGS-B
website](http://users.iems.northwestern.edu/~nocedal/lbfgsb.html) under their
license. When placed in `src` appropriately, that library will be compiled as
suggested, and linked to the f03 libraries in the remainder of `src`.

**You** will need to download the `L-BFGS-B` source distribution (and extract it)
and place it inside `src` for this project to compile.

# Do you want to use this?

User implementation of `f`, `g` goes in functions.f03. There's nothing
interesting there. I wrote this to look at the Thomson problem, but lost track
of the changes where I implemented the right `f`, `g` for that!

# Final Conditions

This article describes the different types of final conditions supported in
StateSpaceEcon, the relevant mathematical derivations, as well as some
implementation details.

## Introduction

In the stacked time algorithm all equations for all time periods are solved
simultaneously as a single, very large system of equations. Because of lags in
some of the variables, we must impose initial conditions, i.e. values for the
variables before the first period of the simulation. This is not unique to
stacked time algorithm - all solution methods require initial conditions.

Similarly, because of the presence of leads in the equations, we must provide
final conditions. Final conditions are equations in terms of variable values at
times beyond the last period of the simulation.

As a running example, consider a model with one variable ``y_t``, one shock
``sy_t``, and one equation:

```math
0.5 y_{t-1} - y_t + 0.5 y_{t+1} = s_t
```

Suppose we want to simulate 3 periods. Let's use indices ``t=2..4`` for the
simulation periods. In the stacked time algorithm we have to solve the following
system of equations:

```math
0.5 y_1 - y_2 + 0.5 y_3 = s_2
0.5 y_2 - y_3 + 0.5 y_4 = s_3
0.5 y_3 - y_4 + 0.5 y_5 = s_4
```

We see that we have 3 equations with 5 unknowns. In order to find a unique
solution, we need two more equations. The first one is the initial condition.

```math
y_1 = Y_1,
```

where ``Y_1`` is a known value of ``y`` at time ``t=1``. The last equation is
the final condition, which would help us solve for ``y_5``.

## Types of Final Conditions

There are three types of final conditions currently implemented in
StateSpaceEcon.

### `fcgiven`

This is the simplest one of them. It cen be used when the values of the variable
past the end of the simulation are known and we simply assign them.

In our running example, the following equation corresponds to `fcgiven`.

```math
y_5 = Y_5
```

### `fclevel`

This is almost the same as `fcgiven` in that here again we simply assign known
values to the variable in the periods of the final conditions. This time the
values come from the steady state of the system.

The equation in our example is 

```math
y_5 = Ys_{level}
```

Where ``Ys_{level}`` is the steady state of ``y``. This works if the steady state of
``y`` is a constant level.

### `fcslope`

In this case we write an equation which sets the first difference of ``y_t`` at
the end of the simulation (and for all final conditions periods) to the slope of
the steady state. This works if the steady state of ``y_t`` is a constant level
or a constant rate of change, i.e. a balanced path of linear growth.

The equation is

```math
y_5 - y_4 = Ys_{slope},
```
where ``Ys_{slope}`` is the slope of the steady state of ``y_t``.

## The Stacked Time System of Equations

Once we stack all equations for all time periods into a single system of
equations, we get a system with more unknowns than equations, as we saw above.
In addition to initial and final conditions, we also have exogenous constraints.

### Vector of Unknowns

Let us denote by ``x`` the vector of all unknowns. To be specific, the variables
and shocks are assigned consecutive and unique indices starting from 1 to ``N``.
Also, the time periods of the simulation, including the necessary number of time
periods before (initial conditions) and after (final conditions) the simulation,
are numbered sequentially starting from 1 to ``T``. Thus vector ``x`` has ``NT``
components. We have adopted the convention that the first ``T`` components
correspond to values of the first variable, components from ``T+1`` to ``2T``
are variable 2 and so on.

We divide the unknowns into three groups based on how they are treated by the
solver. The first group are unknowns whose values are already known. These
include initial conditions and exogenous constraints. We denote these ``x_e``.

The second group is the "active unknowns". These are the ones we are actually solving for in the simulation. We denote their vector ``x_s``.

The third group consists of the unknowns determined by final conditions. We denote that vector ``x_c``

In our example, the vectors of unknowns would look like this:

```math
    x = [y_1, y_2, y_3, y_4, y_5, s_1, s_2, s_3, s_4, s_5]
    x_e = [y_1, s_1, s_2, s_3, s_3, s_4, s_5]
    x_s = [y_2, y_3, y_4]
    x_c = [y_5]
```

In what follows, we will renumber the unknowns in ``x`` such that ``x_e`` are in
the beginning, ``x_s`` are in the middle and ``x_c`` are at the end. In the code
we don't actually do this, but it makes it easier to present and follow the
linear algebra in the following sections.

```math
    x = [ x_e... , x_s... , x_c... ]
```

### Equations

The equations are also grouped into the same three groups and for the purpose of
this exposition we put them in the same order as we did with the unknowns above.

### The System of Equations

Without loss of generality we have a system of equations ``F(x) = 0``. Starting
with an initial guess ``x^0``, The Newton-Raphson method consists in the
iteration

```math
    x^{n+1} = x^{n} - [J(x^n)]^{-1} F(x^n),
```

where ``J(x^n)`` is the Jacobian of ``F`` evaluated at ``x^n``.

!!! warning "Important"
    We need to distinguish between *initial condition* and *initial guess*. The
    former refers to the values of the model variables prior to the simulation
    range. The latter is the vector of unknowns at the start of the iterative
    solution method. To distinguish the two, we use upper index (superscript) to
    denote the successive iterations of the Newton-Raphson method, while the
    lower index (subscript) is used to denote the variable group ``e``, ``s``,
    or ``c``.

The computational step here consists in solving the linear system with matrix
``J`` and right hand side ``F``. We can write this system into 3-by-3 blocks,
with rows corresponding to equations and columns corresponding to unknowns split
into the three groups.

```math
    \begin{bmatrix} I & 0 & 0 \\ E_s & S & C_s \\ E_c & S_c & C \end{bmatrix}
    \cdot
    \begin{bmatrix} \delta x_e \\ \delta x_s \\ \delta x_c \end{bmatrix}
    =
    \begin{bmatrix} 0 \\ F_s \\ F_c \end{bmatrix}
```

The first row corresponds to exogenous and initial conditions. Notice that the
unknown here is not ``x`` but the update ``\delta x``. If we assign the correct
exogenous and initial values in ``x^0`` then the residuals of this group of
equations will be all zeros, ``F_e = 0``, and so the update ``\delta x_e`` will
also be always zero.

Therefore the entire system reduces to solving the following:

```math
    \begin{bmatrix} S & C_s \\ S_c & C \end{bmatrix}
    \cdot
    \begin{bmatrix} \delta x_s \\ \delta x_c \end{bmatrix}
    =
    \begin{bmatrix} F_s \\ F_c \end{bmatrix}.
```

## Solution Method

### Case 1: `fcgiven`

In this case we have

```math
    \begin{bmatrix} S & C_s \\ 0 & I \end{bmatrix}
    \cdot
    \begin{bmatrix} \delta x_s \\ \delta x_c \end{bmatrix}
    =
    \begin{bmatrix} F_s \\ 0 \end{bmatrix}.
```

Once again we assume that the correct values for ``x_c`` are assigned in the
initial guess, ``x^0``. Therefore the update ``\delta x_c`` is always zero.

Therefore in this case we simply solve

```math
    S \cdot \delta x_s = F_s
```

Note that even though we are not explicitly solving for ``\delta x_e`` and
``\delta x_c``, the matrix ``S`` and the right hand side ``F_s`` here depend on
the values ``x_e`` and ``x_c``, since they are part of ``x^n`` when evaluating
``F(x^n)`` and ``J(n^n)``.

### Case 2: `fclevel`

This is identical to case 1.

### Case 3: `fcslope`

This is the interesting case.  We have the following equations

```math
\begin{align}
    S \cdot \delta x_s &+ C_s \cdot \delta x_c &= F_s \\
    S_c \cdot \delta x_s &+ C \cdot \delta x_c &= F_c
\end
```

We eliminate ``\delta x_c`` from the system. To do so, we multiply the
second equation by ``C_s C^{-1}`` and subtract the result from the first equation.

```math
    \left( S - C_s C^{-1} S_c \right) \cdot \delta x_s = F_s - C_s C^{-1} F_c
```

Now pay attention because this part is tricky.

Suppose that ``F_c = 0``. We will discuss later how we make sure that's the case. 
Then the solution for ``\delta x_s`` is given by

```math
    \left( S - C_s C^{-1} S_c \right) \cdot \delta x_s = F_s
```

The only difference with case 1 and 2 is that the system matrix is modified by
subtracting ``C_s C^{-1} S_c``. The matrix ``C^{-1} S_c`` is constant. This
matrix is specific to the `fcslope` final conditions for the given model. It
only depends on the number of variables and the number of final conditions
periods (that is the same as the maximum lag in the model). It can be
pre-computed and stored. The matrix ``C_s`` on the other hand depends on ``x^n``
and so it needs to be re-computed at every iteration.

How do we make sure that ``F_c = 0``? Remember that the final conditions
equation in our example model is ``y_5 - y_4 = Ys_{slope}``. Imagine how this
would generalize to an arbitrary model. Now notice that the residual ``F_c``
depends on ``x^n`` and the slope of the steady state. If we know the ``x^n_s``
part of ``x^n``, we can solve for the rest of it such that the final conditions
equations are satisfied. In outer words, this would make sure that ``F_c = 0``.
One way to do this is to simply start from the values of the variables at the
last period of the simulation (which are in ``x^n_s``, that's ``y_4`` in our
example) and compute all future values (which are in ``x^n_c``,that's ``y_5`` in
the example) by adding the corresponding steady state slope (or
``y_5 = y_4 + Ys_{slope}``). We must do this on every iteration before we
evaluate ``F(x^n)`` and ``J(x^n)``.

Actually, we only need to do this to the initial guess ``x^0``. After that, once
we compute ``\delta x_s`` by solving the above system, we can solve the
following system for ``\delta x_c``.

```math
    C \cdot \delta x_c = - S_c \cdot \delta x_s
```

If we assume that ``x^n_c`` is such that the ``F_c`` computed from it is 0, and
we compute ``x^{n+1}_c = x^n_c + \detla x_c``, with ``\delta x_c`` coming from
the above equation, then we can prove that this ``x^{n+1}_c`` would also produce
a ``F_c = 0``. at the following iteration of Newton-Raphson.



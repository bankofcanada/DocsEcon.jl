# Final Conditions

This article describes the different types of final conditions supported in
StateSpaceEcon, the relevant mathematical derivations, as well as some
implementation details.

## Introduction

In the stacked time algorithm all equations for all time periods are solved
simultaneously as one, very large system of equations. Because of lags in some
of the variables, we must impose initial conditions, i.e. values for the
variables before the first period of the simulation. This is not unique to
stacked time algorithm - all solution methods require initial conditions.

Similarly, because of leads in some of the variables, we must provide final
conditions. Final conditions are equations in terms of variables at times beyond
the last period of the simulation.

As a running example, consider a model with one variable ``y_t``, one shock
``sy_t``, and one equation involving one lag and one lead:

```math
    f(y_{t-1}, y_t, y_{t+1}, s_t) = 0
```

Suppose we want to simulate 3 periods. Let's use indices ``t=2..4`` for the
simulation periods. In the stacked time algorithm we have to solve the following
system of equations:

```math
\begin{aligned}
    f(y_1, y_2, y_3, s_2) &= 0 \\
    f(y_2, y_3, y_4, s_3) &= 0 \\
    f(y_3, y_4, y_5, s_4) &= 0
\end{aligned}
```

We see that we have 3 equations with 5 unknowns - we assume that the values of
the shocks (``s_t``) are given as exogenous data. In order to find a unique
solution for ``y_t`` for all ``t=1..5``, we need two more equations. The first
one is the initial condition.

```math
y_1 = Y_1,
```

where ``Y_1`` is a known value of ``y`` at time ``t=1``. The last equation is
the final condition, which would help us solve for ``y_5``.

## Types of Final Conditions

There are four types of final conditions currently implemented in
StateSpaceEcon.

### `fcgiven`

This is the simplest one of them. It can be used when the values of the variable
after the end of the simulation are known and we simply assign them.

In our running example, the following equation corresponds to `fcgiven`.

```math
y_5 = Y_5
```

### `fclevel`

This is almost the same as `fcgiven` in that here again we simply assign known
values to the variables in the final conditions. This time the values come from
the steady state solution of the system. This works if the steady state of
``y_t`` is a constant.

```math
y_5 = ssY_5,
```

Where ``ssY`` is the steady state of ``y``. Note that the steady state is not
necessarily a constant. In the case of balanced growth path and more than one
final conditions period, we still assign the known values of ``ssY_t`` as
computed from its known level and slope.

### `fcslope`

In this case we write an equation which sets the first difference of ``y_t`` at
the end of the simulation (for all final conditions periods) to the slope of the
steady state. This works if the steady state solution of ``y_t`` is a balanced
path with linear growth. It can also be used with constant steady state - in
that case the "linear growth" has slope 0.

```math
y_5 - y_4 = ssY_5 - ssY_4
```

Note that ``ssY_{t+1} - ssY_{t} = ssY_{slope}`` is simply the slope of the
steady state - a constant that does not depend on ``t``.

### `fcnatural`

This is the case when we believe that the solution path beyond the end of the
simulation is a straight line, but we don't know its slope, i.e., we allow the
slope to be solved for. Practically, this final condition imposes the constraint
that the second difference of the variable is zero after the last simulation
period.

```math
   y_5 - 2 y_4 + y_3 = 0
```

## The Stacked Time System of Equations

Once we stack all equations for all simulation time periods into a single system
of equations, we get a system with more unknowns than equations, as we saw
above. In addition to initial and final conditions, we also have to impose
exogenous constraints.

### Vector of Unknowns

Let us denote by ``x`` the vector of all unknowns. To be specific, the variables
and shocks are assigned consecutive and unique indices from ``1`` to ``N``. Also,
the time periods of the simulation, together with the necessary number of time
periods before (initial conditions) and after (final conditions) the simulation,
are numbered sequentially starting from 1 to ``T``. Thus vector ``x`` has
``N T`` components. We have adopted the convention that the first ``T``
components correspond to values of the first variable, components from ``T+1``
to ``2T`` are for variable 2 and so on.

We divide the unknowns into three groups based on how they are treated by the
solver. The first group contains the unknowns whose values are already known.
These include initial conditions and exogenous constraints. We denote these
``x_e``.

The second group is the set of "active unknowns". These are the ones we are
actually solving for in the simulation. We denote them ``x_s``.

The third group consists of the unknowns determined by final conditions. We
denote that vector ``x_c``.

In our example, the vectors of unknowns would look like this:

```math
\begin{aligned}
    x &= [y_1, y_2, y_3, y_4, y_5, s_1, s_2, s_3, s_4, s_5] \\
    x_e &= [y_1, s_1, s_2, s_3, s_3, s_4, s_5] \\
    x_s &= [y_2, y_3, y_4] \\
    x_c &= [y_5]
\end{aligned}
```

In what follows, we will renumber the unknowns in ``x`` such that ``x_e`` are in
the beginning, ``x_s`` are in the middle and ``x_c`` are at the end. In the code
we don't actually do this, but it makes it easier to discuss the linear algebra
in the following sections.

```math
    x = [ x_e... , x_s... , x_c... ]
```

### Equations

The equations are also grouped into the same three groups and for the purpose of
this exposition we put them in the same order as we did with the unknowns above.

### The System of Equations

Without loss of generality we have a system of equations ``F(x) = 0``. Starting
with an initial guess ``x^0``, the Newton-Raphson method consists in the
iteration

```math
    x^{n+1} = x^{n} - [J(x^n)]^{-1} F(x^n),\qquad\mathrm{for}\ n=0,1,2...,
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
``J`` and right hand side ``F``. We can write this system into a 3-by-3
block-matrix form, with rows corresponding to equations and columns
corresponding to unknowns split into the three groups.

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

This is an interesting case. Pay attention because this part is tricky.

We have the following equations.

```math
\begin{aligned}
    S \cdot \delta x_s &+ C_s \cdot \delta x_c &= F_s \\
    S_c \cdot \delta x_s &+ C \cdot \delta x_c &= F_c
\end{aligned}
```

We eliminate ``\delta x_c`` from the system. To do so, we multiply the second
equation by ``C_s C^{-1}`` and subtract the result from the first equation.

```math
    \left( S - C_s C^{-1} S_c \right) \cdot \delta x_s = F_s - C_s C^{-1} F_c
```

#### Solve for ``\delta x_s``

Suppose that ``F_c = 0``. We will discuss later how we make sure that's the
case. Then the solution for ``\delta x_s`` is given by

```math
    \left( S - C_s C^{-1} S_c \right) \cdot \delta x_s = F_s
```

The only difference with case 1 and 2 is that the system matrix is modified by
subtracting ``C_s C^{-1} S_c``. The matrix ``C^{-1} S_c`` is constant. This
matrix is specific to the `fcslope` type of final conditions for the given
model. It only depends on the number of variables and the number of final
conditions periods. It can be pre-computed and stored.

The matrix ``C_s`` on the other hand depends on ``x^n`` and so it needs to be
re-computed at every iteration.

#### Solve for ``\delta x_c``

How do we make sure that ``F_c = 0``? Remember that the final conditions
equation in our example model is

```math
y_5 - y_4 = ssY_{slope}.
```

Imagine how this would generalize to an arbitrary model. Now notice that the
residual ``F_c`` depends on ``x^n`` and the slope of the steady state
``ssY_{slope}``. Since we know the ``x^n_s`` part of ``x^n`` prior to solving
the system, we can set the ``x^n_c`` part of ``x^n`` so that the final
conditions are satisfied. In other words, this would make sure that ``F_c = 0``.
One way to do this is to simply start from the values of the variables at the
last period of the simulation (which are in ``x^n_s``; that's ``y_4`` in our
example) and compute all future values (which are in ``x^n_c``,; that's ``y_5``
in the example) by adding the corresponding steady state slope (that is
``y_5 = y_4 + ssY_{slope}``). We must do this on every iteration before we
evaluate ``F(x^n)`` and ``J(x^n)``.

Actually, that's not true. It turns out that we only need to do this to the
initial guess ``x^0``. After that, once we compute ``\delta x_s`` by solving the
above system, we can solve the following system for ``\delta x_c``.

```math
    C \cdot \delta x_c = - S_c \cdot \delta x_s
```

With ``\delta x`` computed this way, the resulting ``x^{n+1}`` will produce
``F_c=0`` at the next iteration. This can be verified directly.

#### The Matrices: ``C``, ``S_c`` and ``C^{-1}S_c``

These matrices have ``0`` everywhere except for some non-zero blocks, which we
discuss here.

Our running example has only one period of final conditions and a single
variable, which is a trivial case. In order to see what happens in a more
general case, suppose we have 4 periods of final conditions and several
variables. In matrix ``C`` we will have a block, ``C_b``, like the one below for
each variable in the model. Each ``C_b`` will be the same square block with as
many rows and columns as the number of final condition periods.

```math
C_b = \begin{bmatrix}
    1 & 0 & 0 & 0 \\ -1 & 1 & 0 & 0 \\ 0 & -1 & 1 & 0 \\ 0 & 0 & -1 & 1
    \end{bmatrix}
```

Matrix ``S_c`` also contains identical blocks ``S_{c,b}`` for each variable. The
number of rows is the same as ``C_b``, while the number of columns equals the
number of simulation periods. The ``-1`` in the top-right corner is in the
column corresponding to the last period of the simulation. (In our trivial
example above that would be ``t=4``)

```math
S_{c,b} = \begin{bmatrix}
            0 & \cdots & 0 & -1 \\
            0 & \cdots & 0 & 0 \\
            0 & \cdots & 0 & 0 \\
            0 & \cdots & 0 & 0
          \end{bmatrix}
```

Now it is straightforward to compute ``C^{-1} S_c``. It also has block-structure
with blocks like this:

```math
 \left(C^{-1}S_c\right)_b = \begin{bmatrix}
            0 & \cdots & 0 & -1 \\
            0 & \cdots & 0 & -1 \\
            0 & \cdots & 0 & -1 \\
            0 & \cdots & 0 & -1 \\
        \end{bmatrix}.
```

The column with ``-1`` again corresponds to the last period of the simulation.

### Case 4: `fcnatural`

This case is identical to case 3. The only thing that changes is the matrices.

This time for our example we will use 5 periods of final conditions, so that the
patterns would be more obvious. We have the following.

```math
C_b = \begin{bmatrix}
    -1 &  0 &  0 &  0 &  0 \\
     2 & -1 &  0 &  0 &  0 \\
    -1 &  2 & -1 &  0 &  0 \\
     0 & -1 &  2 & -1 &  0 \\
     0 &  0 & -1 &  2 & -1 \\
    \end{bmatrix}
```

For ``S_c`` this time we have non-zeros in two columns corresponding to the last
two periods of the simulation.

```math
S_{c,b} = \begin{bmatrix}
            0 & \cdots & 0 & -1 & 2 \\
            0 & \cdots & 0 & 0 & -1 \\
            0 & \cdots & 0 & 0 &  0 \\
            0 & \cdots & 0 & 0 &  0 \\
            0 & \cdots & 0 & 0 &  0 \\
          \end{bmatrix}
```

Finally, we have

```math
 \left(C^{-1}S_c\right)_b = \begin{bmatrix}
            0 & \cdots & 0 & 1 & -2 \\
            0 & \cdots & 0 & 2 & -3 \\
            0 & \cdots & 0 & 3 & -4 \\
            0 & \cdots & 0 & 4 & -5 \\
            0 & \cdots & 0 & 5 & -6 \\
        \end{bmatrix},
```

## Handling of log-variables

If we have log variables the final conditions the cases of `fclevel` and
`fcgiven` are the same as above.

In the case of `fcslope` the balanced growth path solution is actually a
geometric sequence. What we call its "slope" here is actually the common ratio,
that is ``ssY_{slope} = ssY_{t} / ssY_{t-1}`` for all ``t``. We have final
condition equations that look like this:

```math
    y_5 / y_4 = ssY_{slope}.
```

In the case of `fcnatural`, we again impose the condition that the solution must
be a geometric sequence, although this time the common ratio is unknown and
we must solve for it. We have final conditions like this

```math
    y_5 / y_4 = y_4 / y_3.
```

In both cases it is better to work with an equivalent formulation in terms of logs.

```math
\begin{aligned}
    log(y_5) &= log(y_4) + log(ssY_{slope}) \qquad & \mathrm{for `fcslope`} \\
    log(y_5) &= 2 log(y_4) - log(y_3) \qquad & \mathrm{for `fcnatural`}
\end{aligned}
```

If we were to implement this directly, the matrix blocks ``C_b`` and ``S_{c,b}``
corresponding to log-variables would not be constant (as they were above for
non-log variables), because they would contain the derivatives of the above log
functions and would therefore need to be re-computed on each iteration.

However, in our implementation of log-variables, we apply the log-transformation
and so the unknowns we actually solve for are ``log(y_t)``. Thus, the final
conditions are in fact identical to the ones for non-log variables and we don't
need to do anything special here.

## Conclusion


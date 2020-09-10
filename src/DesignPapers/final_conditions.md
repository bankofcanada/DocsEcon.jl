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
0.5 y_1 - y_2 + 0.5 y_3 = s_2   \\
0.5 y_2 - y_3 + 0.5 y_4 = s_3   \\
0.5 y_3 - y_4 + 0.5 y_5 = s_4   \\
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
y_5 = S_{level}
```

Where ``S_{level}`` is the steady state of ``y``. This works if the steady state of
``y`` is a constant level.

### `fcslope`

In this case we write an equation which sets the first difference of ``y_t`` at
the end of the simulation (and for all final conditions periods) to the slope of
the steady state. This works if the steady state of ``y_t`` is a constant level
or a constant rate of change, i.e. a balanced path of linear growth.

The equation is

```math
y_5 - y_4 = S_{slope},
```
where ``S_{slope}`` is the slope of the steady state of ``y_t``.

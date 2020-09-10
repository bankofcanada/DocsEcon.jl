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

As a running example, consider a model with one variable `y`, one shock `sy`,
and one equation:
``0.5 y_{t-1} - y_t + 0.5 y_{t+1} = s_t``

Suppose we want to simulate 3 periods. Let's use indices ``t=2..4`` for the
simulation periods. In the stacked time algorithm we have to solve the following
system of equations:

``
0.5 y_1 - y_2 + 0.5 y_3 = s_2
0.5 y_2 - y_3 + 0.5 y_4 = s_3
0.5 y_3 - y_4 + 0.5 y_5 = s_4
``

We see that we have 3 equations with 5 unknowns. In order to find a unique
solution, we need two more equations. The first one is the initial condition.
``
y_1 = Y_1,
``
where ``Y_1`` is a known value of ``y`` at time ``t=1``. The last equation is
the final condition, which would help us solve for ``y_5``.

## Types of Final Conditions





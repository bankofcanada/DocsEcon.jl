# Log-variables

This article describes the intended meaning of declaring a variable using the
`@log` annotation and the internal handling of such variables.

## What is a log-variable

A variable should be declared using the `@log` annotation when its balanced
growth path is exponential growth / decay. Specifically this means that

```math
X_t = c X_{t-1},
```

for some ``c``, which we call its *slope*. The growth rate, let's call it
``\rho``, is related to the slope as ``c = 1 + \rho``.

This has implications to how we solve for the steady state (balanced growth path)
of such variable and also to how we impose final conditions of type `fcslope` and
`fcnatural`.

## Implementation details

Internally we work with the log transformation of log variables. All equations
and data provided by the user should be in terms of the declared variable. This
log transformation is done internally and automatically and should be completely
transparent to the user.

It is not strictly necessary to use such transformation. However, this approach
simplifies several aspects of the implementation. In addition, a log-variable is
always positive and usually appears in expressions involving log, fractional
powers and division, which produce domain errors if the argument is
non-positive. By working with the log, which is allowed to be any real number,
we avoid such problems.

Applying this transformation affects the following parts of the implementation.

* Transform the dynamic equations and their corresponding steady state equations.
* Transform the steady-state constraints.
* Apply appropriate final conditions in the case of `fcslope` and `fcnatural`.
* Transform the linearization about a solution with log-variables.

We also need to transform the user provided data before running the solution
algorithms and then transform the solution by the inverse transformation before
returning it.

* initial conditions
* exogenous data
* steady state solution
* simulation result
* data given in deviation from the steady state

We address each of these in the remainder of this article.

## Transformations of the equations

### Dynamic equations

When a mention of a variable is encountered in an equation, that mention is
replaced by a new symbol whose name is made up from the name of the variable and
the lag or lead value. For example, equation `Y[t] = Y[t-1] + 0.1` becomes
`#Y#0# = #Y#-1# + 0.1`.

When a variable is declared `@log X`, the new symbols created for the different
lags have the meaning of the log of that variable. For example, equation
`X[t] / X[t-1] = 1.01` becomes `exp(#logX#0#) / exp(#logX#-1#) = 1.01`.

All we have to do from this point on is make sure that the values for these
variables are transformed accordingly. In particular, all derivatives are
automatically transformed since we use automatic differentiation.

### Steady state equations derived from dynamic equations

For regular variables we substitute `Y[t] = lvl_Y + (t-t_ref) * slp_Y` in the
dynamic equations. `t_ref` is a reference time, the time at which
`Y[t] = lvl_Y`. All lags and leads of `Y` are unknowns in the dynamic system,
while here in the steady state system we have two unknowns, namely `lvl_Y` and
`slp_Y`. For this reason, we take each equation at two different values of `t`.

In the case of `@log X` variable, we have
`X[t] = exp(lvl_logX + (t-t_ref) * slp_logX)`. In this case, the reference level
is `X[t] = exp(lvl_logX)` and the growth rate of the balanced growth path
solution is `(X[t] - X[t-1])/X[t-1] = exp(slp_logX) - 1`. So the "slope" is
`c = exp(slp_logX)`.

### 






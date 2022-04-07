# Log-variables

This article describes the intended meaning of declaring a variable using the
`@log` annotation, and the internal handling of such variables.

## What is a log-variable

A variable should be declared using the `@log` annotation when its balanced
growth path is exponential growth or decay. Specifically this means that

```math
X_t = c X_{t-1},
```

for some ``c``, which we call its *slope*. The balanced growth path forms a
geometric sequence with common ratio ``c``. The growth rate, let's call it
``r``, is related to the slope as ``c = 1 + r``.

This has implications to how we solve for the steady state of such variable and
also to how we impose final conditions of type `fcslope` and `fcnatural`.

## Implementation details

Internally we work with the log transformation of log variables. All equations
and data provided by the user should be in terms of the declared variable. This
log transformation is done internally, automatically, and should be completely
transparent to the user.

It is not strictly necessary to use such transformation. However, this approach
simplifies several aspects of the implementation. In addition, a log-variable is
always positive and usually appears as argument to logarithms, fractional powers
and division, which might produce domain errors if the argument becomes negative
or zero, for example during the solver iterations. By working with the log of
the variable, which is allowed to be any real number, we avoid such problems.

Applying this transformation affects the following parts of the implementation.

* Transform the dynamic equations and their corresponding steady state
  equations.
* Transform the steady-state constraints.
* Apply appropriate final conditions in the case of `fcslope` and `fcnatural`.
* Transform the linearization about a solution with log-variables.

We also need to transform the user provided data before running the solution
algorithms and then transform the solution back by applying the inverse
transformation before returning it to the user. This includes

* initial conditions,
* exogenous data,
* steady state solution,
* simulation result,
* data given in deviation from the steady state.

We address each of these in the remainder of this article.

## Transformations of the equations

### Dynamic equations

When a mention of a variable is encountered in an equation, we replace that
mention by a new symbol whose name is made up from the name of the variable and
the lag or lead value. For example, equation `Y[t] = Y[t-1] + 0.1` becomes
`#Y#0# = #Y#-1# + 0.1`, where `#Y#0#` and `#Y#-1#` are the new variable names
corresponding to the contemporaneous and lag 1 values of Y.

When a variable is declared `@log X`, the new symbols created for the different
lags have the meaning of the log of that variable. For example, equation
`X[t] / X[t-1] = 1.01` becomes `exp(#logX#0#) / exp(#logX#-1#) = 1.01`.

All we have to do from this point on is to make sure that the data values for
these variables are transformed accordingly. In particular, there is no need to
do anything about transforming the gradients of the equation residual functions,
since they are automatically computed from the transformed equation by automatic
differentiation.

### Steady state equations derived from dynamic equations

For regular variables we substitute
```math
Y_t = lvl_Y + (t-t_{ref}) * slp_Y
```
in the dynamic equations. `t_ref` is a reference time: time at which
`Y[t_ref] = lvl_Y`. All lags and leads of `Y` are unknowns in the dynamic
system, while here, in the steady state system, we have two unknowns, namely
`lvl_Y` and `slp_Y`. For this reason, we take each equation at two different
values of `t`.

In the case of `@log X` variable, we have the steady state substitution
```math
X_t = exp(lvl_{logX} + (t-t_{ref}) * slp_{logX}).
```

Since the dynamic equations have already been transformed in terms of
`log(X_t)`, we actually have to do the substitution
```math
log(X_t) = lvl_{logX} + (t-t_{ref}) slp_{logX},
```
which is the same as for non-log variables. So once again we don't need to do
anything to the equations, we only need to transform the data.

### Steady state constraints

Here we expect the user to provide equations in terms of the original meaning of
the log-variable. When `X` is mentioned in a level type constraint, we replace
it by `exp(lvl_logX)` and similarly in a slope type constraint we replace is by
`exp(slp_logX)`.

This works well when the constraint is simply assigning a known value. The user
must keep in mind that we interpret the slope as the common ratio of the
geometric sequence and provide values in these terms.

### Final conditions

This is discussed at the end of the article on final conditions. TLDR: we don't
need to do anything special since we're working with the log-transformed
variables.

### Linearization

**TODO**

## Transforming the data

Every value of user-provided data for a log-variable we must apply `log()`
before using it internally. Also, every value we compute for a log-variable, we
must apply `exp()` before returning it to the user.

There is nothing special about this, we just have to make sure to do it.

### Data provided in deviation

**TODO**

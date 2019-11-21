# StochasticBlockModel

[![Build Status](https://travis-ci.com/BSAraujo/StochasticBlockModel.jl.svg?branch=master)](https://travis-ci.com/BSAraujo/StochasticBlockModel.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/BSAraujo/StochasticBlockModel.jl?svg=true)](https://ci.appveyor.com/project/BSAraujo/StochasticBlockModel-jl)
[![Codecov](https://codecov.io/gh/BSAraujo/StochasticBlockModel.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/BSAraujo/StochasticBlockModel.jl)
[![Coveralls](https://coveralls.io/repos/github/BSAraujo/StochasticBlockModel.jl/badge.svg?branch=master)](https://coveralls.io/github/BSAraujo/StochasticBlockModel.jl?branch=master)


StochasticBlockModel.jl is a Julia package that provides methods for common tasks related to Stochastic Block Models (SBM), such as generating random graphs with community structure and detecting communities in a given network. Community detection is performed by estimating the parameters of a SBM from an observed graph. Different heuristics and one exact method are provided for the problem of finding the maximum log-likelihood estimate of the parameters of a SBM.

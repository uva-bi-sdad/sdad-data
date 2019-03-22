library(sp)
library(gstat)

X = c(61,63,64,68,71,73,75)
Y = c(139,140,129,128,140,141,128)
Z = c(477,696,227,646,606,791,783)

X1 = 65; Y1 = 137

knowndt = data.frame(X,Y,Z)
coordinates(knowndt)  <- ~ X + Y

unknowndt = data.frame(X1,Y1)
coordinates(unknowndt)  <- ~ X1 + Y1

idwmodel = idw(Z ~1, knowndt,unknowndt, maxdist = Inf, idp = 2)

predZ = idwmodel@data$var1.pred
predZ

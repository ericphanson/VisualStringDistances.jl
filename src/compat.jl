@static if v"0.7" <= VERSION < v"1.1.0-DEV.792"
    eachrow(A::AbstractVecOrMat) = (view(A, i, :) for i in axes(A, 1))
end

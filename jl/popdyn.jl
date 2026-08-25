function plusonly(x)
    if x > 0
        return x
    else return
        0
    end
end


function popdyn(x0, y0, β, τ, μ, K, iter)
    x = zeros(iter + 1)
    y = zeros(iter + 1)
    x[1] = x0
    y[1] = y0

    for t in 2:(iter + 1)
        x[t] = x[t-1] + β * plusonly(x[t-1] + y[t-1])*(1 - (x[t-1] + y[t-1])/K) - μ*x[t-1]
        y[t] = y[t-1] + τ * plusonly(x[t-1] + y[t-1])*(1 - (x[t-1] + y[t-1])/K) - μ*y[t-1]
    end

    hcat(x, y)
end


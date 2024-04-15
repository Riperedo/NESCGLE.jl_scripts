using NESCGLE
using JSON

function main(args...)
    # user inputs
    ν_str =  args[1]
    
    # variable definition
    ν = parse(Int64, ν_str)

    # preparing saving folder
    save_path = NESCGLE.make_directory("SCGLE")
    save_path = NESCGLE.make_directory(save_path*"WCA")
    filename = save_path*"arrest_WCA_nu"*string(ν)*".json"

    if !isfile(filename)
        # preparing ϕ-T space grid
        phi = collect(0.58:0.001:0.7)
        Temperature = zeros(length(phi))
        T_min = 1e-6
        T_max = 1e1
        
        # preparing Input object
        k = collect(0:0.1:15*π)

        # main loop
        for (i, ϕ) in enumerate(phi)
            println("Computing ϕ= ", ϕ)
            function condition(T)
                I = Input_WCA(ϕ, T, k)
                iterations, gammas, system = Asymptotic(I, flag = false)
                return system == "Glass"
            end
            Temperature[i] = NESCGLE.bisection(condition, T_min, T_max, 1e-6)
        end
        #saving data
        data = Dict("phi"=>phi, "Temp"=>Temperature)
        open(filename, "w") do file
            JSON.print(file, data)
        end
    end
    println("Calculation complete.")
end

@time main(ARGS...)
# julia Eq_WCA_script.jl 0.61 1.0

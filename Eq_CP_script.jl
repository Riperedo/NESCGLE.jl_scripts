using NESCGLE
using JSON

function main(args...)
    # user inputs
    ϕC_str, ϕP_str, ξ_str =  args

    # variable definition
    ϕC = parse(Float64, ϕC_str)
    ϕP = parse(Float64, ϕP_str)
    ξ = parse(Float64, ξ_str)

    # preparing saving folder
    save_path = NESCGLE.make_directory("SCGLE")
    save_path = NESCGLE.make_directory(save_path*"CP")
    save_path = NESCGLE.make_directory(save_path*"xi"*num2text(ξ))
    save_path = NESCGLE.make_directory(save_path*"phiC"*num2text(ϕC))
    save_path = NESCGLE.make_directory(save_path*"phiP"*num2text(ϕP))
    filename = save_path*"output.json"
    if !isfile(filename)
        println("Running SCGLE")
        # wave vector
        k = collect(0:0.1:15*π)
        
        # computing Static structures
        I = Input_AO(ϕC, ϕP, ξ, k)
        S = structure_factor(I)
        # computing dynamics
        τ, Fs, F, Δζ, Δη, D, W = SCGLE(I)
        # parsing to json file
        structural_data = Dict("k"=>k, "S"=>S)
        dynamics_data = Dict("tau"=>τ, "sISF"=>Fs, "ISF"=>F, "Dzeta"=>Δζ, "Deta"=>Δη, "D"=>D, "MSD"=>W)
        data = Dict("Statics"=>structural_data, "Dynamics"=>dynamics_data)
        # saving data
        open(filename, "w") do file
            JSON.print(file, data)
        end
    end
    println("Calculation complete.")
end

@time main(ARGS...)
# julia Eq_CP_script.jl 0.25 1.0 0.1
using NESCGLE
using JSON

function main(args...)
    # user inputs
    ϕ_str, T_str, z_str =  args

    # variable definition
    ϕ = parse(Float64, ϕ_str)
    T = parse(Float64, T_str)
    z = parse(Float64, z_str)
    # preparing saving folder
    save_path = NESCGLE.make_directory("SCGLE")
    save_path = NESCGLE.make_directory(save_path*"Yukawa")
    save_path = NESCGLE.make_directory(save_path*"z"*num2text(z))
    save_path = NESCGLE.make_directory(save_path*"phi"*num2text(ϕ))
    save_path = NESCGLE.make_directory(save_path*"T"*num2text(T))
    filename = save_path*"output.json"
    if !isfile(filename)
        println("Running SCGLE")
        # wave vector # WARNING NaN at k=0 for this system
        k = collect(0.01:0.1:15*π)
        
        # computing Static structures
        #I = T != 0 ? Input_Yukawa(ϕ, 1/T, z, k) : Input_HS(ϕ, k, VW=true)
        I = Input_Yukawa(ϕ, 1/T, z, k)
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
#julia Eq_YA_script.jl 0.25 1.5 2.0

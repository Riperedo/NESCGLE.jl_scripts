using NESCGLE
using JSON

function main(args...)
    # user inputs
    z_str =  args[1]
    
    # variable definition
    z = parse(Float64, z_str)

    # preparing saving folder
    save_path = NESCGLE.make_directory("SCGLE")
    save_path = NESCGLE.make_directory(save_path*"Yukawa")
    save_path = NESCGLE.make_directory(save_path*"z"*num2text(z))
    filename_a = save_path*"arrest_Yukawa_z"*num2text(z)*".json"
    filename_s = save_path*"spinodal_Yukawa_z"*num2text(z)*".json"
    
    if !isfile(filename_s)
        # computiing spinodal
        phi = collect(0.01:0.001:0.58)
        T_spinodal = zeros(length(phi))
        T_min = 1e-6
        T_max = 1e1
            
        # preparing Input object
        k = collect(0.01:0.1:π)

        # main loop
        for (i, ϕ) in enumerate(phi)
            println("Computing ϕ= ", ϕ)
            function condition(T)
                I = Input_Yukawa(ϕ, 1/T, z, k)
                S = structure_factor(I)
                return sum(S .< 0.0) == 0
            end
            T_spinodal[i] = NESCGLE.bisection(condition, T_max, T_min, 1e-3)
        end
        #saving data
        data = Dict("phi"=>phi, "Temp"=>T_spinodal)
        open(filename_s, "w") do file
            JSON.print(file, data)
        end
        save_data("test_s.dat", [phi T_spinodal])
    end
    # TO DO binodal

    if !isfile(filename_a)
        # preparing ϕ-T space grid
        dict = JSON.parsefile(filename_s)
        Phi = dict["phi"]
        T_s = dict["Temp"]
        phi = zeros(length(Phi))
        Temperature = zeros(length(phi))
        T_max = 1e1
        
        # preparing Input object
        k = collect(0.1:0.1:25*π)

        # main loop
        for (i, ϕ) in enumerate(Phi)
            println("Computing ϕ= ", ϕ)
            function condition(T)
                I = Input_Yukawa(ϕ, 1/T, z, k)
                iterations, gammas, system = Asymptotic(I, flag = false)
                return system == "Glass"
            end
            phi[i] = ϕ
            Temperature[i] = NESCGLE.bisection(condition, T_s[i], T_max, 1e-6)
        end
        #saving data
        data = Dict("phi"=>phi, "Temp"=>Temperature)
        open(filename_a, "w") do file
            JSON.print(file, data)
        end
        save_data("test.dat", [phi Temperature])
        println(z)
    end
    println("Calculation complete.")
end

@time main(ARGS...)
# julia Eq_WCA_script.jl 0.61 1.0

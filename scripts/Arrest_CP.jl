using NESCGLE
using JSON

function main(args...)
    # user inputs
    ξ_str =  args[1]
    
    # variable definition
    ξ = parse(Float64, ξ_str)

    # preparing saving folder
    save_path = NESCGLE.make_directory("SCGLE")
    save_path = NESCGLE.make_directory(save_path*"CP")
    save_path = NESCGLE.make_directory(save_path*"xi"*num2text(ξ))
    filename_a = save_path*"arrest_CP_xi"*num2text(ξ)*".json"
    filename_s = save_path*"spinodal_CP_xi"*num2text(ξ)*".json"
    
    if !isfile(filename_s)
        # computiing spinodal
        C = collect(0.01:0.001:0.58)
        P_spinodal = zeros(length(C))
        P_min = 1e-6
        P_max = 1e2
            
        # preparing Input object
        k = collect(0.01:0.1:π)

        # main loop
        for (i, ϕC) in enumerate(C)
            println("Computing ϕC= ", ϕC)
            function condition(ϕP)
                I = Input_AO(ϕC, ϕP, ξ, k)
                S = structure_factor(I)
                return sum(S .< 0.0) == 0
            end
            P_spinodal[i] = NESCGLE.bisection(condition, P_min, P_max, 1e-3)
        end
        #saving data
        data = Dict("phiC"=>C, "phiP"=>P_spinodal)
        open(filename_s, "w") do file
            JSON.print(file, data)
        end
        save_data("test_s.dat", [C P_spinodal])
    end
    # TO DO binodal

    if !isfile(filename_a)
        # preparing ϕ-T space grid
        dict = JSON.parsefile(filename_s)
        C = dict["phiC"]
        P_s = dict["phiP"]
        c = zeros(length(C))
        p = zeros(length(C))
        P_min = 1e-6
        
        # preparing Input object
        k = collect(0.0:0.1:25*π)

        # main loop
        for (i, ϕC) in enumerate(C)
            println("Computing ϕC= ", ϕC)
            function condition(ϕP)
                I = Input_AO(ϕC, ϕP, ξ, k)
                iterations, gammas, system = Asymptotic(I, flag = false)
                return system == "Glass" || system == "Dump" #|| gammas[end] < 10.0
                #return system == "Fluid"
            end
            c[i] = ϕC
            p[i] = NESCGLE.bisection(condition, P_s[i], P_min, 1e-6)
            #p[i] = NESCGLE.bisection(condition, P_min, P_s[i], 1e-6)
        end
        #saving data
        data = Dict("phiC"=>c, "phiP"=>p)
        open(filename_a, "w") do file
            JSON.print(file, data)
        end
        save_data("test.dat", [c p])
        println(ξ)
    end
    println("Calculation complete.")
end

@time main(ARGS...)
# julia Eq_WCA_script.jl 0.61 1.0

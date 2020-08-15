

tutorial_path(path="") = joinpath("src", path)

function scan_path!(c, path; ext=".md") # dispatches based on path type
    tut_path = tutorial_path(path)
    if isdir(tut_path)
        add_dir!(c, path; ext=ext)
    elseif isfile(tut_path)
        add_page!(c, path; ext=ext)
    else
        error("$(path) is neither a file nor a directory")
    end
    if length(c) == 1
        return c[1]
    else
        return c
    end
end

function add_page!(c, path; ext)
    tut_path = tutorial_path(path)
    if endswith(tut_path, ext)
        title = open(tut_path) do f
            firstline = readline(f)
            strip(firstline, ['#', ' '])
        end
        push!(c, string(title) => string(path))
    end
    return c
end

function add_dir!(c, path; ext)
    new_c = []
    for p in readdir(tutorial_path(path))
        scan_path!(new_c, joinpath(path, p); ext=ext)
    end
    if length(new_c) == 1
        push!(c, new_c[1])
    elseif length(new_c) > 1
        title = basename(path)
        push!(c, string(title) => new_c)
    end
    return c
end

tutorials = scan_path!([], "Tutorials")

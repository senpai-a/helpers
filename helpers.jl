module helpers
export log,printProcess,flushProcess,endswith
export matShowGray,matShow,matShow3d,peek
export collectImgFilename,collectImgSubfolder,collectFilesSubfolder,collectFiles

using Images
using Printf
#using Makie
using Plots

import Base.log
function log(fn::String,msg)::Nothing
    f = open(fn,append=true)
    println(f,msg)
    println(msg)
    close(f)
end
log(msg::String)=log("log.txt",msg)

function matShow(mat,name=" ")
    Plots.heatmap(Array(mat),title=name,yflip=true,aspect_ratio = 1)
end

function matShowGray(mat)
    ma = maximum(mat)
    mi = minimum(mat)
    Gray.(Array((mat.-mi)./(ma-mi)))
end

function peek(mat)
    m,n = size(mat)
    println("$(m÷2+1):$(m÷2+5),$(n÷2+1):$(n÷2+5)")
    display(mat[m÷2+1:m÷2+5,n÷2+1:n÷2+5])
end

function matShow3d(mat)
    m,n=size(mat)
    ma = maximum(mat);    mi = minimum(mat)
    mat2 = (mat.-mi)./(ma-mi)
    mat3 = mat2.*max(m,n)
    x = similar(mat); y=similar(mat)
    for i in 1:m x[i,:].=i end
    for j in 1:n y[:,j].=j end
    if(max(m,n)<150) s = 1
    else s = max(m,n)/150 end
    Makie.meshscatter(x[:],y[:],mat3[:];
        marker = Rect3D(Vec3f0(0,0,0), Vec3f0(1,1,-1)),
        markersize = Vec3f0.(s, s, mat3[:]),
        color = mat2[:],
        shading = false
        )
end

function collectImgFilename(path)::Array{String,1}
    ret = String[]
    print("\ncollect images in $path: ")
    for (root, dirs, files) in walkdir(path)
        for file in files
            f=lowercase(file)
            if endswith(f,".jpg") | endswith(f,".png") |
                endswith(f,".jpeg") | endswith(f,".bmp")
                push!(ret,joinpath(root, file)) # path to files
                #print(file," ")
            end
        end
    end
    println("$(length(ret)) image(s)")
    return ret
end
function collectImgSubfolder(path::String)
    ret = Dict{String,Array{String,1}}()
    println("\ncollect images in $path:")
    for (root,dirs,files) in walkdir(path)
        for file in files
            f=lowercase(file)
            if endswith(f,".jpg") | endswith(f,".png") |
                endswith(f,".jpeg") | endswith(f,".bmp")
                if root ∉ keys(ret)
                    ret[root]=String[]
                end
                push!(ret[root],joinpath(root,file))
            end
        end
    end
    for k in keys(ret)
        println("\t$k : $(length(ret[k])) image(s).")
    end
    ret
end
function printProcess(i::AbstractFloat;len::Int=50,printPercentage::Bool=false)::Nothing
    k::Int = floor(i*len)
    tails=String["","▏","▎","▍","▌","▋","▊","▉"]
    re::Int = floor((i*len - k)*8)
    tail::String = tails[re+1]
    spa::Int = len-k-length(tail)
    if spa<0 spa=0 end
    print("\r▕$("█"^k)$(tail)$(" "^spa)▎")#░
    if printPercentage print("$(@sprintf("%.2f",i*100))%") end
    #print("\r")
end

function printProcess(i::Int,N::Int;len::Int=50,printPercentage::Bool=false)::Nothing
    printProcess(i/N;len=len,printPercentage=printPercentage)
end

flushProcess(i::Int=60)::Nothing = print("\r$(" "^i)\r")

import Base.endswith
function endswith(str::AbstractString,tail::Vector{String})::Bool
    for s in tail
        if endswith(str,s)
            return true
        end
    end
    return false
end

#collect files with given suffixes from a list of path
function collectFiles(paths::Vector{String},suffixes::Vector{String})::Vector{String}
    ret = String[]
    for path in paths
        if !ispath(path)
            println("$(path): no such file or directory.")
            continue
        end
        if isfile(path)
            if endswith(lowercase(path),suffixes) push!(ret,path) end
        elseif isdir(path)
            for (root,dirs,files) in walkdir(path)
                for file in files
                    if endswith(lowercase(file),suffixes) push!(ret,joinpath(root,file)) end
                end
            end
        end
    end
    return ret
end

function collectFilesSubfolder(paths::Vector{String},suffixes::Vector{String})
    ret = Dict{String,Array{String,1}}()
    for path in paths
        if !ispath(path)
            println("$(path): no such file or directory.")
            continue
        end
        if isfile(path)
            if endswith(lowercase(path),suffixes) push!(ret,path) end
        elseif isdir(path)
            println("\ncollect files in $path:")
            for (root,dirs,files) in walkdir(path)
                for file in files
                    f=lowercase(file)
                    if endswith(f,suffixes)
                        if root ∉ keys(ret)
                            ret[root]=String[]
                        end
                        push!(ret[root],joinpath(root,file))
                    end
                end
            end
        end
    end
    for k in keys(ret)
        println("\t$k : $(length(ret[k])) image(s).")
    end
    ret
end

end

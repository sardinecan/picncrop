using GLMakie
using FileIO
using ImageIO

path = @__DIR__

input = readdir(path*"/input", join=true)
images = [load(image) for image in input]

fig = Figure()

#i_slice = Observable(1)

image = Observable(1)

ax =    Axis(
            fig[1, 1],
            aspect = DataAspect(), 
            yreversed = true,
            title = @lift("Image $($image)")
        )
hidedecorations!(ax)

selectediImage = @lift(images[$image]')

i = image!(ax, selectediImage)
translate!(i, 0, 0, -5)

buttongrid = fig[1, 2] = GridLayout(tellheight = false)
b = Button(buttongrid[1, 1], label = "Save crop")
b2 = Button(buttongrid[2, 1], label = "Next image")
b3 = Button(buttongrid[3, 1], label = "Previous image")
b4 = Button(buttongrid[4, 1], label = "Reload")

on(b.clicks) do c
    lims = ax.finallimits[]
    
    mini, maxi = extrema(lims) # get the bottom left and top right corners of `lims`
    mini = round.(Int, mini) # to index into an image, which is an array, we need ints
    maxi = round.(Int, maxi) # and the axis bounding box is always represented in floats
    croppedImage = selectediImage[][mini[1]:maxi[1], mini[2]:maxi[2]]
    pos = parse(Int64, "$(image[])")
    ext = split(input[pos], ".")[2]
    save(path*"/output/image_$(image[])."*ext, rotl90(croppedImage[:, end:-1:1]))
end

on(b2.clicks) do c
    image[] = mod1(image[] + 1, length(input))
    autolimits!(ax)
end

on(b3.clicks) do c
    image[] = mod1(image[] - 1, length(input))
    autolimits!(ax)
end
on(b4.clicks) do c
    image[] = mod1(image[], length(input))
    autolimits!(ax)
end

fig
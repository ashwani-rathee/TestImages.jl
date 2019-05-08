using Images, YAML, ColorTypes
# Open the HTML prequel and put it into our content we build.
content = read("open.txt",String)

# Read all images
f = readdir("images/")
# Read yaml metadata
imageMetadata = YAML.load(open("metadata.yml"))

# Initialize Thumbnails directory and set default height to 200
if isdir("thumbnails")
  rm("thumbnails/", recursive=true)
end
mkdir("thumbnails")
cp("cannot_be_displayed.png","thumbnails/cannot_be_displayed.png")
HEIGHT = 200

# Go through all files
for i in f
    global content
    println("Processing "*i)
    img = load(joinpath("images/",i))
    fname, ext =splitext(i)
  file=""
  # fetch metadata (is empty if no yaml entry exists)
  fileMeta = get(imageMetadata,fname,Dict())
  if length(size(img))==2
        file=fname*".png"
        if !isfile(joinpath("thumbnails/",file))
            img_size = size(img)
            resized_image = Images.imresize(img, (Int(ceil(img_size[1]*HEIGHT/img_size[2])), HEIGHT))
            save(joinpath("thumbnails/",file), resized_image)
        end
    else
        file="cannot_be_displayed.png"
    end
    content *= "\""*fname*"\" : "*"{"
  # check for metatdata fields and add them
  for key in ["name","url","author"]
    if haskey(fileMeta,key)
        content *= key * ":\"" * fileMeta[key] * "\", "
    end
  end
  # and the classical ones
  content *= "thumbnail:\""*file*"\", "
  content *= "file:\""*i*"\", "
  content *= "colorspace:\""*string(base_color_type(eltype(img)))*"\", "
  content *= "size : \""*string(size(img))*"\", "
  content *= "filetype : \""*uppercase(ext[2:end])*"\"},\n"
end
# add end of html file and write out js.
content *= read("close.txt",String)
write("displayimages.js", content);
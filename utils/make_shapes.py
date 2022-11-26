import pyllusion as ill

path = "C:/Users/anshu/Documents/GitHub/IllusionSelf/utils/"

# Generate Stimuli
## Circle
circle = ill.image_circles(
    width=250, height=250, size=1.5, n=1, x=[0], y=[0], color="red", background="grey"
)
circle.save(path + "circle.png")

## Square
square = ill.image_rectangle(
    width=250, height=250, x=0, y=0, size_width=1.5, size_height=1.5, color="red", background="grey"
)
square.save(path + "square.png")

## Triangle
import PIL.Image
import PIL.ImageDraw
import PIL.ImageFilter
import PIL.ImageFont
import PIL.ImageOps

width = 250
height = 250

image = PIL.Image.new("RGBA", (width, height), color="grey")
# mask = PIL.Image.new("RGBA", (width, height))
draw = PIL.ImageDraw.Draw(image)
draw.polygon([(20, 220), (230, 220), (125, 20)], fill="red")

image.save(path + "triangle.png")

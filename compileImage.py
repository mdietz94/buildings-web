from PIL import Image
import os
import math

size = 128, 128
width, height = size

imgs = [ x for x in os.listdir('./static/images') if x.startswith('bldg')]

i = 0.0
for imgName in imgs:
    im = Image.open('./static/images/' + imgName)
    im.thumbnail(size, Image.ANTIALIAS)
    im.save('./static/images/thumb_' + imgName)
    i += 1.0
    print("\r{0:.2%} Complete".format(i/len(imgs)), end='')
print()

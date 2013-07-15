from PIL import Image
import os
import math
from db import db
import random

size = 64, 64
width, height = size

imgs = [ x for x in os.listdir('./static/images') if x.startswith('bldg')]
num = min(len(imgs), 10000) # no more than 10K pictures in the background collection
bigWidth = bigHeight = math.ceil(math.sqrt(num)) * width

bigImage = Image.new("RGB", tuple([bigWidth, bigHeight]), "white")
x = 10
y = 10
i = 0.0
lowestPt = 0
for i in range(0,num):
    if x + width > bigWidth:
        x = 0
        y += height
    im = Image.open('./static/images/' + imgs[i])
    im.thumbnail(size, Image.ANTIALIAS)
    bigImage.paste(im, (x,y))
    x += width
    y += random.choice(range(-5,5))
    x += random.choice(range(-5,5))
    if y + height > lowestPt: lowestPt = y + height
    i += 1.0
    print("\r{0:.2%} Complete ({1},{2})".format(i/num, x, y), end='')
print("\rSaving completed image...", end='')
bigImage.crop((0, 0, bigWidth, lowestPt)).save('./static/images/collection.jpg', 'jpeg')
print()

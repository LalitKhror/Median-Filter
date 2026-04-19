import cv2
import numpy as np

input_image = r"C:\Data\My\lena_256x256.png"
output_mem  = r"C:\Data\My\lena_256x256.mem"

img = cv2.imread(input_image)

# resize just to ensure correct size
img = cv2.resize(img,(256,256))

# convert BGR → RGB
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

with open(output_mem,"w") as f:
    for y in range(256):
        for x in range(256):
            r,g,b = img[y,x]
            f.write(f"{r:02x}{g:02x}{b:02x}\n")

print("MEM file generated successfully")

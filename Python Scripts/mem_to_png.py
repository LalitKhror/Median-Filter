import numpy as np
import cv2

mem_file = r"C:\Data\My\lena_256x256_output.mem"
output_image = r"C:\Data\My\lena_256x256_output.png"

pixels = []

with open(mem_file, "r") as f:
    for line in f:
        line = line.strip()
        if line == "":
            continue

        val = int(line, 16)

        r = (val >> 16) & 0xFF
        g = (val >> 8) & 0xFF
        b = val & 0xFF

        pixels.append([r, g, b])

pixels = np.array(pixels, dtype=np.uint8)

expected_pixels = 256 * 256

print("Pixels read from MEM:", len(pixels))

# pad missing pixels if needed
if len(pixels) < expected_pixels:
    padding = np.zeros((expected_pixels - len(pixels), 3), dtype=np.uint8)
    pixels = np.vstack((pixels, padding))

# trim if too many
pixels = pixels[:expected_pixels]

img = pixels.reshape((256, 256, 3))

img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

cv2.imwrite(output_image, img)

print("PNG image generated successfully")

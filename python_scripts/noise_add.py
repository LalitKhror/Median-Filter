import cv2
import numpy as np

# input and output paths
input_path  = r"C:\Data\My\lena_256x256.png"
output_path = r"C:\Data\My\lena_256x256_sp_noise.png"

# noise percentage (example: 5%)
noise_percent = 5

# read image
img = cv2.imread(input_path)

if img is None:
    print("Error: image not found")
    exit()

# copy image
noisy_img = img.copy()

# total pixels
total_pixels = img.shape[0] * img.shape[1]

# number of noisy pixels
num_noise = int(total_pixels * noise_percent / 100)

# add salt noise (white pixels)
for _ in range(num_noise // 2):
    y = np.random.randint(0, img.shape[0])
    x = np.random.randint(0, img.shape[1])
    noisy_img[y, x] = [255, 255, 255]

# add pepper noise (black pixels)
for _ in range(num_noise // 2):
    y = np.random.randint(0, img.shape[0])
    x = np.random.randint(0, img.shape[1])
    noisy_img[y, x] = [0, 0, 0]

# save output image
cv2.imwrite(output_path, noisy_img)

print("Salt & Pepper noise added successfully.")
print("Saved at:", output_path)

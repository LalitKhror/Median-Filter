# generate_lena_raw.py
# Creates a dummy lena.raw file (256x256 RGB, 8-bit per channel)

with open("test.raw", "wb") as f:
    for row in range(256):        # 256 rows
        for col in range(256):    # 256 columns
            # Dummy RGB values: R = row, G = col, B = (row + col) % 256
            red = row % 256
            green = col % 256
            blue = (row + col) % 256
            # Write 3 bytes per pixel (RGB)
            f.write(bytes([red, green, blue]))

print("lena.raw created successfully! Size: 256x256x3 = 196,608 bytes")

import os
from PIL import Image

image_path = "/root/.gemini/antigravity-cli/brain/a8d3286e-6a2d-4590-91d9-53222e55c21a/cyber_tictactoe_logo_1786363915775.jpg"
output_dir = "/root/Desktop/flutter-test/hello_app/android/app/src/main/res"
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

try:
    with Image.open(image_path) as img:
        for folder, size in sizes.items():
            dir_path = os.path.join(output_dir, folder)
            os.makedirs(dir_path, exist_ok=True)
            out_img = img.resize((size, size), Image.Resampling.LANCZOS)
            out_img.save(os.path.join(dir_path, "ic_launcher.png"), "PNG")
    print("Icons successfully generated!")
except Exception as e:
    print(f"Error: {e}")

import subprocess
import os
import shutil

script_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(script_dir)
repo_url = 'https://github.com/sindhut1/Video_Tracker_Speech_Recognition'
clone_dir = os.path.join(script_dir, 'Video_Tracker_Speech_Recognition')

try:
    # Clone the repo into parent directory
    subprocess.run(['git', 'clone', repo_url, clone_dir], check=True)
    
    # Copy all files from cloned repo to parent directory
    for item in os.listdir(clone_dir):
        src = os.path.join(clone_dir, item)
        dst = os.path.join(script_dir, item)
        
        # Skip the cloned folder itself
        if src == clone_dir:
            continue
        
        if os.path.isdir(src):
            if os.path.exists(dst):
                shutil.rmtree(dst)
            shutil.copytree(src, dst)
        else:
            shutil.copy2(src, dst)
    
    # Delete the cloned folder
    shutil.rmtree(clone_dir)
    
    print("Update successful")
except subprocess.CalledProcessError as e:
    print(f"Update failed: {e}")
    exit(1)

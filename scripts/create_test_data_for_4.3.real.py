import os
import sys
import cv2
import glob
import numpy as np
from scipy.io import loadmat


def crop(mask, orig_img):
    '''
    Crop masked segment of original image
    '''
    mask = cv2.findNonZero(mask)
    xmin = min([x[0][0] for x in mask])
    ymin = min([x[0][1] for x in mask])
    xmax = max([x[0][0] for x in mask])
    ymax = max([x[0][1] for x in mask])
    cropped_image = orig_img[ymin:ymax, xmin:xmax]
    return cropped_image

if __name__ == "__main__":
    # read meta file path (absolute, relative: not tested)
    real_world_data_dir = sys.argv[1]

    cwd = os.getcwd()
    _ = 'real-world-samples'
    out_dir_path_bg = os.path.join(cwd, _, 'sample_query-w-bg') # with bg
    out_dir_path_wo_bg = os.path.join(cwd, _, 'sample_query-wo-bg') # without bg 
    real_objects_wo_bg = os.path.join(cwd, _, 'real_objects_wo_bg') # without bg

    for dir in [out_dir_path_bg, out_dir_path_wo_bg, real_objects_wo_bg]:
        if not os.path.exists(dir):
            os.makedirs(dir)
    
    
    for mat_file in glob.glob(f"{real_world_data_dir}/*.mat"):
        print(mat_file)
        # read mat file
        mat_file_path = os.path.join(cwd, mat_file)
        r = loadmat(mat_file_path)

        orig_img = r['rgb']
        img_mask = r['labels'] # labels refined contain refined pred masks
        masked_orig_img = orig_img

        for obj_id in np.unique(img_mask)[1:]:
            # keep mask of required object
            mask = np.where(img_mask == obj_id, 1, 0)
            cropped_img = crop(mask, orig_img)
            cropped_img_name = f"{mat_file.split('/')[-1].replace('.mat', '')}_obj_{obj_id}.png"
            
            # convert all background to white
            mask_rgb = np.moveaxis([mask] * 3, 0, -1)
            orig_img_without_bg = mask_rgb * orig_img
            orig_img_without_bg = np.where(mask_rgb == 0, 255, orig_img_without_bg)
            cropped_img_without_bg = crop(mask, orig_img_without_bg)
            cropped_img_name_wo_bg = f"{mat_file.split('/')[-1].replace('.mat', '')}_obj_{obj_id}_wo_bg.png"
            # To handle: error: (-215:Assertion failed) !_img.empty() in function 'imwrite'
            try:
                cv2.imwrite(os.path.join(out_dir_path_bg, cropped_img_name), cropped_img)
                cv2.imwrite(os.path.join(out_dir_path_wo_bg, cropped_img_name_wo_bg), cropped_img_without_bg)
                cv2.imwrite(os.path.join(real_objects_wo_bg, cropped_img_name_wo_bg), orig_img_without_bg)
            except:
                pass
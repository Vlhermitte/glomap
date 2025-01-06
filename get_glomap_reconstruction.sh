#!/bin/bash

# This script generates a GOLMAP reconstruction from a number of input images
# Usage: sh get_golmap_reconstruction.sh <image-set-directory> <project-directory>

# Check the permissions of the script
if [ ! -r "$0" ] || [ ! -w "$0" ]; then
  echo "The script does not have the necessary read and write permissions."
  exit 1
fi

# Find colmap executable directory
colmap_path=$(which colmap)
glomap_path=$(whereis golmap)

if [ -z "$colmap_path" ]; then
  echo "COLMAP executable not found. Please install COLMAP and ensure it is in your PATH."
  exit 1
else
  colmap_folder=$(dirname "$colmap_path")
  echo "Found COLMAP executable at: ${colmap_path}"
fi

if [ -z "$glomap_path" ]; then
  echo "GOLMAP executable not found..."
  echo "Assuming GOLMAP is in the same folder as COLMAP. If not, please provide the path to GOLMAP."
  glomap_folder=$colmap_folder

  # Try glomap to check if we can use it
  ${glomap_folder}/golmap --help > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "GOLMAP executable not found. Please add GOLMAP to your PATH"
#    exit 1
  fi

else
  glomap_folder=$(dirname "$glomap_path")
  echo "Found GOLMAP executable at: ${glomap_path}"
fi

iname=$1
echo "Input image directory: ${iname}"
outf=$2

DATABASE=${outf}/sample_reconstruction.db

PROJECT_PATH=${outf}
echo "Project path: ${PROJECT_PATH}"
mkdir -p ${PROJECT_PATH}
mkdir -p ${PROJECT_PATH}/images

cp -r ${iname}/*.jpg ${PROJECT_PATH}/images

# If database does not exist, create a new database
if [ ! -f ${DATABASE} ]; then
  ${colmap_folder}/colmap feature_extractor \
    --database_path ${DATABASE} \
    --image_path ${PROJECT_PATH}/images \
	--ImageReader.camera_model RADIAL \
	--ImageReader.single_camera 1 \
	--SiftExtraction.use_gpu 1

${colmap_folder}/colmap sequential_matcher \
    --database_path ${DATABASE} \
    --SiftMatching.use_gpu 1
fi

mkdir ${PROJECT_PATH}/sparse
${colmap_folder}/glomap mapper \
    --database_path ${DATABASE} \
    --image_path ${PROJECT_PATH}/images \
    --output_path ${PROJECT_PATH}/sparse



mkdir ${PROJECT_PATH}/dense
${colmap_folder}/colmap image_undistorter \
    --image_path ${PROJECT_PATH}/images \
    --input_path ${PROJECT_PATH}/sparse/0/ \
    --output_path ${PROJECT_PATH}/dense \
    --output_type COLMAP --max_image_size 1500

${colmap_folder}/colmap patch_match_stereo \
    --workspace_path $PROJECT_PATH/dense \
    --workspace_format COLMAP \
    --PatchMatchStereo.geom_consistency true

${colmap_folder}/colmap stereo_fusion \
    --workspace_path $PROJECT_PATH/dense \
    --workspace_format COLMAP \
    --input_type geometric \
    --output_path $PROJECT_PATH/dense/fused.ply
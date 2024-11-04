#!/bin/bash

# Start a timer for the script
start=$(date)

colmap_folder=$1/
iname=$2/
outf=$3/

DATABASE=${outf}sample_reconstruction.db

PROJECT_PATH=${outf}
mkdir -p ${PROJECT_PATH}
mkdir -p ${PROJECT_PATH}/images

cp -n ${iname}*.jpg ${PROJECT_PATH}/images

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
# We assume that glomap is a the same path as colmap
${colmap_folder}/golmap mapper \
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



# End the timer for the script
end=$(date)
echo "Time taken to run the script: $((end-start))"


colmap gui --import_path ../images/Ignatius/images/sparse/0/ --database_path ../images/Ignatius/images/database.db --image_path ../images/Ignatius/images/
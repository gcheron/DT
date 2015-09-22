#! /bin/bash
#compute FV improved trajectories for the given train and test lists
# parameter 1: dataset name 
# parameter 2: videos list path
# parameter 3: splitlists dir path
# parameter 4: number of wanted trajectory features for training pca and gmm
# Example:
# sh compute_FV_train_test.sh  dummy  /sequoia/data2/gcheron/dummy/videos/video_list.txt /sequoia/data2/gcheron/dummy/splitlists 5000000
# sh compute_FV_train_test.sh  MPII_cooking_activities  /sequoia/data2/gcheron/MPII_cooking_activities_full/videos_in_actions/video_list.txt /sequoia/data2/gcheron/MPII_cooking_activities_full/splitlists/modelsplits 500000
# sh compute_FV_train_test.sh  JHMDB  /sequoia/data2/gcheron/JHMDB/videos/video_list.txt /sequoia/data2/gcheron/JHMDB/splitlists/modelsplits 500000
# sh compute_FV_train_test.sh  JHMDB_humanboxes  /sequoia/data2/gcheron/JHMDB/videos/video_list.txt /sequoia/data2/gcheron/JHMDB/splitlists/modelsplits 500000

set -e

# display paramters
echo "Dataset name: $1"
echo "Video list in: $2"
echo "Splitlists in: $3"
echo "PCA/GMM samples: $4"


rundir=$(eval "pwd")
codedir=/sequoia/data2/gcheron/DT/code

train1dirs=$(eval "ls $3/*_train1.txt")
firsttrain=$(echo $train1dirs | cut -d " " -f1)
nb_train_examples=$(eval "cat $firsttrain | wc -l")

echo "number of training examples in first split ($firsttrain): $nb_train_examples"

if [ $# -ne 4 ]; 
then
        echo "illegal number of parameters"
        exit 1
fi

# make directories for the current dataset
mkdir -p $1 $1/jobs/qsub_jobs $1/improved_dense_trajectories $1/sub-traj $1/cutting/subsampled $1/concatenations $1/pca $1/proj $1/gmm $1/fisher_pyr


# compute DTs (which are not already computed)
sh $codedir/generate_jobs_DT_features.sh  $2 $rundir/$1 # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_DT.txt # launch jobs 
echo "command is sh $codedir/generate_jobs_DT_features.sh  $2 $rundir/$1"
sh $codedir/wait_end_job_named.sh dense_traj # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors


# get samples from DTs
sh $codedir/generate_jobs_sub_samples.sh $2 $rundir/$1 $4 $nb_train_examples # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_sub_sample.txt # launch jobs 
echo "command is sh $codedir/generate_jobs_sub_samples.sh $2 $rundir/$1 $4 $nb_train_examples"
sh $codedir/wait_end_job_named.sh sub_sample # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

# cut DT features into HOG, HOF, MBHx and MBHy
sh $codedir/generate_jobs_cut.sh  $2 $rundir/$1 # generate jobs
sh $codedir/generate_jobs_cut_subsampled.sh  $2 $rundir/$1 # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_cutting.txt # launch jobs
sh $codedir/launcher.sh $1/jobs/joblist_cutting_subsampled.txt # launch jobs
echo "command are sh $codedir/generate_jobs_cut.sh  $2 $rundir/$1 and sh $codedir/generate_jobs_cut_subsampled.sh  $2 $rundir/$1"
sh $codedir/wait_end_job_named.sh cutting # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

# concatenate samples for each of the 4 descriptors for each of the training lists
sh $codedir/generate_jobs_train_concatenation.sh $3 $rundir/$1 $codedir # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_train_concat.txt # launch jobs
echo "command is sh $codedir/generate_jobs_train_concatenation.sh $3 $rundir/$1 $codedir "
sh $codedir/wait_end_job_named.sh train_conc # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

# compute PCAs for each of the 4 descriptors for each of the training lists
sh $codedir/generate_jobs_train_pca.sh  $3 $rundir/$1 $codedir # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_pca.txt # launch jobs
echo "command is sh $codedir/generate_jobs_train_pca.sh  $3 $rundir/$1 $codedir"
sh $codedir/wait_end_job_named.sh pca # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

# project train concatenated samples with PCA plan
sh $codedir/write_trainconcat_pairlist_pcaplan.sh $3 $rundir/$1 # write the sequencename/plan pairs list
sh $codedir/generate_jobs_projections.sh $1/jobs/trainconcat_pairlist_pcaplan.txt 1 $rundir/$1 $codedir # generate projection jobs
sh $codedir/launcher.sh $1/jobs/joblist_project.txt # launch jobs
echo "command is sh $codedir/generate_jobs_projections.sh $1/jobs/trainconcat_pairlist_pcaplan.txt 1 $rundir/$1 $codedir"
sh $codedir/wait_end_job_named.sh projection # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

# compute GMM on projected examples
sh $codedir/generate_jobs_train_gmm.sh $3 $rundir/$1 $codedir # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_gmm.txt # launch jobs
echo "command is sh $codedir/generate_jobs_train_gmm.sh $3 $rundir/$1 $codedir"
sh $codedir/wait_end_job_named.sh gmm # wait for the end of the jobs
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

# compute Fisher Vectors
sh $codedir/write_train_test_pairlist_pcaplan.sh $3 $rundir/$1 # write the sequencename/plan pairs list
echo "command is sh $codedir/write_train_test_pairlist_pcaplan.sh $3 $rundir/$1 "

#mkdir $1/fisher
#sh $codedir/generate_jobs_fisher.sh $1/jobs/train_test_pairlist_pcaplan.txt $rundir/$1 $codedir # generate jobs
#sh $codedir/launcher.sh $1/jobs/joblist_fisher.txt # launch jobs
#sh $codedir/wait_end_job_named.sh fisher # wait for the end of the jobs
sh $codedir/generate_jobs_fisher_pyr.sh $1/jobs/train_test_pairlist_pcaplan.txt $rundir/$1 # generate jobs
sh $codedir/launcher.sh $1/jobs/joblist_fisher_pyr.txt # launch jobs
sh $codedir/wait_end_job_named.sh fisher_pyr # wait for the end of the jobs
echo "command is sh $codedir/generate_jobs_fisher_pyr.sh $1/jobs/train_test_pairlist_pcaplan.txt $rundir/$1"
sh $codedir/check_logs.sh $rundir/$1/jobs/logs # check log errors

#extract fisher vectors
sh $codedir/uncompress_fysher.sh $rundir/$1 



# Supervised learning classifiers predict the categorical metadata classes of unlabeled samples by learning 
# the composition of labeled training samples. For example, we may use a classifier to 
# diagnose or predict disease susceptibility based on stool microbiome composition, 
# or predict sample type as a function of the sequence variants, microbial taxa, or metabolites detected in a sample.

##USE THIS FOR RAREFIED TABLE####
qiime sample-classifier classify-samples \
--i-table ggtable.qza \
--m-metadata-file metadata_to_use.tsv \
--m-metadata-column diet \
--p-optimize-feature-selection \
--p-parameter-tuning \
--p-estimator RandomForestClassifier \
--p-n-estimators 20 \
--p-random-state 123 \
--output-dir diet-classifier

# For species only
qiime sample-classifier classify-samples \
--i-table species-collapse.qza \
--m-metadata-file metadata_to_use.tsv \
--m-metadata-column LSdiet \
--p-optimize-feature-selection \
--p-parameter-tuning \
--p-estimator RandomForestClassifier \
--p-n-estimators 20 \
--p-random-state 123 \
--output-dir species-classifier

# First let’s check out accuracy_results.qzv, which presents classification 
# accuracy results in the form of a confusion matrix, as well as Receiver Operating Characteristic (ROC) curves.
# view the .qzv file for accuracy_results.qzv

# This pipeline also reports the actual predictions made for each test sample
# in the predictions.qza output. This is a SampleData[ClassifierPredictions] artifact, 
# which is viewable as metadata. So we can take a peak with metadata tabulate:

#for diet
qiime metadata tabulate \
--m-input-file diet-classifier/predictions.qza \
--o-visualization diet-classifier/predictions.qzv

#for LSdiet
qiime metadata tabulate \
--m-input-file LSdiet-classifier/predictions.qza \
--o-visualization LSdiet-classifier/predictions.qzv

# for species
qiime metadata tabulate \
--m-input-file species-classifier/predictions.qza \
--o-visualization species-classifier/predictions.qzv

# In addition to the predicted class information, the model also reports the individual class probabilities
# in probabilities.qza. This is a SampleData[Probabilities] artifact, and is also viewable as metadata, 
# so let’s take a peak with metadata tabulate:


#for diet
qiime metadata tabulate \
  --m-input-file diet-classifier/probabilities.qza \
  --o-visualization diet-classifier/probabilities.qzv

# for LSdiet
qiime metadata tabulate \
  --m-input-file LSdiet-classifier/probabilities.qza \
  --o-visualization LSdiet-classifier/probabilities.qzv
# for species
qiime metadata tabulate \
  --m-input-file species-classifier/probabilities.qza \
  --o-visualization species-classifier/probabilities.qzv

# Another really useful output of supervised learning methods is feature selection, i.e., 
# they report which features (e.g., ASVs or taxa) are most predictive. 
# A list of all features, and their relative importances (or feature weights or model coefficients, 
# depending on the learning model used), will be reported in feature_importance.qza


#for diet
qiime metadata tabulate \
  --m-input-file diet-classifier/feature_importance.qza \
  --o-visualization diet-classifier/feature_importance.qzv

#for LS diet
qiime metadata tabulate \
  --m-input-file LSdiet-classifier/feature_importance.qza \
  --o-visualization LSdiet-classifier/feature_importance.qzv
# for species
qiime metadata tabulate \
  --m-input-file species-classifier/feature_importance.qza \
  --o-visualization species-classifier/feature_importance.qzv

# If --p-optimize-feature-selection is enabled, only the selected features (i.e., the most important features, 
# which maximize model accuracy, as determined using recursive feature elimination) will be reported in this 
# artifact, and all other results (e.g., model accuracy and predictions) that are output use the final, 
# optimized model that utilizes this reduced feature set. This allows us to not only see which features 
# are most important (and hence used by the model), but also use that information to filter out uninformative 
# features from our feature table for other downstream analyses outside of q2-sample-classifier:


#for diet
qiime feature-table filter-features \
  --i-table ggtable.qza \
  --m-metadata-file diet-classifier/feature_importance.qza \
  --o-filtered-table diet-classifier/important-feature-table.qza

#for LSdiet
qiime feature-table filter-features \
  --i-table ggtable.qza \
  --m-metadata-file LSdiet-classifier/feature_importance.qza \
  --o-filtered-table LSdiet-classifier/important-feature-table.qza
# for species

qiime feature-table filter-features \
  --i-table species-collapse.qza \
  --m-metadata-file species-classifier/feature_importance.qza \
  --o-filtered-table species-classifier/important-feature-table.qza

# We can also use the heatmap pipeline to generate an abundance heatmap of the most important 
# features in each sample or group. Let’s make a heatmap of the top 30 most abundant features in each of our sample types:


#diet
qiime sample-classifier heatmap \
  --i-table ggtable.qza \
  --i-importance diet-classifier/feature_importance.qza \
  --m-sample-metadata-file metadata_to_use.tsv \
  --m-sample-metadata-column diet \
  --m-feature-metadata-file new_taxonomy.tsv \
  --m-feature-metadata-column Taxon \
  --p-cluster both \
  --p-group-samples \
  --p-feature-count 30 \
  --o-filtered-table diet-classifier/important-feature-table-top-30.qza \
  --o-heatmap diet-classifier/important-feature-heatmap.qzv \
  --p-color-scheme RdYlBu_r


#LSdiet
qiime sample-classifier heatmap \
  --i-table ggtable.qza \
  --i-importance LSdiet-classifier/feature_importance.qza \
  --m-sample-metadata-file metadata.tsv \
  --m-sample-metadata-column LSdiet \
  --m-feature-metadata-file taxonomy.tsv \
  --m-feature-metadata-column Taxon \
  --p-cluster both \
  --p-group-samples \
  --p-feature-count 30 \
  --o-filtered-table LSdiet-classifier/important-feature-table-top-30.qza \
  --o-heatmap LSdiet-classifier/important-feature-heatmap.qzv \
  --p-color-scheme RdYlBu_r

# for species
qiime sample-classifier heatmap \
  --i-table species-collapse.qza \
  --i-importance species-classifier/feature_importance.qza \
  --m-sample-metadata-file metadata_to_use.tsv \
  --m-sample-metadata-column LSdiet \
  --p-cluster features \
  --p-group-samples \
  --p-feature-count 30 \
  --o-filtered-table species-classifier/important-feature-table-30.qza \
  --o-heatmap species-classifier/important-feature-heatmap.qzv \
  --p-color-scheme RdYlBu_r
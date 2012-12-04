#!/usr/bin/env bash

set -o pipefail

temp_dir=$ML_DESTDIR/temp
num_specific_segs=$(cat $ML_SPECIFIC_DOMAIN_CORPUS_PREFIX.$ML_SOURCE_LANG | wc -l)
languages=$(eval echo $ML_CALCULATION_LANGUAGES)

echo "--- Clearing the temporary directory." >&2
rm -rf $temp_dir
mkdir -p $temp_dir

# Copy corpora, insert space at the beginning of each line to prevent srilm
# from ignoring a line with a hash character at the beginning.
for lang in $languages; do
  # general-domain corpus
  cat $ML_GENERAL_DOMAIN_CORPUS_PREFIX.$lang \
    | sed 's/^/ /' \
    > $temp_dir/copied_general_domain_corpus_prefix.$lang
  # specific-domain corpus
  cat $ML_SPECIFIC_DOMAIN_CORPUS_PREFIX.$lang \
    | sed 's/^/ /' \
    > $temp_dir/copied_specific_domain_corpus_prefix.$lang
done

for lang in $languages; do
  echo
  echo "--- Extracting the $lang-side vocabulary from" >&2
  echo "--- the specific-domain corpus..." >&2
  # Only words that appeared more than once go into the vocab.
  $SRILM_DIR/ngram-count -text $temp_dir/copied_specific_domain_corpus_prefix.$lang -write-order 1 -write $temp_dir/specific_$lang.1cnt
  awk \
      '$2 > 1' \
      $temp_dir/specific_$lang.1cnt \
    | cut -f1 \
    | sort \
    > $temp_dir/specific_$lang.vocab
done

for lang in $languages; do
  echo
  echo "--- Selecting the equivalent number of segments from the $lang-side" >&2
  echo "--- of the general domain as in the specific domain for building a " >&2
  echo "--- language model." >&2
  head -n $num_specific_segs $temp_dir/copied_general_domain_corpus_prefix.$lang \
    > $temp_dir/general_lm_training_segments.$lang
done

for domain in general specific; do
  for lang in $languages; do
    echo
    echo "--- Building a language model from $domain-domain $lang text," >&2
    echo "--- with vocabulary restricted by that of the in-domain corpus." >&2
    if [ "$domain" == "specific" ]; then
      text=$temp_dir/copied_specific_domain_corpus_prefix.$lang
    else
      text=$temp_dir/general_lm_training_segments.$lang
    fi
    $GRID_CMD $SRILM_DIR/ngram-count \
      -unk \
      -interpolate \
      -order 5 \
      -kndiscount \
      -text $text \
      -vocab $temp_dir/specific_$lang.vocab \
      -lm $temp_dir/lm_${domain}_$lang.gz
  done
done

for domain in general specific; do
  for lang in $languages; do
    echo
    echo "--- Calculating the perplexity of the general-domain text segment " >&2
    echo "--- against the $domain $lang-side LM." >&2
    $GRID_CMD $SRILM_DIR/ngram -debug 1 -unk \
        -lm $temp_dir/lm_${domain}_$lang.gz \
        -ppl $temp_dir/copied_general_domain_corpus_prefix.$lang \
      | grep "zeroprobs.* logprob.* ppl.* ppl1" \
      | awk '{print $6}' \
      | head -n -1 \
      > $temp_dir/ppl_${domain}_${lang}
  done
done

for lang in $languages; do
  echo
  echo "--- Subtracting (the perplexity of the source-side $lang text against the" >&2
  echo "--- general-domain LM)" >&2
  echo "--- from (the perplexity of the source-side text against the" >&2
  echo "--- specific-domain LM)" >&2
  paste $temp_dir/ppl_specific_$lang $temp_dir/ppl_general_$lang \
    | awk -F '\t' '{print $1 - $2}' \
    > $temp_dir/ppl_diff_$lang
done

# If the number of ppl_diff files is 2, then add together the perplexity differences.
if [ $(ls $temp_dir/ppl_diff_* | wc -l) -eq 2 ]; then
  echo
  echo "--- Adding together the perplexity differences for both target-" >&2
  echo "--- and source-languages" >&2
  paste $temp_dir/ppl_diff_$ML_SOURCE_LANG $temp_dir/ppl_diff_$ML_TARGET_LANG \
    | awk -F '\t' '{print $1 + $2}' \
    > $temp_dir/ppl_diffs_summed
fi

# Determine whether to use ppl_diffs_summed or one of the ppl_diff_$lang files to create the training data sorted by rank.
if [ -e $temp_dir/ppl_diffs_summed ]; then
  rankfile=$temp_dir/ppl_diffs_summed
else
  rankfile=$temp_dir/ppl_diff_*
fi

echo
echo "--- Sorting training data by (summed) perplexity difference scores" >&2
echo "--- and deleting consecutive duplicate training candidates." >&2
# Combine score with source segment and target segment.
cat $rankfile \
  | paste - $ML_GENERAL_DOMAIN_CORPUS_PREFIX.$ML_SOURCE_LANG \
  | paste - $ML_GENERAL_DOMAIN_CORPUS_PREFIX.$ML_TARGET_LANG \
  > $temp_dir/scores_source_target.tsv

# Then sort in ascending orders (largest number is high perplexity against
# general-domain LM and much lower perplexity against specific-domain LM).
# Then delete consecutive duplicates.
cat $temp_dir/scores_source_target.tsv \
	| sort -n \
	| uniq \
  > $temp_dir/sorted-uniq-scores_source_target.tsv

# Then write source and target training corpus files in sorted order.
echo
echo "--- Writing source and target training corpus files in sorted order." >&2
cat $temp_dir/sorted-uniq-scores_source_target.tsv \
	| tee \
	>(awk -F '\t' '{print $2}' \
		> $ML_DESTDIR/sorted_training.$ML_SOURCE_LANG) \
	>(awk -F '\t' '{print $3}' \
		> $ML_DESTDIR/sorted_training.$ML_TARGET_LANG) \
	> /dev/null


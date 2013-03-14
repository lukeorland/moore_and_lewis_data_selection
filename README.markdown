# Description #

This script works on parallel translation corpora that have two files, one
sentence per line in the source language file and the corresponding translation
on each line of the target-side translation file. The result of running this
script is a copy of the pair of parallel training data files, sorted with
sentences at the top that are most "similar" to the domain-specific data and
least "similar" at the bottom. It is then possible to subsample by selecting
the first N sentences from the sorted files.

The ranking computations can be done on one language side or both. When sorting
bilingually, the perplexity of the training sentence pair is calculated for
both languages then summed.


# Usage #

A recommended first step is to tokenize and normalize the general-domain
training and domain-specific data before processing them with this script.

## Command format ##

    ./ml_select.sh \
        GENERAL_DOMAIN_CORPUS_PREFIX \
        SPECIFIC_DOMAIN_CORPUS_PREFIX \
        DEST_DIR \
        SOURCE_LANG \
        TARGET_LANG \
        RANK_BY_SOURCE_LANG \
        RANK_BY_TARGET_LANG \
        [ SRILM_BIN_DIR ]

### Parameters ###

* `GENERAL_DOMAIN_CORPUS_PREFIX`

  This is the path to the pair of (normalized, tokenized) parallel
  general-domain files, with the final "." and language extension removed
  (e.g. `.fr`, `.en`).

  E.g. if the general-domain files are located at

      /path/to/general-domain.lc.tok.fr
      /path/to/general-domain.lc.tok.en

  then the value to pass for this parameter is

      /path/to/general-domain.lc.tok.fr

* `SPECIFIC_DOMAIN_CORPUS_PREFIX`

  This is the path to the (pair of) (normalized, tokenized) parallel
  specific-domain files, with the final "." and language extension removed
  (e.g. `.fr`, `.en`).

  E.g. if the specific-domain files are located at

      /path/to/specific-domain.lc.tok.fr
      /path/to/specific-domain.lc.tok.en

  then the value to pass for this parameter is

      /path/to/general-domain.lc.tok

* `DEST_DIR`

  The path to the existing directory where the sorted general-domain files
  should be written

* `SOURCE_LANG`

  The (probably two-letter) file extension of the source language.

  E.g. for the examples above, the value to pass for this parameter is `fr`.

* `TARGET_LANG`

  The (probably two-letter) file extension of the target language.

  E.g. for the examples above, the value to pass for this parameter is `en`.

* `RANK_BY_SOURCE_LANG`

  Whether to calculate the specific domain's language model's perplexity for
  each source-language sentence in the general-domain.

  The value to pass is either `true` or `false`.

* `RANK_BY_TARGET_LANG`

  Whether to calculate the specific domain's language model's perplexity for
  each target-language sentence in the general-domain.

  The value to pass is either `true` or `false`.

* `[ SRILM_BIN_DIR ]` (optional)

  This parameter specifies the path to the directory where the SRILM binary
  tools (e.g. `ngram`, `ngram-count`) have been compiled in your system. It
  assumed by default that this location is the directory `$SRILM/bin/i686_m64`,
  where `SRILM` is a system variable that has been assigned to the path to the
  SRILM source code directory.

## Example command invocation ##

    ./ml_select.sh \
        /path/to/general-domain.lc.tok \
        /path/to/specific-domain.lc.tok \
        /path/to/destination_directory \
        fr \
        en \
        false \
        true \
        $HOME/code/srilm/bin/i686_m64

## Notes ##

The two parallel files in a corpus should have the same path prefix, and the
filename extension should be the language abbreviation (e.g. `.fr`, `.en`).

After calling the above command, the general-domain corpus is sorted,
duplicates are removed, and the result is copied into the two files such as the
following:

    /dest/dir/general_corpus_sorted.es
    /dest/dir/general_corpus_sorted.en


# How it works

## Calculating perplexity difference ##

Extracting the target-side vocabulary from
the specific-domain corpus...

Selecting the equivalent number of segments from the en-side
of the general domain as in the specific domain for building a 
language model.

Building a language model from general-domain en text,
with vocabulary restricted by non-singleton tokens from the in-domain corpus.

Building a language model from specific-domain en text,
with vocabulary restricted by non-singleton tokens from the in-domain corpus.

Calculating the perplexity of the general-domain text segment 
against the general en-side LM.

Calculating the perplexity of the general-domain text segment 
against the specific en-side LM.

Subtracting (the perplexity of the source-side en text against the
general-domain LM)
from (the perplexity of the source-side text against the
specific-domain LM)


The following computation process is performed first on the source-language
side, then the target-language side if desired.

Extract the vocabulary from the specific-domain corpus. The vocabulary consists
of all non-singleton types.

Build a language model from non-in-domain text, with vocabulary restricted by
that of the in-domain corpus.

Calculate the perplexity of the non-in-domain text against the
LM.

Calculate the perplexity of the source-side non-in-domain text against the
in-domain LM.

Combine perplexity differences, unprocessed/raw source-, and target-side text
segments into a single file.
"We partition N [non-in-domain set of segments] into tet segments (e.g.,
sentences), and score the segments according to HI(s)-HN(s), selecting all
text segments whose score is less than a threshold T".
Then sort it (largest number is high perplexity against non-in-domain LM and
much lower perplexity against in-domain LM).
Then delete consecutive duplicates.

This script prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment, all tab-delimited.
Finally, it sorts the file by the perplexity difference value.

------------------------------------

This script extracts the top number of lines corresponding to the percentage
(passed as $1 from the command line) of the total source segments from the
list of segments sorted/unsorted by perplexity difference.

This script prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment, all tab-delimited.
Finally, it sorts the file by the perplexity difference value.

It then prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment.

This script subtracts the perplexity of the source-side text against the
non-in-domain LM from the perplexity of the source-side text against the
in-domain LM.

It then prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment.

Finally, it sorts the file by the perplexity difference value.

## Sum the two differences together if required ##

Combine perplexity differences, unprocessed/raw source-, and target-side text
segments into a single file.
"We partition N [non-in-domain set of segments] into tet segments (e.g.,
sentences), and score the segments according to HI(s)-HN(s), selecting all
text segments whose score is less than a threshold T".
Then sort it (largest number is high perplexity against non-in-domain LM and
much lower perplexity against in-domain LM).
Then delete consecutive duplicates.

Adding together the perplexity differences for both target-
and source-languages

Sorting training data by (summed) perplexity difference scores
and deleting consecutive duplicate training candidates.

Writing source and target training corpus files in sorted order.

## Sort the general domain lines by ranking ##

Finally, it sorts the file by the perplexity difference value.

# TODO #

* Sort files aligned by Berkeley Aligner or GIZA++

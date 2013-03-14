# Description #

This script applies Moore and Lewis's approach to [intelligently selecting
training data](http://research.microsoft.com/apps/pubs/default.aspx?id=138756)
to domain adaptation of translation models for machine translation.

The result of running this script is a copy of a randomly-ordered
general-domain corpus, sorted such that the sentences at the top are most
"similar" to the domain-specific data and the least "similar" sentences are at
the bottom. It is then possible to subsample by selecting the first N sentences
from the sorted files.

This script operates on the type of parallel translation corpora that have two
files, one sentence per line in the source language file, and corresponding
translation appears on each line of the target-side translation file.

The ranking computations can be done on one language side or both. When sorting
bilingually, the ranking of a training sentence pair is its sum of rankings for
both languages.

# Usage #

A recommended first step is to tokenize and normalize the general-domain
training data and domain-specific data before processing them with this script.

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
  (e.g. `.fr`, `.en`). The is the corpus that will be resorted.

  E.g. if the general-domain files are located at

      /path/to/general-domain.lc.tok.fr
      /path/to/general-domain.lc.tok.en

  then the value to pass for this parameter is

      /path/to/general-domain.lc.tok.fr

* `SPECIFIC_DOMAIN_CORPUS_PREFIX`

  This is the path to the (pair of) (normalized, tokenized) parallel
  specific-domain files, with the final "." and language extension removed
  (e.g. `.fr`, `.en`). The general-domain corpus is resorted by similarity to
  this corpus.

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
filename extension should be the language abbreviations followed by a period
(e.g. `.fr`, `.en`).

After calling the above command, the general-domain corpus is sorted,
duplicates are removed, and the result is copied into the two files such as the
following:

    /dest/dir/general_corpus_sorted.es
    /dest/dir/general_corpus_sorted.en


# How it works

This Bash script takes the following steps to accomplish its task.

## Calculate perplexity difference ##

1.  Extract the target-side vocabulary from the specific-domain corpus

1.  Select the equivalent number of segments from the target-side of the
    general domain as in the specific domain for building a language model.

1.  Build a language model from general-domain target text,
    with vocabulary restricted by non-singleton tokens from the in-domain
    corpus.

1.  Build a language model from specific-domain target text,
    with vocabulary restricted by non-singleton tokens from the in-domain
    corpus.

1.  Calculate the perplexity of the general-domain text segment
    against the general target-side LM.

1.  Calculate the perplexity of the general-domain text segment against the
    specific target-side LM.

1.  Subtract the perplexity of the source-side target text against the
    general-domain LM from the perplexity of the source-side text against the
    specific-domain LM

The following computation process is performed first on the source-language
side, then the target-language side if desired.

1.  Extract the vocabulary from the specific-domain corpus. The vocabulary
    consists of all non-singleton types.

1.  Build a language model from non-in-domain text, with vocabulary restricted
    by that of the in-domain corpus.

1.  Calculate the perplexity of the non-in-domain text against the LM.

1.  Calculate the perplexity of the source-side non-in-domain text against the
    in-domain LM.

1.  Combine perplexity differences, unprocessed/raw source-, and target-side
    text segments into a single file.

This script prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment, all tab-delimited.
Finally, it sorts the file by the perplexity difference value.

## Sum the two differences together if doing bilingual ranking ##

1.  Combine perplexity differences, unprocessed/raw source-, and target-side
    text segments into a single file.
1.  Add together the perplexity differences for both target- and
    source-languages

## Sort the general domain lines by ranking ##

1.  Sort training data by (summed) perplexity difference scores and delete
    consecutive duplicate training candidates.
1.  Write source and target training corpus files in sorted order.


# TODO #

* Sort files aligned by Berkeley Aligner or GIZA++


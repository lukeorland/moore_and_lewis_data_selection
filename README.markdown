# Usage #

Clearing the temporary directory.

## Example command ##

    SRILM_DIR=/path/to/srilm/bin \
    ML_GENERAL_DOMAIN_CORPUS_PREFIX=/general_domain/path/prefix \
    ML_SPECIFIC_DOMAIN_CORPUS_PREFIX=/specific_domain/path/prefix \
    ML_DEST_DIR=/dest/dir \
    ML_SOURCE_LANG=es \
    ML_TARGET_LANG=en \
    ML_RANK_BY_SOURCE_LANG=true \
    ML_RANK_BY_TARGET_LANG=true \
    ./ml_select.sh

The two parallel files in a corpus should have the same path prefix, and the
filename extension should be the language abbreviation.

# Description #

After calling the above command, the general-domain corpus is sorted,
duplicates are removed, and the result is copied into the two files such as the
following:

    /dest/dir/general_corpus_sorted.es
    /dest/dir/general_corpus_sorted.en

## Calculate perplexity difference ##

TODO: clean this up:

Extracting the en-side vocabulary from
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

# TODO

- sort files aligned by berkeley or giza

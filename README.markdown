# Example command:

    GRID_CMD="" \
    SRILM_DIR=/path/to/srilm/bin \
    ML_GENERAL_DOMAIN_CORPUS_PREFIX=/general_domain/path/prefix \
    ML_SPECIFIC_DOMAIN_CORPUS_PREFIX=/specific_domain/path/prefix  \
    ML_DESTDIR=/dest/dir  \
    ML_SOURCE_LANG=es  \
    ML_TARGET_LANG=en  \
    ML_CALCULATION_LANGUAGES={es,en}  \
    ./ml_select.sh

# Description

TBD...

It then prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment.

Finally, it sorts the file by the perplexity difference value.

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

This script prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment, all tab-delimited.
Finally, it sorts the file by the perplexity difference value.

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

This script prints out a file with the calculated perplexity difference, the
source-side text segment, then the target-side text segment, all tab-delimited.
Finally, it sorts the file by the perplexity difference value.

This script extracts the top number of lines corresponding to the percentage
(passed as $1 from the command line) of the total source segments from the
list of segments sorted/unsorted by perplexity difference.

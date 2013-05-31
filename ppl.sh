#!/bin/bash
# Usage: ./ppl.sh lm.gz

# Pipe lines through this script to calculate the perplexity of lm.gz for each
# line of text.
set -u

lm=$1
$SRILM_BIN_DIR/ngram -debug 1 -unk -lm $lm -ppl - 2>/dev/null \
  | grep "zeroprobs.* logprob.* ppl.* ppl1" \
  | awk '{print $6}' \
  | head -n -1

POSSIBLE EXPLANATION FOR DIFFERING RESULTS


Confidence Level = 1 to 10 (1 is not confident the statement is true, 10 is very confident the statement is true)
------------------------------------------
iGenomics will not find an initial alignment if a large portion of a read extends over the end of a segment (9)
-->For iGenomics, clipping does not come into play until an alignment is actually found so this would likely be pre-clipping (7)
-->The Edit Distance Computation MAY (not positive about this yet) count extending past the beginning to the edit distance and extending past the end to the edit distance (5)
----->So some alignments MAY not even be reported because their ED is too high at the time of Edit Distance Computation (5)
-->Current Status: UNCONFIRMED .. need to test this

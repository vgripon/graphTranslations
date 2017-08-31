# Finding neighborhood preserving translations on graphs

## Installation

```
ocamlopt str.cmxa main.ml -o main.native
```

Or, if you prefer slow version
```
ocamlc str.cma main.ml -o main.bytecode
```

## Usage

This is an OCaml implementation of the methodology described in [this paper](http://vincent-gripon.com/index.php?p1=100&p2=100&p3=039).

Input is read on stdin. Format is the following: vertices are labelled from 0 to n-1. First line contains n, then each consecutive line contains the list of neighbors of the next vertex (starting from vertex 0) separated by blank spaces.

For example for a ring graph:
```
8
1 7
0 2
1 3
2 4
3 5
4 6
5 7
6 0
```

Output contains the list of maximal translations found on this graph.
Complexity is clearly exponential so do not expect results on large graphs.

Example output:
```
Extracting maximal translation with loss 0
1 2 3 4 5 6 7 0 
Extracting maximal translation with loss 0
7 0 1 2 3 4 5 6
```

Output is read as image_of_vertex0 image_of_vertex1 ... image_of_vertexn-1.
A -1 means the vertex has no image.


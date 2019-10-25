# MeshGenerator_SWE
Generate 2D mesh with elevation for shallow water equation modelling.

The files for creating a mesh is from `MESH2D` by Darren Engwirda [1]. MESH2D is designed to provide a simple and easy-to-understand implementation of Delaunay-based mesh-generation techniques. For a much more advanced, and fully three-dimensional mesh-generation library, see the JIGSAW package. MESH2D makes use of the AABBTREE and FINDTRIA packages to compute efficient spatial queries and intersection tests.

The code for interplation of elevation information from measured cross-section profiles on a 2D mesh is written based on the algorithm propoesed by B.Schäppi [2].

The code for topographic interplation in the confluence area of a river network is './'

[1] - Darren Engwirda, Locally-optimal Delaunay-refinement and optimisation-based mesh generation, Ph.D. Thesis, School of Mathematics and Statistics, The University of Sydney, September 2014.

[2] - B. Schäppi, P. Perona, P. Schneider, P. Burlando, Integrating river cross section measurements with digital terrain models for improved flow modelling applications, Computers & Geosciences, Volume 36, Issue 6, 2010, Pages 707-716, ISSN 0098-3004, http://dx.doi.org/10.1016/j.cageo.2009.12.004.
(http://www.sciencedirect.com/science/article/pii/S0098300410001020)



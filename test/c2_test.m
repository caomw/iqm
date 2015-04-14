addpath('../config');

%  %--------------------------------
%  cfg.it = 20;     % # of iterations
%  cfg.K  = 1000;   % # of clusters
%  cfg.c  = 512;    % # of cells
%  cfg.m  = 16;     % # of subspaces
%  cfg.k  = 256;    % fine codebook size
%  cfg.w  = 64;     % search window
%  cfg.rr = 128;    % centroid rerank
%  cfg.t  = 15000;  % search target
%  cfg.cn = 20;     % # of centroid neighbors
%  cfg.o  = .7;     % overlap threshold
%  %
%  %  cfg.dataset = 'siftsmall';
%  cfg.dataset = 'sift';
%  cfg.gen = false;
%  cfg.verbose = 1;

%--------------------------------
cfg.it = 10;    % # of iterations
cfg.K  = 24;    % # of clusters
cfg.c  = 64;    % # of cells
cfg.m  = 2;     % # of subspaces
cfg.k  = 16;    % fine codebook size
cfg.w  = 20;    % search window
cfg.rr = 16;    % centroid rerank
cfg.t  = 400;   % search target
cfg.cn = 10;    % # of centroid neighbors
cfg.o  = .7;    % overlap threshold
%
%  cfg.dataset = '2d_uni';
cfg.dataset = '2d_gm';
cfg.gen = false;
cfg.verbose = 2;

%--------------------------------
cfg = c2_config(cfg);

%  %--------------------------------
%  fprintf('Learning codebooks\n');
%  X = xload(cfg.learn);
%  u = cputime;
%  [G,B] = c2_learn(cfg, X);
%  fprintf('Learn time: %.3fs\n', cputime - u);
%  xsave(cfg.grid, G);
%  xsave(cfg.book, B);
%
%  %--------------------------------
%  fprintf('Encoding vectors & codebooks\n');
%  G = xload(cfg.grid);
%  B = xload(cfg.book);
%  X = xload(cfg.base);
%  u = cputime;
%  [C,E] = c2_encode(cfg, G, B, X);
%  fprintf('Encode time: %.3fs\n', cputime - u);
%  xsave(cfg.cell, C);
%  xsave(cfg.code, E);

%--------------------------------
fprintf('Inverting\n');
C = xload(cfg.cell);
X = xload(cfg.base);
u = cputime;
[P,Mi,M,I,cI] = c2_invert(cfg, C, X);
fprintf('Invert time: %.3fs\n', cputime - u);
xsave(cfg.pop, P);
xsave(cfg.mean_i, Mi);
xsave(cfg.mean, M);
xsave(cfg.idx, I);
save(cfg.inv, 'cI');

%--------------------------------
fprintf('Initializing\n');
G = xload(cfg.grid);
B = xload(cfg.book);
E = xload(cfg.cell);
P = xload(cfg.pop);
u = cputime;
W = c2_init(cfg, G, B, E, P);
fprintf('Initialize time: %.3fs\n', cputime - u);
xsave(cfg.cen, W);

%--------------------------------
fprintf('Iterating\n');
if cfg.synth
	X = xload(cfg.base);
	C = xload(cfg.cell);
else
	X = [];
	C = [];
end
W  = xload(cfg.cen);
G  = xload(cfg.grid);
B  = xload(cfg.book);
E  = xload(cfg.cell);
P  = xload(cfg.pop);
Mi = xload(cfg.mean_i);
M  = xload(cfg.mean);
cfg.K = size(W, 2);
u = cputime;
[W,A] = c2_iter(cfg, W, G, B, E, P, Mi, M, X, C);
fprintf('Iterate time: %.3fs\n', cputime - u);
xsave(cfg.cen, W);
xsave(cfg.asgn, A);

function [idx, dist] = ex_nn(Q, B, E, r, verb)

% idx: top-ranking points
% dist: top-ranking (least) distances
% Q: query points
% B: codebook
% E: encoded points
% r: # nearest neighbors
% verb: verbose mode

if nargin < 4, r = 1; end
if nargin < 5, verb = false; end

k = size(B,2);                                 % codebook size
m = size(E,1);                                 % # subspaces
[d, D, N] = slices(Q, m);                      % dims / subspace, dims, # queries

idx  = zeros(r, N, 'uint32');                  % top ranking indices
dist = zeros(r, N, 'single');                  % top ranking distances

for q = 1:N                                    % queries
	L = zeros(k, m, 'single');                  % lookup table
	for i = 1:m                                 % subspaces
		s = slice(i, d, D);                      % dimensions in subspace
		L(:,i) = yael_L2sqr(B(s,:), Q(s,q));     % codeword distances in subspace i
	end
	ex = search_lu(L, E);                       % exhaustive search
	[dist(:,q), idx(:,q)] = kmin(ex, r);        % top r points per query
	if verb & mod(q,100)==0, fprintf('.'), end
end

if verb, fprintf('\n'), end

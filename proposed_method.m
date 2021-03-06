function W = proposed_method(X_multiview, Label_multiview, num_view, options)

%% load parameter
if nargin < 4
    error('Algorithm parameters should be set!');
end
if ~isfield(options, 'lambda1')
    options.lambda1 = 0.01;
end
if ~isfield(options, 'lambda2')
    options.lambda2 = 0.05;
end
if ~isfield(options, 'beta')
    options.beta = 0.1;
end
if ~isfield(options, 'p1')
    options.p1 = 1;
end
if ~isfield(options, 'p2')
    options.p2 = 10;
end
if ~isfield(options, 'dim')
    options.dim = 30;
end

lambda1 = options.lambda1;
lambda2 = options.lambda2;
beta = options.beta;
p1 = options.p1;
p2 = options.p2;
dim = options.dim;

%% construct X
num_feature = size(X_multiview{1}, 1);
num_sample = size(X_multiview{1}, 2);

X = zeros(num_feature*num_view, num_sample*num_view);
for v = 1: num_view
    X(num_feature*(v-1)+1:num_feature*v, num_sample*(v-1)+1:num_sample*v) = X_multiview{v};
end

%% computing J
J = zeros(num_view*num_sample, num_view*num_sample);
I = eye(num_view*num_sample);
for v = 1 : (num_view-1)
    Ji = [I(:, num_sample*v+1:num_sample*num_view), I(:, 1:num_sample*v)];
    J = J + (I - Ji)*(I - Ji).';
end

%% computing U and V
S1 = cell(1, num_view);
S2 = cell(1, num_view);
if p1 ~= 0
    S1 = nearest_neighbor_index(X_multiview, Label_multiview{1}, p1, 1); % intra-view within-class nearest neighbors 
end
if p2 ~= 0
    S2 = nearest_neighbor_index(X_multiview, Label_multiview{1}, p2, 0); % inter-view between-class nearest neighbors
end

STmp = cell(1, num_view);
for m = 1 : num_view
   S3 = [];
   S4 = [];
   for n = 1 : num_view
       if m~= n
            S3 = [S3, S1{n}+num_sample*(n-1)];
            S4 = [S4, S2{n}+num_sample*(n-1)];
       end
   end
   STmp{m} = [S3, S4];
end

S5 = [];
S6 = [];
STmp2 = [];
for m = 1  : num_view
    S5 = [S5; S1{m}+num_sample*(m-1)];
    S6 = [S6; S2{m}+num_sample*(m-1)];
    STmp2 = [STmp2; STmp{m}];
end
STmp1 = [S5, S6];
STmp1 = [(sort(randperm(num_sample*num_view)))', STmp1];
STmp2 = [(sort(randperm(num_sample*num_view)))', STmp2];

U = construct_L(STmp1, p1, p2, beta, num_sample, num_view);
V = construct_L(STmp2, p1*(num_view-1), p2*(num_view-1), beta, num_sample, num_view);

%% eigenvalue decomposition
T = X*(J+lambda1*U+lambda2*V)*X.';
T = (T+T.')/2;
[V, D] = eig(T);
eigenvalues = ones(1, size(D, 1)) * D;
[~, index] = sort(eigenvalues);
UDLA = V(:,index);

W = cell(1, num_view);
for v = 1:num_view
   W{v} = UDLA(num_feature*(v-1)+1:num_feature*v, 1:dim); 
end
end
function newmeans = ls_slam(vmeans, eids, emeans, einfs, etype, n)

error=1;
for i=1:n
    vmeans;
    vmeans = linearize_and_solve(vmeans, eids, emeans, einfs,etype);
end

newmeans = vmeans;

end


%computes the taylor expansion of the error function of the k_th edge
%vmeans: vertices positions
%eids:   edge ids
%emeans: edge means
%k:	 edge number
%e:	 e_k(x)
%A:	 d e_k(x) / d(x_i)
%B:	 d e_k(x) / d(x_j)
function [e, A, B] = linear_factors(vmeans, eids, emeans,etype, k)
%extract the ids of the vertices connected by the kth edge
id_i = eids(1,k);
id_j = eids(2,k);
%extract the poses of the vertices and the mean of the edge
v_i = vmeans(:,id_i);
v_j = vmeans(:,id_j);
xi=v_i(1);yi=v_i(2);
xj=v_j(1);yj=v_j(2);
z_ij = emeans(:,k);
temp_d=norm(v_j-v_i);
temp_type=etype(k);
if temp_type==1%只有距离约束
    e=(v_j-v_i)*(z_ij(1)/temp_d);
    %A=[v_i(1)-v_j(1),v_i(2)-v_j(2);0,0]/temp_d;
    A= [-1,0;0, -1 ];
    B=-A;
elseif temp_type==2%只有角度约束
    e=v_j-v_i-z_ij*temp_d;
    A=[-1,0;0,-1];
    B=-A;
elseif temp_type==3%联合约束
    e=(v_j-v_i)-z_ij;
    A= [-1,0;0, -1 ];
    B =-A;
end
    

end


%linearizes and solves one time the ls-slam problem specified by the input
%vmeans:   vertices positions at the linearization point
%eids:     edge ids
%emeans:   edge means
%einfs:    edge information matrices
%newmeans: new solution computed from the initial guess in vmeans
function newmeans = linearize_and_solve(vmeans, eids, emeans, einfs,etype)
%disp('allocating workspace...');
% H and b are respectively the system matrix and the system vector
H = zeros(size(vmeans,2)*2);
b = zeros(size(vmeans,2)*2,1);

%disp('linearizing');
% this loop constructs the global system by accumulating in H and b the contributions
% of all edges (see lecture)
for k = 1:size(eids,2),
    id_i = eids(1,k);
    id_j = eids(2,k);
    [e, A, B] = linear_factors(vmeans, eids, emeans,etype,  k);
    omega = einfs(:,:,k);
    %compute the blocks of H^k
    b_i = -A' * omega * e;
    b_j = -B' * omega * e;
    H_ii=  A' * omega * A;
    H_ij=  A' * omega * B;
    H_jj=  B' * omega * B;
    %accumulate the blocks in H and b
    H((id_i-1)*2+1:id_i*2,(id_i-1)*2+1:id_i*2) = ...
        H((id_i-1)*2+1:id_i*2,(id_i-1)*2+1:id_i*2)+ H_ii;
    H((id_j-1)*2+1:id_j*2,(id_j-1)*2+1:id_j*2) = ...
        H((id_j-1)*2+1:id_j*2,(id_j-1)*2+1:id_j*2) + H_jj;
    H((id_i-1)*2+1:id_i*2,(id_j-1)*2+1:id_j*2) = ...
        H((id_i-1)*2+1:id_i*2,(id_j-1)*2+1:id_j*2) + H_ij;
    H((id_j-1)*2+1:id_j*2,(id_i-1)*2+1:id_i*2) = ...
        H((id_j-1)*2+1:id_j*2,(id_i-1)*2+1:id_i*2) + H_ij';
    b((id_i-1)*2+1:id_i*2,1) = ...
        b((id_i-1)*2+1:id_i*2,1) + b_i;
    b((id_j-1)*2+1:id_j*2,1) = ...
        b((id_j-1)*2+1:id_j*2,1) + b_j;
    
    %NOTE on Matlab compatibility: note that we use the += operator which is octave specific
    %using H=H+.... results in a tremendous overhead since the matrix would be entirely copied every time
    %and the matrix is huge
end;
disp('Done');
%note that the system (H b) is obtained only from
%relative constraints. H is not full rank.
%we solve the problem by anchoring the position of
%the the first vertex.
%this can be expressed by adding the equation
%  deltax(1:3,1)=0;
%which is equivalent to the following
H(1:2,1:2) = H(1:2,1:2) + eye(2);

SH = sparse(H);
%disp('System size: '),disp(size(H));
%disp('solving (may take some time) ...');
deltax = SH\b;
%disp('Done! ');

%split the increments in nice 3x1 vectors and sum them up to the original matrix
newmeans = vmeans + reshape(deltax, 2, size(vmeans,2));


end

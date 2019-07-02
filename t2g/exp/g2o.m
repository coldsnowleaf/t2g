function [ pos ] = g2o( edgematrix, pp )

IterationNum = 100;
Termination  = 1e-5;
lamada = 1; % lamada越大，每步迭代步长越小

[row, col ] = size(pp);

% x: 自变量组成的向量,迭代中使用
x = pp;

% 雅克比矩阵 j_ij;所有边都一样
J = [1,-1];

% J'*J
JtJ= J'*J;


% H 迭代使用的矩阵,是个稀疏矩阵，当顶点数量大于100时,
% 需要考虑稀疏矩阵的求解方法，到时候可能需要c++实现一个版本，不然速度奇慢
H = zeros(col);
for i = 1 : col
    for j = i : col
        if edgematrix(i,j).connect > 0
            id = [i, j];
            H(id, id) = H(id, id) + edgematrix(i,j).conf * JtJ;
        end
    end
end

move = 1;
count = 1;


%Iteration
while count< IterationNum && move > Termination
    b = zeros(col, 2);
    detaX = zeros(col, 2);
    
    for i = 1 : col
        for j = i : col
            if edgematrix(i,j).connect >0
                id = [i, j];
                measure = edgematrix(i,j).measureavg';
                b(id,:) = b(id,:) + edgematrix(i,j).conf * J' * (x(:,i) - x(:,j) - measure')';  
            end           
        end
    end
    % (H+lamada*I) * detaX = -b  , 迭代方程
    detaX = - inv( H + lamada * eye(col) ) * b;
    move = norm(detaX);
    x = x + detaX';
    count = count + 1;
    lamada = lamada + 0.1;  
end

pos = x;

end


function [ pos ] = g2o( edgematrix, pp )

IterationNum = 100;
Termination  = 1e-5;
lamada = 1; % lamadaԽ��ÿ����������ԽС

[row, col ] = size(pp);

% x: �Ա�����ɵ�����,������ʹ��
x = pp;

% �ſ˱Ⱦ��� j_ij;���б߶�һ��
J = [1,-1];

% J'*J
JtJ= J'*J;


% H ����ʹ�õľ���,�Ǹ�ϡ����󣬵�������������100ʱ,
% ��Ҫ����ϡ��������ⷽ������ʱ�������Ҫc++ʵ��һ���汾����Ȼ�ٶ�����
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
    % (H+lamada*I) * detaX = -b  , ��������
    detaX = - inv( H + lamada * eye(col) ) * b;
    move = norm(detaX);
    x = x + detaX';
    count = count + 1;
    lamada = lamada + 0.1;  
end

pos = x;

end


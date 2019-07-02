global FPErrorArray;
global G2OErrorArray;
global FPMeanArray;
global G2OMeanArray;
%load OfflineTrain.mat
load testcluster.mat
%load addcluster.mat
pointpos = [];
clear edgematrix;
clear ConnectivityM;
ConnectivityM = zeros(nodelength, nodelength);
for i = 1 : nodelength
    for j = 1 : nodelength
        edgematrix(i,j).lengtharray = [];
        edgematrix(i,j).measurearray = [];
    end
end

for i = 1 : nodelength
    pointpos(1:2, i) = point(i).clusterpos;
end



%for i = 1 : size(AllRSS, 2) - 1
%for i1 = 1 : size(AllRSS, 2) - 1 
i1 = 1;
while i1 <  size(AllRSS,2) - 1
    i2 = i1 + 1;
    if AllRSS(Nap+3:Nap+4, i1) ~= 10000 
    edgea = [];
    edgea = AllRSS(Nap+3:Nap+4, i1);  
    while 1
        if (AllRSS(Nap+5, i2) ~= AllRSS(Nap+5, i1)) | (i2 >= size(AllRSS,2)) |  (mean(AllRSS(Nap+3:Nap+4, i2)) == 10000)
            break;
        end
        edgea = [edgea, AllRSS(Nap+3:Nap+4, i2)];
        i2 = i2 + 1;
        %AllRSS(Nap+5, i2) == AllRSS(Nap+5, i1) & i2 < size(AllRSS,2) &  mean(AllRSS(Nap+3:Nap+4, i2)) ~= 10000
    end
    
    %edge = sum(edgea, 2)/2;
    if size(edgea, 2) > 1
        edge = sum(edgea(:,1:size(edgea,2)-1), 2)/2 + edgea(:,size(edgea,2));
    else
        edge = edgea;
    end
    n1 = AllRSS(Nap+5, i1);
    n2 = AllRSS(Nap+5, i2);
    i1 = i2;
    edge = edge;
    %edge = sum(edgea, 2);
%    edge = AllRSS(Nap+3:Nap+4, i);
%    if mean(edge) ~= 10000
%         if n1 == n2
%             edgematrix(n1,n2).measurearray = [];
%             edgematrix(n1,n2).lengtharray = [];
%             edgematrix(n1,n2).connect = 0;
%             ConnectivityM(n1,n2) = 0;
%         else
          if n1 ~= n2
             edgematrix(n1,n2).measurearray = [edgematrix(n1,n2).measurearray, edge];
             edgematrix(n1,n2).lengtharray = [edgematrix(n1,n2).lengtharray, norm(edge, 2)];
             edgematrix(n2,n1).measurearray = [edgematrix(n2,n1).measurearray, -edge];
             edgematrix(n2,n1).lengtharray = [edgematrix(n2,n1).lengtharray, norm(edge, 2)];
             edgematrix(n1,n2).connect = 1;
             edgematrix(n2,n1).connect = 1;
             ConnectivityM(n1,n2) = 3;
             ConnectivityM(n2,n1) = 3;
         end
%        end
    else
        i1 = i1+1;
    end
end


t = 1;
edgefilter1error = [];
edgefilter2error = [];
edgefilter3error = [];
errorarray = [];
for i = 1 : nodelength
    for j = 1 : nodelength
        if length(edgematrix(i,j).lengtharray) >= 1
            gd = point(i).clusterpos - point(j).clusterpos;
            error = norm(gd - mean(edgematrix(i,j).measurearray, 2));
            errorarray = [errorarray,  gd - mean(edgematrix(i,j).measurearray, 2)];
            edgematrix(i,j).measureavg = mean(edgematrix(i,j).measurearray, 2)+[0.05*randn();0.05*randn()];
            %edgematrix(i,j).conf = length(edgematrix(i,j).lengtharray)/10;%mean(bestw(edgematrix(i,j).measurearray, edgematrix(i,j).measureavg));
            edgematrix(i,j).conf =  length(edgematrix(i,j));%mean(bestw(edgematrix(i,j).measurearray, edgematrix(i,j).measureavg));
            if length(edgematrix(i,j).lengtharray) == 1
                edgefilter1error = [edgefilter1error; error];
            end
            if length(edgematrix(i,j).lengtharray) > 1
                if length(edgematrix(i,j).lengtharray) == 2
                    edgefilter2error = [edgefilter2error; error];
                end
                if length(edgematrix(i,j).lengtharray) == 3
                    edgefilter3error = [edgefilter3error; error];
                end
            end
        end
    end
end
figure
subplot(2,1,1)
bar([length(edgefilter1error),length(edgefilter2error),length(edgefilter3error)]);
xlabel('The number of edges'); ylabel('The number of samples'); title('');
subplot(2,1,2)
bar([mean(edgefilter1error),mean(edgefilter2error),mean(edgefilter3error)]/20);
xlabel('The number of edges'); ylabel('Average error(m)'); title('');
% figure
% set(cdfplot(errorarray(1,:)), 'linewidth', 2,'color', 'b', 'marker', '+');
% hold on
% set(cdfplot(errorarray(2,:)), 'linewidth', 2, 'color', 'm', 'marker', 'o');
save testedgefilterplusr.mat